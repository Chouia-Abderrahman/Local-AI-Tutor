import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/generate/chunk_generator.dart';
import 'package:pdf_study_assistant/core/generate/generation_repository.dart';
import 'package:pdf_study_assistant/core/generate/json_model.dart';
import 'package:pdf_study_assistant/core/generate/power_policy.dart';
import 'package:pdf_study_assistant/core/generate/profile.dart';
import 'package:pdf_study_assistant/core/generate/runner.dart';
import 'package:pdf_study_assistant/core/ingest/importer.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';

/// Writes plausible output for any passage: facts from its first sentences,
/// one question per fact, and correct blind answers.
class _FakeTeacher implements JsonModel {
  _FakeTeacher({this.name = 'fake-teacher'});

  final String name;
  final List<String> stages = [];
  final Map<String, String> _answers = {};
  bool failFacts = false;
  void Function(String stage)? onCall;
  void Function(String text)? onText;

  @override
  String get modelName => name;

  @override
  Future<Map<String, Object?>> json({
    required String stage,
    required List<LlmMessage> messages,
    required Map<String, Object?> schema,
    required int maxTokens,
    double temperature = 0.2,
  }) async {
    stages.add(stage);
    onCall?.call(stage);
    final text = messages.last.text;
    onText?.call(text);
    switch (stage) {
      case 'facts':
        if (failFacts) throw LlmException('model crashed');
        final passage = RegExp(
          r'<<<\n([\s\S]*?)\n>>>',
        ).firstMatch(text)!.group(1)!;
        final sentences = passage
            .split(RegExp(r'(?<=\.)\s+'))
            .where((s) => s.split(' ').length > 4)
            .take(2);
        return {
          'facts': [
            for (final s in sentences)
              {
                'quote': s,
                'statement': s,
                'key_term': _longestWord(s),
                'importance': 2,
                'front': 'Name the key term of this idea.',
                'back': _longestWord(s),
              },
          ],
        };
      case 'mcq':
        final facts = RegExp(
          r'^(\d+)\. \[\w+\] (.+?) \(source:(?:.*)\)(?:\n {3}Already asked, so ask something different: (.*))?$',
          multiLine: true,
        ).allMatches(text);
        return {
          'questions': [
            for (final f in facts)
              () {
                // A fact that already has questions gets a new one about
                // another word of its sentence.
                final asked = f.group(3) == null
                    ? 0
                    : f.group(3)!.split('"; "').length;
                final words =
                    (f
                        .group(2)!
                        .replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '')
                        .split(RegExp(r'\s+'))
                        .toSet()
                        .toList()
                      ..sort((a, b) {
                        final byLength = b.length.compareTo(a.length);
                        return byLength != 0 ? byLength : a.compareTo(b);
                      }));
                final answer = asked == 0
                    ? _longestWord(f.group(2)!)
                    : words[asked % words.length];
                final question = asked == 0
                    ? 'Which term matters most in idea ${f.group(1)} of ${text.hashCode}?'
                    : 'Round $asked: ${List.generate(6, (i) => 'w${((text.hashCode.abs() + int.parse(f.group(1)!) * 131) * (i + 3)) % 9973}').join(' ')} name another key word?';
                _answers[question] = answer;
                return {
                  'fact': int.parse(f.group(1)!),
                  'question': question,
                  'answer': answer,
                  'distractors': ['alpha', 'beta', 'gamma'],
                  'explanation': 'It is in the passage.',
                };
              }(),
          ],
        };
      case 'flashcards':
        final facts = RegExp(
          r'^(\d+)\. (.+?) \(source:',
          multiLine: true,
        ).allMatches(text);
        return {
          'cards': [
            for (final f in facts)
              {
                'fact': int.parse(f.group(1)!),
                'front':
                    'From another angle, what is idea ${f.group(1)} of ${text.hashCode}?',
                'back': _longestWord(f.group(2)!),
              },
          ],
        };
      case 'blanks':
        final facts = RegExp(
          r'^(\d+)\. .+? \(source: "(.+?)"\)(?:\n.*?: (.*))?$',
          multiLine: true,
        ).allMatches(text);
        return {
          'terms': [
            for (final f in facts)
              {
                'fact': int.parse(f.group(1)!),
                // The longest word of the sentence not blanked yet.
                'term':
                    (f
                            .group(2)!
                            .replaceAll(
                              RegExp(r'[^\p{L}\s]', unicode: true),
                              '',
                            )
                            .split(RegExp(r'\s+'))
                            .toSet()
                            .where((w) => !(f.group(3) ?? '').contains('"$w"'))
                            .toList()
                          ..sort((a, b) => b.length.compareTo(a.length)))
                        .first,
              },
          ],
        };
      case 'blind':
        final blocks = RegExp(
          r'^(\d+)\. (.+)\nA\) (.+)\nB\) (.+)\nC\) (.+)\nD\) (.+)$',
          multiLine: true,
        ).allMatches(text);
        return {
          'answers': [
            for (final b in blocks)
              {
                'question': int.parse(b.group(1)!),
                'choice':
                    'ABCD'[[
                      for (var i = 3; i <= 6; i++) b.group(i),
                    ].indexOf(_answers[b.group(2)])],
              },
          ],
        };
    }
    throw StateError(stage);
  }

  static String _longestWord(String s) =>
      (s
              .replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '')
              .split(RegExp(r'\s+'))
            ..sort((a, b) => b.length.compareTo(a.length)))
          .first;
}

/// Reports item status changes, to act at exact points of the work loop.
class _HookedRepository extends GenerationRepository {
  _HookedRepository(super.db);

  void Function(String status)? onStatus;

  @override
  Future<void> setItemStatus(
    int itemId,
    String status, {
    String? error,
    bool countAttempt = false,
  }) async {
    await super.setItemStatus(
      itemId,
      status,
      error: error,
      countAttempt: countAttempt,
    );
    onStatus?.call(status);
  }
}

void main() {
  late AppDatabase db;
  late Directory storage;
  late GenerationRepository repo;
  late _FakeTeacher teacher;
  late int documentId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = Directory.systemTemp.createTempSync('runner');
    repo = GenerationRepository(db);
    teacher = _FakeTeacher();
    final notes = File('${storage.path}/notes.md')
      ..writeAsStringSync(
        '# Cells\n\nOsmosis moves water across selectively permeable membranes. '
        'Hypotonic solutions make animal cells swell and sometimes burst.\n\n'
        '# Energy\n\nMitochondria produce most of the ATP in eukaryotic cells. '
        'Glycolysis splits glucose into two pyruvate molecules.\n',
      );
    final result = await DocumentImporter(
      db: db,
      storageDir: storage,
      extractPdf: (path, {required title, onProgress}) =>
          throw UnimplementedError(),
    ).importFile(notes.path);
    documentId = result.documentId;
  });

  tearDown(() async {
    await db.close();
    storage.deleteSync(recursive: true);
  });

  GenerationRunner runner(JsonModel model) =>
      GenerationRunner(repo: repo, prepareModel: (_) async => model);

  test('Standard: facts for every passage first, then questions', () async {
    final r = runner(CachedJsonModel(teacher, db));
    final jobId = await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.standard),
    );
    await r.idle();

    expect(teacher.stages, ['facts', 'facts', 'mcq', 'blind', 'mcq', 'blind']);
    final facts = await db.select(db.facts).get();
    expect(facts, hasLength(4));
    final questions = await db.select(db.questions).get();
    final types = questions.map((q) => q.type).toList();
    expect(types.where((t) => t == 'mcq'), hasLength(4));
    expect(types.where((t) => t == 'cloze'), hasLength(4));
    expect(types.where((t) => t == 'flashcard'), hasLength(4));
    expect(questions.every((q) => q.modelId == 'fake-teacher'), isTrue);

    final summary = (await repo.summary(jobId!))!;
    expect(summary.job.status, 'done');
    expect(summary.done, summary.total);
    // Live queries (the progress card) see the job finish.
    expect(await repo.watchOpenJobs(documentId).first, isEmpty);
    final counts = await repo.countsBySection(documentId);
    expect(counts.values.map((c) => c.mcq), [2, 2]);
  });

  group('generate more', () {
    Future<void> generateAll(JsonModel model) async {
      final r = runner(model);
      await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.standard),
      );
      await r.idle();
      teacher.stages.clear();
    }

    Future<List<Question>> active(String type) => (db.select(
      db.questions,
    )..where((q) => q.type.equals(type) & q.status.equals('active'))).get();

    test('only multiple choice: old questions stay, new ones differ', () async {
      final model = CachedJsonModel(teacher, db);
      await generateAll(model);
      final before = await active('mcq');
      expect(before, hasLength(4));

      final r = runner(model);
      final jobId = await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.standard),
        more: MoreKind.mcq,
      );
      await r.idle();

      // Only multiple-choice work: no facts, flashcards or blanks.
      expect(teacher.stages.toSet(), {'mcq', 'blind'});
      final after = await active('mcq');
      expect(after, hasLength(8));
      expect(
        before.every((q) => after.any((a) => a.id == q.id)),
        isTrue,
        reason: 'the old questions are still active',
      );
      expect(after.map((q) => q.prompt).toSet(), hasLength(8));
      expect(await active('cloze'), hasLength(4));
      expect(await active('flashcard'), hasLength(4));
      expect((await repo.summary(jobId!))!.job.status, 'done');
    });

    test('a second request adds again, to all facts', () async {
      final model = CachedJsonModel(teacher, db);
      await generateAll(model);
      for (var i = 0; i < 2; i++) {
        final r = runner(model);
        await r.start(
          documentId: documentId,
          profile: GenerationProfile.preset(Quality.standard),
          more: MoreKind.mcq,
        );
        await r.idle();
      }
      expect(await active('mcq'), hasLength(12));
    });

    test('the model is told what each fact already has', () async {
      final model = CachedJsonModel(teacher, db);
      await generateAll(model);
      final prompts = <String>[];
      teacher.onText = prompts.add;
      final r = runner(model);
      await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.standard),
        more: MoreKind.mcq,
      );
      await r.idle();
      final asked = prompts.where((t) => t.contains('Already asked'));
      expect(asked, isNotEmpty);
      final first = (await active('mcq')).first.prompt;
      expect(asked.any((t) => t.contains(first)), isTrue);
    });

    test('flashcards and blanks add cards of just that kind', () async {
      final model = CachedJsonModel(teacher, db);
      await generateAll(model);
      final r = runner(model);
      await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.quick),
        more: MoreKind.flashcard,
        perFact: 1,
      );
      await r.idle();
      expect(teacher.stages.toSet(), {'flashcards'});
      expect(await active('flashcard'), hasLength(8));
      expect(await active('mcq'), hasLength(4));
      expect(await active('cloze'), hasLength(4));

      teacher.stages.clear();
      await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.quick),
        more: MoreKind.cloze,
      );
      await r.idle();
      expect(teacher.stages.toSet(), {'blanks'});
      final clozes = await active('cloze');
      expect(clozes, hasLength(8));
      // Each fact's blanks are different words.
      for (final fact in await db.select(db.facts).get()) {
        final answers = clozes
            .where((q) => q.factId == fact.id)
            .map((q) => q.answer)
            .toList();
        expect(answers.toSet(), hasLength(2));
      }
    });

    test('nothing to add to before facts exist', () async {
      final r = runner(teacher);
      final jobId = await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.standard),
        more: MoreKind.mcq,
      );
      expect(jobId, isNull);
    });
  });

  test('an interrupted item is resumed after a restart', () async {
    final jobId = await repo.createJob(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.quick),
    );
    // Simulate an app killed in the middle of an item.
    await (db.update(db.jobItems)..where((i) => i.jobId.equals(jobId!))).write(
      const JobItemsCompanion(status: Value('running')),
    );
    final r = runner(teacher);
    await r.resumePending();
    await r.idle();
    expect((await repo.summary(jobId!))!.job.status, 'done');
    expect(await db.select(db.facts).get(), hasLength(4));
  });

  test('a failing item is retried, then marked failed', () async {
    teacher.failFacts = true;
    final r = runner(teacher);
    final jobId = await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.quick),
    );
    await r.idle();
    final summary = (await repo.summary(jobId!))!;
    expect(summary.failed, 2);
    expect(summary.job.status, 'done');
    final items = await db.select(db.jobItems).get();
    expect(items.every((i) => i.attempts == 2 && i.error != null), isTrue);
  });

  test('re-running a stage reuses cached model output', () async {
    final cached = CachedJsonModel(teacher, db);
    final first = runner(cached);
    await first.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.quick),
    );
    await first.idle();
    expect(teacher.stages, ['facts', 'facts']);
    // Facts deleted (for example by a model change), then generated again.
    await db.delete(db.facts).go();
    final r = runner(cached);
    await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.quick),
    );
    await r.idle();
    expect(teacher.stages, ['facts', 'facts'], reason: 'no new model calls');
    expect(cached.hits, 2);
    expect(await db.select(db.facts).get(), hasLength(4));
  });

  test('no model: the runner waits with a message', () async {
    final r = GenerationRunner(repo: repo, prepareModel: (_) async => null);
    await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.quick),
    );
    await r.idle();
    expect(r.state.message, contains('Load an AI model'));
    expect(await repo.hasQueuedWork(), isTrue);
  });

  test(
    'pausing mid-item (for the chat) stops at the next model call',
    () async {
      final cached = CachedJsonModel(teacher, db);
      final r = runner(cached);
      var paused = false;
      teacher.onCall = (stage) {
        if (stage == 'mcq' && !paused) {
          paused = true;
          r.pause(); // The chat takes the model while the mcq call runs.
        }
      };
      final jobId = await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.standard),
      );
      await r.idle();
      // Stopped before the blind call; the item went back to the queue.
      expect(teacher.stages, ['facts', 'facts', 'mcq']);
      expect((await repo.summary(jobId!))!.remaining, 2);

      r.resume();
      await r.idle();
      // The finished mcq call came from the cache; the rest ran normally.
      expect(teacher.stages, [
        'facts',
        'facts',
        'mcq',
        'blind',
        'mcq',
        'blind',
      ]);
      expect((await repo.summary(jobId))!.job.status, 'done');
      expect(cached.hits, 1);
    },
  );

  test('each document is generated with its own model', () async {
    final energy = File('${storage.path}/energy.md')
      ..writeAsStringSync(
        '# Plants\n\nPhotosynthesis turns light energy into chemical energy '
        'in plants. Chlorophyll absorbs mostly red and blue light.\n',
      );
    final second = (await DocumentImporter(
      db: db,
      storageDir: storage,
      extractPdf: (path, {required title, onProgress}) =>
          throw UnimplementedError(),
    ).importFile(energy.path)).documentId;
    final other = _FakeTeacher(name: 'other-model');
    final asked = <int>{};
    final r = GenerationRunner(
      repo: repo,
      prepareModel: (document) async {
        asked.add(document);
        return document == second ? other : teacher;
      },
    );
    await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.quick),
    );
    await r.start(
      documentId: second,
      profile: GenerationProfile.preset(Quality.quick),
    );
    await r.idle();

    expect(asked, {documentId, second});
    final documentOfFact = {
      for (final f in await db.select(db.facts).get()) f.id: f.documentId,
    };
    final questions = await db.select(db.questions).get();
    expect(questions.map((q) => q.modelId).toSet(), {
      'fake-teacher',
      'other-model',
    });
    for (final q in questions) {
      expect(
        q.modelId,
        documentOfFact[q.factId] == second ? 'other-model' : 'fake-teacher',
      );
    }
  });

  test('time left is estimated before the questions stage has run', () async {
    final r = runner(teacher);
    final states = <RunnerState>[];
    final subscription = r.states.listen(states.add);
    await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.standard),
    );
    await r.idle();
    await subscription.cancel();
    final working = states.where((s) => s.working).toList();
    // Nothing to go on for the very first passage...
    expect(working.first.stage, Stage.facts);
    expect(working.first.secondsLeft, isNull);
    // ...but the questions stage is guessed from the facts stage.
    final firstQuestions = working.firstWhere(
      (s) => s.stage == Stage.questions,
    );
    expect(firstQuestions.secondsLeft, isNotNull);
  });

  test('resuming before the paused call ends shows the work again', () async {
    final r = runner(teacher);
    final states = <RunnerState>[];
    final subscription = r.states.listen(states.add);
    var toggled = false;
    teacher.onCall = (stage) {
      if (stage == 'mcq' && !toggled) {
        toggled = true;
        r.pause(reason: 'Paused to save battery (15%).');
        r.resume(); // Plugged in while the call still runs.
      }
    };
    final jobId = await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.standard),
    );
    await r.idle();
    await subscription.cancel();
    expect((await repo.summary(jobId!))!.job.status, 'done');
    // Nothing was cancelled.
    expect(teacher.stages, ['facts', 'facts', 'mcq', 'blind', 'mcq', 'blind']);
    final paused = states.indexWhere((s) => s.paused);
    expect(states[paused + 1].working, isTrue);
    expect(states[paused + 1].message, isNull);
  });

  test('a resume while the loop is stopping starts it again', () async {
    final hooked = _HookedRepository(db);
    final r = GenerationRunner(
      repo: hooked,
      prepareModel: (_) async => teacher,
    );
    var paused = false;
    teacher.onCall = (stage) {
      if (stage == 'mcq' && !paused) {
        paused = true;
        r.pause();
      }
    };
    hooked.onStatus = (status) {
      // The cancelled item went back to the queue: the loop is on its way
      // out when the resume arrives.
      if (status == 'queued' && paused) {
        hooked.onStatus = null;
        r.resume();
      }
    };
    final jobId = await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.standard),
    );
    await r.idle();
    expect((await hooked.summary(jobId!))!.job.status, 'done');
  });

  test('steps with nothing to do are left out of the estimate', () async {
    final quick = runner(teacher);
    await quick.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.quick),
    );
    await quick.idle();

    // Standard reuses the facts, so its facts steps finish at once. A fresh
    // runner has no timings, and those instant steps mustn't become one.
    final r = runner(teacher);
    final states = <RunnerState>[];
    final subscription = r.states.listen(states.add);
    await r.start(
      documentId: documentId,
      profile: GenerationProfile.preset(Quality.standard),
    );
    await r.idle();
    await subscription.cancel();
    final firstQuestions = states.firstWhere(
      (s) => s.working && s.stage == Stage.questions,
    );
    expect(firstQuestions.secondsLeft, isNull);
  });

  group('battery', () {
    late BatteryReading battery;
    late GenerationRunner r;
    late PowerPolicy policy;

    setUp(() {
      battery = (level: 15, charging: false);
      r = runner(teacher);
      policy = PowerPolicy(runner: r, readBattery: () async => battery);
    });

    tearDown(() => policy.dispose());

    test('low battery pauses with a reason; plugging in resumes', () async {
      policy.start(every: const Duration(hours: 1));
      final jobId = await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.quick),
      );
      await r.idle();
      expect(r.state.paused, isTrue);
      expect(r.state.message, contains('battery (15%)'));
      expect(await repo.hasQueuedWork(), isTrue);

      battery = (level: 15, charging: true);
      await policy.check();
      await r.idle();
      expect(r.state.paused, isFalse);
      expect(r.state.message, isNull);
      expect((await repo.summary(jobId!))!.job.status, 'done');
    });

    test('a hand resume stands; plugging in keeps a hand pause', () async {
      Future<void>? checking;
      teacher.onCall = (_) => checking = policy.check();
      final jobId = await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.quick),
      );
      await r.idle();
      await checking;
      expect(r.state.message, contains('battery'));
      expect((await repo.summary(jobId!))!.remaining, 1);

      // The user resumes anyway: the next check leaves the work running.
      r.resume();
      await r.idle();
      await checking;
      expect((await repo.summary(jobId))!.job.status, 'done');

      // A pause by hand isn't undone by plugging in.
      teacher.onCall = null;
      r.pause();
      battery = (level: 15, charging: true);
      await policy.check();
      expect(r.state.paused, isTrue);
    });

    test('nothing happens when the phone is charging', () async {
      battery = (level: 5, charging: true);
      policy.start(every: const Duration(hours: 1));
      final jobId = await r.start(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.quick),
      );
      await r.idle();
      expect((await repo.summary(jobId!))!.job.status, 'done');
    });
  });
}
