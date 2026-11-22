import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/llm/llm_engine.dart';
import '../background/background_tasks.dart';
import '../generate/generate_controllers.dart';
import 'model_controllers.dart';

/// Runs model work the user is waiting for: a chat answer, a web search, a
/// fact check, a model test.
///
/// Background generation steps aside first (its current step is cancelled
/// and retried later), then the right model is loaded: a conversation's,
/// a document's or the app default. Generation resumes afterwards and loads
/// its own model again if it differs. The work is registered as a
/// background task, so it goes on if the user leaves the app.
class ModelUse {
  ModelUse(this._ref);

  final Ref _ref;

  Future<T> run<T>({
    required String title,
    String? detail,
    int? documentId,
    int? threadId,
    String? modelPath,
    required Future<T> Function(LlmEngine engine) body,
  }) {
    return exclusive(title, detail: detail, () async {
      final path =
          modelPath ??
          await _ref
              .read(modelResolverProvider)
              .pathFor(documentId: documentId, threadId: threadId);
      final models = _ref.read(activeModelProvider.notifier);
      if (path == null || !await models.ensureLoaded(path: path)) {
        throw LlmException(
          _ref.read(activeModelProvider).error ??
              'Set up an AI model first (Settings → AI models).',
        );
      }
      return body(_ref.read(llmEngineProvider));
    });
  }

  /// Runs [body] as a background task with the model to itself: generation
  /// steps aside first and resumes afterwards. [body] loads whatever it needs.
  Future<T> exclusive<T>(
    String title,
    Future<T> Function() body, {
    String? detail,
  }) {
    return _ref.read(backgroundTasksProvider.notifier).run(title, () async {
      final runner = _ref.read(generationRunnerProvider);
      // isActive also covers a runner that is still loading its model.
      final yielded = runner.isActive && !runner.state.paused;
      if (yielded) {
        runner.pause();
        _ref.read(llmEngineProvider).cancel();
        await runner.idle();
      }
      try {
        return await body();
      } finally {
        if (yielded) runner.resume();
      }
    }, detail: detail);
  }
}

final modelUseProvider = Provider<ModelUse>(ModelUse.new);
