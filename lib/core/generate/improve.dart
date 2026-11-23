import 'dart:convert';
import 'dart:math' as math;

import '../db/database.dart';
import '../text/matching.dart';
import 'checks.dart';
import 'chunk_generator.dart';
import 'cloze.dart';
import 'json_model.dart';
import 'profile.dart';
import 'prompts.dart';

/// A rewritten question, ready to replace the one it came from.
class QuestionRewrite {
  const QuestionRewrite({
    required this.prompt,
    required this.answer,
    this.distractors = const [],
    this.explanation,
  });

  final String prompt;
  final String answer;
  final List<String> distractors;
  final String? explanation;
}

/// No acceptable rewrite came out; [message] says why, in plain words.
class ImproveFailure implements Exception {
  const ImproveFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Rewrites one question the learner found bad, from the same source
/// sentence and passage. The rewrite goes through the same code checks as
/// generated questions, and a multiple-choice rewrite must also be answered
/// the same way by the model reading the passage blind; otherwise it tries
/// once more at a higher temperature, then gives up rather than offering
/// something worse.
class QuestionImprover {
  QuestionImprover(this.model);

  final JsonModel model;

  static const _attempts = 2;

  /// Feedback saying the marked answer itself is wrong.
  static final _answerWrong = RegExp(
    r'(answer|key|back).{0,30}(wrong|incorrect|not right|mistake)|'
    r'(wrong|incorrect|bad).{0,15}(answer|key)',
    caseSensitive: false,
  );

  /// [otherQuestions] are the text of the document's other multiple-choice
  /// questions, so the rewrite doesn't copy one of them.
  Future<QuestionRewrite> improve({
    required Question question,
    required Fact fact,
    required PassageInput passage,
    String? feedback,
    Iterable<String> otherQuestions = const [],
  }) {
    var note = feedback?.trim();
    final answerWrong =
        note != null && _answerWrong.hasMatch(note) && question.type != 'cloze';
    if (answerWrong) {
      note = '$note (So the new answer must be different from the marked one.)';
    }
    return switch (question.type) {
      'mcq' => _mcq(
        question,
        fact,
        passage,
        note,
        otherQuestions,
        mustChangeAnswer: answerWrong,
      ),
      'flashcard' => _flashcard(
        question,
        fact,
        passage,
        note,
        mustChangeAnswer: answerWrong,
      ),
      _ => _cloze(question, fact, passage, note),
    };
  }

  double _temperature(int attempt) => 0.4 + attempt * 0.25;

  Future<QuestionRewrite> _mcq(
    Question old,
    Fact fact,
    PassageInput passage,
    String? feedback,
    Iterable<String> otherQuestions, {
    bool mustChangeAnswer = false,
  }) async {
    final oldDistractors = old.distractorsJson == null
        ? const <String>[]
        : [for (final d in jsonDecode(old.distractorsJson!) as List) '$d'];
    final depth = Depth.values.byName(old.depth);
    var reason = 'It came out the same as before.';
    for (var attempt = 0; attempt < _attempts; attempt++) {
      final json = await model.json(
        stage: 'improve',
        messages: improveMcqMessages(
          headingPath: passage.headingPath,
          text: passage.text,
          language: passage.language,
          quote: fact.quote,
          question: old.prompt,
          answer: old.answer,
          distractors: oldDistractors,
          feedback: feedback,
        ),
        schema: improveMcqSchema(),
        maxTokens: 360,
        temperature: _temperature(attempt),
      );
      final question = '${json['question'] ?? ''}'.trim();
      final answer = '${json['answer'] ?? ''}'.trim();
      final distractors = [
        for (final d in (json['distractors'] as List? ?? const [])) '$d'.trim(),
      ];
      final explanation = '${json['explanation'] ?? ''}'.trim();

      final failures = checkMcq(
        question: question,
        answer: answer,
        distractors: distractors,
        quote: fact.quote,
        statement: fact.statement,
        passage: passage.text,
        language: passage.language,
        requireGrounding: depth == Depth.recall || depth == Depth.understand,
        otherQuestions: otherQuestions,
      );
      if (failures.isNotEmpty) {
        reason = failures.first.description;
        continue;
      }
      if (mustChangeAnswer &&
          normalizeForMatch(answer) == normalizeForMatch(old.answer)) {
        reason = 'It kept the answer you said was wrong.';
        continue;
      }
      if (similarity('$question $answer', '${old.prompt} ${old.answer}') >=
              0.95 &&
          _sameSet(distractors, oldDistractors)) {
        continue;
      }
      if (!await _blindAgrees(passage, question, answer, distractors)) {
        reason = CheckFailure.blindMismatch.description;
        continue;
      }
      return QuestionRewrite(
        prompt: question,
        answer: answer,
        distractors: distractors,
        explanation: explanation.isEmpty ? null : explanation,
      );
    }
    throw ImproveFailure(
      'No better version came out. $reason Describe what is wrong and try '
      'again.',
    );
  }

  /// The model, reading the passage with the options shuffled and the key
  /// hidden, picks the one marked correct.
  Future<bool> _blindAgrees(
    PassageInput passage,
    String question,
    String answer,
    List<String> distractors,
  ) async {
    final options = [answer, ...distractors];
    final order = List<int>.generate(options.length, (i) => i)
      ..shuffle(math.Random(question.hashCode));
    final shuffled = [for (final i in order) options[i]];
    final json = await model.json(
      stage: 'blind',
      messages: blindMessages(
        headingPath: passage.headingPath,
        text: passage.text,
        language: passage.language,
        items: [BlindItem(question: question, options: shuffled)],
      ),
      schema: blindSchema(1),
      maxTokens: 70,
      temperature: 0,
    );
    final first = (json['answers'] as List? ?? const []).firstOrNull;
    final choice = first is Map ? '${first['choice']}' : '';
    return optionLetters.indexOf(choice) == order.indexOf(0);
  }

  Future<QuestionRewrite> _flashcard(
    Question old,
    Fact fact,
    PassageInput passage,
    String? feedback, {
    bool mustChangeAnswer = false,
  }) async {
    var reason = 'It came out the same as before.';
    for (var attempt = 0; attempt < _attempts; attempt++) {
      final json = await model.json(
        stage: 'improve',
        messages: improveFlashcardMessages(
          headingPath: passage.headingPath,
          text: passage.text,
          language: passage.language,
          quote: fact.quote,
          front: old.prompt,
          back: old.answer,
          feedback: feedback,
        ),
        schema: improveFlashcardSchema(),
        maxTokens: 160,
        temperature: _temperature(attempt),
      );
      final front = '${json['front'] ?? ''}'.trim();
      final back = '${json['back'] ?? ''}'.trim();
      final failures = checkFlashcard(
        front: front,
        back: back,
        quote: fact.quote,
        statement: fact.statement,
      );
      if (failures.isNotEmpty) {
        reason = failures.first.description;
        continue;
      }
      if (mustChangeAnswer &&
          normalizeForMatch(back) == normalizeForMatch(old.answer)) {
        reason = 'It kept the answer you said was wrong.';
        continue;
      }
      if (similarity('$front $back', '${old.prompt} ${old.answer}') >= 0.95) {
        continue;
      }
      return QuestionRewrite(prompt: front, answer: back);
    }
    throw ImproveFailure(
      'No better version came out. $reason Describe what is wrong and try '
      'again.',
    );
  }

  Future<QuestionRewrite> _cloze(
    Question old,
    Fact fact,
    PassageInput passage,
    String? feedback,
  ) async {
    var reason = 'It chose the same word again.';
    for (var attempt = 0; attempt < _attempts; attempt++) {
      final json = await model.json(
        stage: 'improve',
        messages: improveBlankMessages(
          headingPath: passage.headingPath,
          text: passage.text,
          language: passage.language,
          quote: fact.quote,
          blanked: old.answer,
          feedback: feedback,
        ),
        schema: improveBlankSchema(),
        maxTokens: 60,
        temperature: _temperature(attempt),
      );
      final cloze = buildCloze(fact.quote, '${json['term'] ?? ''}');
      if (cloze == null) {
        reason = 'The word it chose can not be blanked out of the sentence.';
        continue;
      }
      if (normalizeForMatch(cloze.answer) == normalizeForMatch(old.answer)) {
        continue;
      }
      return QuestionRewrite(prompt: cloze.prompt, answer: cloze.answer);
    }
    throw ImproveFailure(
      'No better blank was found. $reason Describe what is wrong and try '
      'again.',
    );
  }

  static bool _sameSet(List<String> a, List<String> b) =>
      a.length == b.length &&
      a.map(normalizeForMatch).toSet().containsAll(b.map(normalizeForMatch));
}
