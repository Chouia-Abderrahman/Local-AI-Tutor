import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/app/providers.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/generate/runner.dart';
import 'package:pdf_study_assistant/core/llm/fake_llm_engine.dart';
import 'package:pdf_study_assistant/core/llm/installed_model.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';
import 'package:pdf_study_assistant/features/background/background_tasks.dart';
import 'package:pdf_study_assistant/features/background/keep_alive.dart';
import 'package:pdf_study_assistant/features/generate/generate_controllers.dart';
import 'package:pdf_study_assistant/features/model/model_controllers.dart';
import 'package:pdf_study_assistant/features/model/model_use.dart';

/// No downloads: catalog models are "absent".
class _NoDownloads extends ModelDownloads {
  _NoDownloads([this.initial = const {}]);

  final Map<String, DownloadStatus> initial;

  @override
  Map<String, DownloadStatus> build() => initial;

  void set(Map<String, DownloadStatus> downloads) => state = downloads;
}

void main() {
  test('copied-in files are told apart from downloads', () {
    const download = InstalledModel(
      path: '/models/Qwen3.5-0.8B-Q4_K_M.gguf',
      sizeBytes: 1,
    );
    const copied = InstalledModel(
      path: '/sideload/Qwen3.5-0.8B-Q4_K_M.gguf',
      sizeBytes: 1,
      copiedIn: true,
    );
    expect(download.name, copied.name);
    expect((download.copiedIn, copied.copiedIn), (false, true));
  });

  test('model files get readable names', () {
    expect(modelDisplayName('Qwen3.5-4B-Q4_K_M.gguf'), 'Qwen3.5 4B');
    expect(
      modelDisplayName('/x/sideload/gemma-3-1b-it-Q8_0.gguf'),
      'gemma 3 1b it',
    );
    expect(modelDisplayName('phi_mini.F16.gguf'), 'phi mini');
    expect(modelDisplayName('tiny.gguf'), 'tiny');
  });

  group('choosing models', () {
    late Directory dir;
    late String a, b, c;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('models');
      String file(String name) =>
          (File('${dir.path}/$name')..writeAsStringSync('gguf')).path;
      a = file('A-Q4_K_M.gguf');
      b = file('B-Q4_K_M.gguf');
      c = file('C-Q4_K_M.gguf');
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('conversation, then document, then app default', () {
      expect(resolveModel(conversation: a, document: b, appDefault: c).path, a);
      final document = resolveModel(document: b, appDefault: c);
      expect((document.path, document.origin), (b, ModelOrigin.document));
      final fallback = resolveModel(appDefault: c);
      expect((fallback.path, fallback.origin), (c, ModelOrigin.appDefault));
      // A deleted file falls back to the next choice.
      File(a).deleteSync();
      expect(resolveModel(conversation: a, document: b).path, b);
      expect(resolveModel().path, isNull);
    });

    test('an answer loads its conversation\'s model, then the '
        "document's, then the default", () async {
      final db = AppDatabase(NativeDatabase.memory());
      final engine = FakeLlmEngine();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          llmEngineProvider.overrideWithValue(engine as LlmEngine),
          modelDownloadsProvider.overrideWith(_NoDownloads.new),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      await db.setSetting(ActiveModel.settingKey, c);
      final doc = await db
          .into(db.documents)
          .insert(DocumentsCompanion.insert(title: 'Cells', sha256: 'x'));
      final thread = await db
          .into(db.chatThreads)
          .insert(ChatThreadsCompanion.insert(documentId: doc, title: 'Chat'));
      final use = container.read(modelUseProvider);
      Future<String?> modelFor() => use.run(
        title: 'test',
        documentId: doc,
        threadId: thread,
        body: (engine) async => engine.modelName,
      );

      expect(await modelFor(), 'C-Q4_K_M.gguf');
      await container.read(modelResolverProvider).setDocumentModel(doc, b);
      expect(await modelFor(), 'B-Q4_K_M.gguf');
      await container.read(modelResolverProvider).setThreadModel(thread, a);
      expect(await modelFor(), 'A-Q4_K_M.gguf');
      expect(container.read(activeModelProvider).loadedPath, a);
      // The default stays what Settings chose.
      expect(container.read(activeModelProvider).path, c);
      // Tasks are listed while they run, for the background service.
      expect(container.read(backgroundTasksProvider), isEmpty);
    });
  });

  test('the background notification names the most urgent work', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final runnerStates = StreamController<RunnerState>.broadcast();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        llmEngineProvider.overrideWithValue(FakeLlmEngine() as LlmEngine),
        modelDownloadsProvider.overrideWith(_NoDownloads.new),
        runnerStateProvider.overrideWith((ref) => runnerStates.stream),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await runnerStates.close();
      await db.close();
    });
    final seen = <BackgroundActivity?>[];
    container.listen(
      backgroundActivityProvider,
      (_, next) => seen.add(next),
      fireImmediately: true,
    );
    expect(seen.last, isNull);

    runnerStates.add(const RunnerState(working: true, done: 1, total: 4));
    await pumpEventQueue();
    expect(seen.last?.title, 'Generating questions');
    expect(seen.last?.text, '1 of 4 steps done');

    // An answer being written comes before generation.
    final answer = Completer<void>();
    final task = container
        .read(backgroundTasksProvider.notifier)
        .run('Writing an answer', () => answer.future, detail: 'Osmosis?');
    await pumpEventQueue();
    expect(seen.last?.title, 'Writing an answer');

    // A download comes before everything.
    final fake =
        container.read(modelDownloadsProvider.notifier) as _NoDownloads;
    fake.set({
      'qwen3.5-4b': const DownloadStatus(DownloadPhase.running, fraction: 0.45),
    });
    await pumpEventQueue();
    expect(seen.last?.title, 'Downloading Qwen3.5 4B');
    expect(seen.last?.text, startsWith('45% of'));
    // The notification carries a progress bar.
    expect(seen.last?.bar, isTrue);
    expect(seen.last?.percent, 45);

    // Without a length from the server, the catalog's file size stands in,
    // and the bytes received show.
    fake.set({
      'qwen3.5-4b': const DownloadStatus(
        DownloadPhase.running,
        receivedBytes: 1291610704,
      ),
    });
    await pumpEventQueue();
    expect(seen.last?.percent, 50);
    expect(seen.last?.text, startsWith('50% · '));

    fake.set(const {});
    answer.complete();
    await task;
    await pumpEventQueue();
    expect(seen.last?.title, 'Generating questions');

    runnerStates.add(const RunnerState());
    await pumpEventQueue();
    expect(seen.last, isNull);
  });
}
