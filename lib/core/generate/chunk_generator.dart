import 'dart:math' as math;

import '../ingest/chunker.dart';
import '../text/matching.dart';
import 'checks.dart';
import 'cloze.dart';
import 'json_model.dart';
import 'profile.dart';
import 'prompts.dart';

enum QuestionType { cloze, flashcard, mcq }

/// One passage (chunk) and what the prompts need to know about it.
class PassageInput {
  const PassageInput({
    required this.chunkId,
    required this.text,
    required this.headingPath,
    required this.language,
    this.context,
  });

  final int chunkId;
  final String text;
  final String headingPath;
  final String? language;

  /// Neighboring text of the same section, for Apply/Analyze questions.
  final String? context;

  int get tokens => estimateTokens(text);
}

class FactDraft {
  const FactDraft({
    required this.quote,
    required this.quoteStart,
    required this.quoteEnd,
    required this.statement,
    required this.keyTerm,
    required this.importance,
  });

  /// The source's own sentence (not the model's copy of it).
  final String quote;
  final int quoteStart;
  final int quoteEnd;
  final String statement;
  final String keyTerm;
  final int importance;
}

/// An existing fact the question stage writes questions for.
class FactInput {
  const FactInput({
    required this.id,
    required this.statement,
    required this.quote,
  });

  final int id;
  final String statement;
  final String quote;
}

class QuestionDraft {
  const QuestionDraft({
    required this.factIndex,
    required this.type,
    required this.depth,
    required this.prompt,
    required this.answer,
    this.distractors = const [],
    this.explanation,
    this.distractorNotes = const [],
    this.checks = const {},
  });

  /// Index into the facts it was written for.
  final int factIndex;
  final QuestionType type;
  final Depth depth;
  final String prompt;
  final String answer;
  final List<String> distractors;
  final String? explanation;
  final List<String> distractorNotes;

  /// What verification it passed, stored with the question.
  final Map<String, Object?> checks;
}

class RejectionDraft {
  const RejectionDraft(this.stage, this.reason, this.payload);

  final String stage;

  /// A [CheckFailure] name, or a short code for other reasons.
  final String reason;
  final Map<String, Object?> payload;
}

class FactsResult {
  const FactsResult(this.facts, this.questions, this.rejections);

  final List<FactDraft> facts;

  /// Cloze cards and flashcards; [QuestionDraft.factIndex] indexes [facts].
  final List<QuestionDraft> questions;
  final List<RejectionDraft> rejections;
}

class QuestionsResult {
  const QuestionsResult(this.questions, this.rejections);

  /// Multiple-choice questions; [QuestionDraft.factIndex] indexes the facts
  /// that were passed in.
  final List<QuestionDraft> questions;
  final List<RejectionDraft> rejections;
}

/// Turns one passage into verified study items, following a
/// [GenerationProfile]. Each stage is one batched model call per passage,
/// because Qwen3.5 can't reuse a cached prompt between calls.
class ChunkGenerator {
  ChunkGenerator({required this.model, required this.profile});

  final JsonModel model;
  final GenerationProfile profile;

  static const _batch = 6;

  /// Stage 1: facts with verified quotes, plus a cloze card (built by code)
  /// and a flashcard for each.
  Future<FactsResult> facts(PassageInput passage) async {
    final wanted = factsWanted(passage.tokens);
    final json = await model.json(
      stage: 'facts',
      messages: factsMessages(
        headingPath: passage.headingPath,
        text: passage.text,
        language: passage.language,
        count: wanted,
      ),
      schema: factsSchema(wanted),
      maxTokens: 100 + wanted * 170,
      temperature: 0.2,
    );

    final facts = <FactDraft>[];
    final questions = <QuestionDraft>[];
    final rejections = <RejectionDraft>[];
    for (final raw in _list(json['facts'])) {
      final item = _map(raw);
      String field(String key) => '${item[key] ?? ''}'.trim();

      final match = findQuote(passage.text, field('quote'));
      if (match == null) {
        rejections.add(
          RejectionDraft('facts', CheckFailure.quoteNotFound.name, item),
        );
        continue;
      }
      final statement = field('statement').isEmpty
          ? match.text
          : field('statement');
      final duplicate = facts.any(
        (f) =>
            _overlap(f.quoteStart, f.quoteEnd, match.start, match.end) > 0.5 ||
            similarity(f.statement, statement) >= 0.85,
      );
      if (duplicate) {
        rejections.add(
          RejectionDraft('facts', CheckFailure.duplicateFact.name, item),
        );
        continue;
      }

      final fact = FactDraft(
        quote: match.text,
        quoteStart: match.start,
        quoteEnd: match.end,
        statement: statement,
        keyTerm: stripQuoteWrapping(field('key_term')),
        importance: ((item['importance'] as num?)?.toInt() ?? 2).clamp(1, 3),
      );
      facts.add(fact);
      final index = facts.length - 1;

      final cloze = buildCloze(fact.quote, fact.keyTerm);
      if (cloze != null) {
        questions.add(
          QuestionDraft(
            factIndex: index,
            type: QuestionType.cloze,
            depth: Depth.recall,
            prompt: cloze.prompt,
            answer: cloze.answer,
          ),
        );
      } else {
        rejections.add(
          RejectionDraft('cloze', 'keyTermUnusable', {
            'quote': fact.quote,
            'key_term': fact.keyTerm,
          }),
        );
      }

      final failures = checkFlashcard(
        front: field('front'),
        back: field('back'),
        quote: fact.quote,
        statement: statement,
      );
      if (failures.isEmpty) {
        questions.add(
          QuestionDraft(
            factIndex: index,
            type: QuestionType.flashcard,
            depth: Depth.recall,
            prompt: field('front'),
            answer: field('back'),
          ),
        );
      } else {
        rejections.add(
          RejectionDraft('flashcard', failures.first.name, {
            'front': field('front'),
            'back': field('back'),
          }),
        );
      }
    }
    return FactsResult(facts, questions, rejections);
  }

  /// Stage 2: multiple-choice questions for [facts], then the blind check
  /// and (Thorough and up) the critique, keeping the best question per fact.
  Future<QuestionsResult> questions(
    PassageInput passage,
    List<FactInput> facts, {
    Iterable<String> existingQuestions = const [],
  }) async {
    if (facts.isEmpty || !profile.multipleChoice) {
      return const QuestionsResult([], []);
    }
    final rejections = <RejectionDraft>[];
    final depths = profile.usableDepths;
    final briefs = [
      for (final (i, fact) in facts.indexed)
        FactBrief(
          statement: fact.statement,
          quote: fact.quote,
          depth: depths[i % depths.length],
        ),
    ];

    // Write candidates in batches of facts so each reply stays short.
    final candidates = <_Candidate>[];
    for (final start in _starts(facts.length, _batch)) {
      final batch = briefs.sublist(
        start,
        math.min(start + _batch, briefs.length),
      );
      final notes = profile.explanation == ExplanationLevel.withDistractors;
      final json = await model.json(
        stage: 'mcq',
        messages: mcqMessages(
          headingPath: passage.headingPath,
          text: passage.text,
          language: passage.language,
          facts: batch,
          perFact: profile.candidatesPerFact,
          explanation: profile.explanation,
          context: profile.neighborContext ? passage.context : null,
        ),
        schema: mcqSchema(
          maxQuestions: batch.length * profile.candidatesPerFact,
          distractorNotes: notes,
        ),
        maxTokens:
            120 +
            batch.length * profile.candidatesPerFact * (notes ? 240 : 180),
        temperature: 0.5,
      );
      for (final raw in _list(json['questions'])) {
        final item = _map(raw);
        final number = (item['fact'] as num?)?.toInt() ?? 0;
        if (number < 1 || number > batch.length) {
          rejections.add(RejectionDraft('mcq', 'unknownFact', item));
          continue;
        }
        final index = start + number - 1;
        final candidate = _Candidate(
          factIndex: index,
          depth: briefs[index].depth,
          question: '${item['question'] ?? ''}'.trim(),
          answer: '${item['answer'] ?? ''}'.trim(),
          distractors: [
            for (final d in _list(item['distractors'])) '$d'.trim(),
          ],
          explanation: '${item['explanation'] ?? ''}'.trim(),
          notes: [for (final n in _list(item['why_wrong'])) '$n'.trim()],
        );
        if (_admit(candidate, passage, facts, existingQuestions, rejections)) {
          candidates.add(candidate);
        }
      }
    }

    for (var run = 0; run < profile.blindRuns; run++) {
      await _blindCheck(passage, candidates, run);
    }

    final accepted = <_Candidate>[];
    if (profile.critique && candidates.isNotEmpty) {
      accepted.addAll(
        await _critique(
          passage,
          facts,
          candidates,
          existingQuestions,
          rejections,
        ),
      );
    } else {
      for (final candidate in candidates) {
        if (candidate.problems.isEmpty) {
          accepted.add(candidate);
        } else {
          rejections.add(candidate.rejection(candidate.problems.first.name));
        }
      }
    }

    // Keep the best candidate per fact, and drop near-duplicates across facts.
    final byFact = <int, List<_Candidate>>{};
    for (final c in accepted) {
      byFact.putIfAbsent(c.factIndex, () => []).add(c);
    }
    final kept = <QuestionDraft>[];
    final keptTexts = <String>[];
    for (final entry in byFact.entries) {
      final ranked = entry.value..sort((a, b) => b.score.compareTo(a.score));
      final best = ranked.first;
      final text = '${best.question} ${best.answer}';
      if (keptTexts.any((other) => similarity(text, other) >= 0.8)) {
        rejections.add(best.rejection(CheckFailure.duplicateQuestion.name));
        continue;
      }
      keptTexts.add(text);
      kept.add(best.toDraft(profile));
    }
    return QuestionsResult(kept, rejections);
  }

  /// Runs the code checks; true when the candidate may continue.
  bool _admit(
    _Candidate c,
    PassageInput passage,
    List<FactInput> facts,
    Iterable<String> existingQuestions,
    List<RejectionDraft> rejections,
  ) {
    final fact = facts[c.factIndex];
    final failures = checkMcq(
      question: c.question,
      answer: c.answer,
      distractors: c.distractors,
      quote: fact.quote,
      statement: fact.statement,
      passage: passage.text,
      language: passage.language,
      requireGrounding: c.depth == Depth.recall || c.depth == Depth.understand,
      otherQuestions: existingQuestions,
    );
    final hard = failures.where((f) => !f.soft || !profile.critique).toList();
    if (hard.isNotEmpty) {
      rejections.add(c.rejection(hard.first.name));
      return false;
    }
    c.problems.addAll(failures);
    return true;
  }

  Future<void> _blindCheck(
    PassageInput passage,
    List<_Candidate> candidates,
    int run,
  ) async {
    for (final start in _starts(candidates.length, _batch)) {
      final batch = candidates.sublist(
        start,
        math.min(start + _batch, candidates.length),
      );
      final shuffled = [for (final c in batch) c.shuffled(run)];
      final json = await model.json(
        stage: 'blind',
        messages: blindMessages(
          headingPath: passage.headingPath,
          text: passage.text,
          language: passage.language,
          items: [
            for (final (i, c) in batch.indexed)
              BlindItem(question: c.question, options: shuffled[i].$1),
          ],
        ),
        schema: blindSchema(batch.length),
        maxTokens: 40 + batch.length * 30,
        temperature: 0,
      );
      final choices = <int, String>{
        for (final raw in _list(json['answers']))
          ((_map(raw)['question'] as num?)?.toInt() ?? 0):
              '${_map(raw)['choice']}',
      };
      for (final (i, c) in batch.indexed) {
        final (options, correct) = shuffled[i];
        final choice = optionLetters.indexOf(choices[i + 1] ?? '');
        if (choice == correct) {
          c.blindPasses++;
        } else {
          c.problems.add(CheckFailure.blindMismatch);
          c.blindChoice = choice >= 0 ? options[choice] : null;
        }
      }
    }
  }

  Future<List<_Candidate>> _critique(
    PassageInput passage,
    List<FactInput> facts,
    List<_Candidate> candidates,
    Iterable<String> existingQuestions,
    List<RejectionDraft> rejections,
  ) async {
    final accepted = <_Candidate>[];
    final rewritten = <_Candidate>[];
    for (final start in _starts(candidates.length, _batch)) {
      final batch = candidates.sublist(
        start,
        math.min(start + _batch, candidates.length),
      );
      final json = await model.json(
        stage: 'critique',
        messages: critiqueMessages(
          headingPath: passage.headingPath,
          text: passage.text,
          language: passage.language,
          items: [for (final c in batch) c.critiqueItem()],
        ),
        schema: critiqueSchema(batch.length),
        maxTokens: 60 + batch.length * 200,
        temperature: 0.2,
      );
      final reviews = <int, Map<String, Object?>>{
        for (final raw in _list(json['reviews']))
          ((_map(raw)['question'] as num?)?.toInt() ?? 0): _map(raw),
      };
      for (final (i, c) in batch.indexed) {
        final review = reviews[i + 1];
        final ok = review?['ok'] == true;
        if (ok && c.problems.isEmpty) {
          c.critique = 'ok';
          accepted.add(c);
          continue;
        }
        final fixed = review == null ? null : c.fixedFrom(review);
        if (fixed == null) {
          rejections.add(
            c.rejection(
              c.problems.isNotEmpty
                  ? c.problems.first.name
                  : CheckFailure.critiqueRejected.name,
            ),
          );
          continue;
        }
        final fact = facts[fixed.factIndex];
        final failures = checkMcq(
          question: fixed.question,
          answer: fixed.answer,
          distractors: fixed.distractors,
          quote: fact.quote,
          statement: fact.statement,
          passage: passage.text,
          language: passage.language,
          requireGrounding:
              fixed.depth == Depth.recall || fixed.depth == Depth.understand,
          otherQuestions: existingQuestions,
        );
        if (failures.isNotEmpty) {
          rejections.add(fixed.rejection(failures.first.name));
        } else {
          rewritten.add(fixed);
        }
      }
    }
    // A rewrite must pass the blind check again.
    if (rewritten.isNotEmpty && profile.blindRuns > 0) {
      await _blindCheck(passage, rewritten, 7);
    }
    for (final c in rewritten) {
      if (c.problems.isEmpty) {
        accepted.add(c);
      } else {
        rejections.add(c.rejection(c.problems.first.name));
      }
    }
    return accepted;
  }

  static Iterable<int> _starts(int length, int size) sync* {
    for (var i = 0; i < length; i += size) {
      yield i;
    }
  }

  static double _overlap(int aStart, int aEnd, int bStart, int bEnd) {
    final overlap = math.min(aEnd, bEnd) - math.max(aStart, bStart);
    if (overlap <= 0) return 0;
    return overlap / math.min(aEnd - aStart, bEnd - bStart);
  }

  static List<Object?> _list(Object? value) => value is List ? value : const [];

  static Map<String, Object?> _map(Object? value) =>
      value is Map ? Map<String, Object?>.from(value) : const {};
}

class _Candidate {
  _Candidate({
    required this.factIndex,
    required this.depth,
    required this.question,
    required this.answer,
    required this.distractors,
    required this.explanation,
    required this.notes,
    this.rewritten = false,
  });

  final int factIndex;
  final Depth depth;
  final String question;
  final String answer;
  final List<String> distractors;
  final String explanation;
  final List<String> notes;
  final bool rewritten;

  final List<CheckFailure> problems = [];
  int blindPasses = 0;
  String? blindChoice;
  String? critique;

  /// Options in a shuffled order that is stable per question and run, and
  /// the index of the correct one.
  (List<String>, int) shuffled(int run) {
    final options = [answer, ...distractors];
    final random = math.Random(_fnv1a('$question|$run'));
    final order = List<int>.generate(options.length, (i) => i)..shuffle(random);
    return ([for (final i in order) options[i]], order.indexOf(0));
  }

  CritiqueItem critiqueItem() => CritiqueItem(
    question: question,
    answer: answer,
    distractors: distractors,
    knownProblem: problems.isEmpty
        ? null
        : [
            for (final p in problems)
              p == CheckFailure.blindMismatch && blindChoice != null
                  ? 'A careful reader chose "$blindChoice" instead.'
                  : p.description,
          ].join(' '),
  );

  _Candidate? fixedFrom(Map<String, Object?> review) {
    final q = '${review['fixed_question'] ?? ''}'.trim();
    final a = '${review['fixed_answer'] ?? ''}'.trim();
    final d = [
      for (final x in (review['fixed_distractors'] as List? ?? const []))
        '$x'.trim(),
    ];
    if (q.isEmpty || a.isEmpty || d.length != 3) return null;
    return _Candidate(
      factIndex: factIndex,
      depth: depth,
      question: q,
      answer: a,
      distractors: d,
      explanation: '${review['fixed_explanation'] ?? explanation}'.trim(),
      notes: const [],
      rewritten: true,
    )..critique = 'rewritten';
  }

  double get score {
    final mean = distractors.isEmpty
        ? 1.0
        : distractors.fold<int>(0, (n, d) => n + d.length) / distractors.length;
    final balance = (answer.length - mean).abs() / math.max(mean, 1);
    return blindPasses * 2 -
        problems.length * 3 -
        (rewritten ? 0.5 : 0) -
        balance;
  }

  RejectionDraft rejection(String reason) => RejectionDraft('mcq', reason, {
    'question': question,
    'answer': answer,
    'distractors': distractors,
    if (blindChoice != null) 'blind_choice': blindChoice,
    if (rewritten) 'rewritten': true,
  });

  QuestionDraft toDraft(GenerationProfile profile) => QuestionDraft(
    factIndex: factIndex,
    type: QuestionType.mcq,
    depth: depth,
    prompt: question,
    answer: answer,
    distractors: distractors,
    explanation: explanation.isEmpty ? null : explanation,
    distractorNotes: notes.length == 3 ? notes : const [],
    checks: {
      'blind': blindPasses,
      'critique': ?critique,
      'candidates': profile.candidatesPerFact,
    },
  );

  static int _fnv1a(String text) {
    var hash = 0x811C9DC5;
    for (final unit in text.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}
