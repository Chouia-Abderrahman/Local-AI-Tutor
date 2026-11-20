import 'dart:async';
import 'dart:convert';

import 'package:llamadart/llamadart.dart';
import 'package:path/path.dart' as p;

import '../util/serial_queue.dart';
import 'json_text.dart';
import 'llm_engine.dart';

/// [LlmEngine] backed by llama.cpp through the llamadart package.
///
/// llamadart runs inference on its own worker, so the UI stays responsive.
/// It allows one generation at a time, which [SerialQueue] enforces here.
class LlamadartEngine implements LlmEngine {
  LlamadartEngine() : _engine = LlamaEngine(LlamaBackend());

  final LlamaEngine _engine;
  final SerialQueue _queue = SerialQueue();

  String? _modelName;
  bool _loaded = false;
  _Request? _active;

  @override
  bool get isLoaded => _loaded;

  @override
  String? get modelName => _modelName;

  @override
  Future<void> load(
    String modelPath, {
    LlmLoadOptions options = const LlmLoadOptions(),
  }) {
    return _queue.run(() async {
      _loaded = false;
      _modelName = null;
      try {
        await _engine.setModel(
          LlamaModel(ModelSource.path(modelPath)),
          params: ModelParams(contextSize: options.contextSize),
        );
      } on LlamaException catch (error) {
        throw LlmException(
          'Could not load ${p.basename(modelPath)}: ${error.message}',
          error,
        );
      }
      _modelName = p.basename(modelPath);
      _loaded = true;
    });
  }

  @override
  Future<void> unload() {
    return _queue.run(() async {
      if (!_loaded) return;
      _loaded = false;
      _modelName = null;
      await _engine.unloadModel();
    });
  }

  @override
  Stream<LlmChunk> stream(
    List<LlmMessage> messages, {
    LlmParams params = const LlmParams(),
  }) {
    final request = _Request();
    final controller = StreamController<LlmChunk>();
    controller.onCancel = () {
      request.cancelled = true;
      if (identical(_active, request)) _engine.cancelGeneration();
    };

    unawaited(
      _queue.run(() async {
        try {
          if (request.cancelled) return;
          _requireLoaded();
          _active = request;
          LlamaCompletionChunk? last;
          await for (final chunk in _engine.create(
            _toLlama(messages),
            params: _toParams(params),
            enableThinking: false,
          )) {
            if (request.cancelled) break;
            last = chunk;
            if (chunk.text.isNotEmpty) controller.add(LlmChunk(chunk.text));
          }
          if (!request.cancelled) {
            controller.add(
              LlmChunk(
                '',
                isLast: true,
                usage: _usage(last?.usage),
                truncated: last?.finishReason == LlamaFinishReason.length,
              ),
            );
          }
        } catch (error, stack) {
          if (!request.cancelled) controller.addError(_wrap(error), stack);
        } finally {
          if (identical(_active, request)) _active = null;
          await controller.close();
        }
      }),
    );
    return controller.stream;
  }

  @override
  Future<LlmResult> complete(
    List<LlmMessage> messages, {
    LlmParams params = const LlmParams(),
  }) {
    return _queue.run(() async {
      _requireLoaded();
      final request = _active = _Request();
      try {
        final completion = await _engine
            .create(
              _toLlama(messages),
              params: _toParams(params),
              enableThinking: false,
            )
            .collect();
        return LlmResult(
          text: completion.text.trim(),
          usage: _usage(completion.usage),
          perf: await _perf(),
          truncated: completion.finishReason == LlamaFinishReason.length,
          cancelled: request.cancelled,
        );
      } catch (error) {
        throw _wrap(error);
      } finally {
        _active = null;
      }
    });
  }

  @override
  Future<LlmJsonResult> completeJson(
    List<LlmMessage> messages, {
    required Map<String, Object?> schema,
    LlmParams params = const LlmParams(),
  }) {
    return _queue.run(() async {
      _requireLoaded();
      final request = _active = _Request();
      try {
        final output = LlamaStructuredOutput<Map<String, dynamic>>.jsonSchema(
          // Deep copy so nested maps are plain Map<String, dynamic>.
          schema: jsonDecode(jsonEncode(schema)) as Map<String, dynamic>,
          decoder: (json) => json,
        );

        // Fast path: plain generation with the expected shape in the prompt,
        // then schema validation. See json_text.dart for why.
        final fast = await _engine
            .create(
              _toLlama(_withShapeHint(messages, schema)),
              params: _toParams(params),
              enableThinking: false,
            )
            .collect();
        if (request.cancelled) throw LlmCancelledException();
        final candidate = extractJsonObjectText(fast.text);
        if (candidate != null) {
          try {
            return LlmJsonResult(
              json: output.parse(candidate),
              raw: candidate,
              usage: _usage(fast.usage),
              perf: await _perf(),
            );
          } on LlamaException {
            // Invalid against the schema: fall through to the grammar.
          }
        }

        // Fallback: grammar-constrained decoding, slow but always valid.
        final constrained = await _engine
            .create(
              _toLlama(messages),
              params: _toParams(params),
              enableThinking: false,
              responseFormat: output.responseFormat,
            )
            .collect();
        if (request.cancelled) throw LlmCancelledException();
        if (constrained.finishReason == LlamaFinishReason.length) {
          throw LlmTruncatedException(params.maxTokens);
        }
        return LlmJsonResult(
          json: output.parse(constrained.text),
          raw: constrained.text,
          usage: _usage(constrained.usage),
          perf: await _perf(),
          usedGrammar: true,
        );
      } catch (error) {
        throw _wrap(error);
      } finally {
        _active = null;
      }
    });
  }

  @override
  Future<int> countTokens(String text) {
    return _queue.run(() async {
      _requireLoaded();
      return _engine.getTokenCount(text);
    });
  }

  @override
  Future<String> backendName() => _engine.getBackendName();

  @override
  void cancel() {
    final active = _active;
    if (active == null) return;
    active.cancelled = true;
    _engine.cancelGeneration();
  }

  @override
  Future<void> dispose() async {
    cancel();
    _loaded = false;
    await _engine.dispose();
  }

  void _requireLoaded() {
    if (!_loaded) throw LlmNotLoadedException();
  }

  static Object _wrap(Object error) {
    if (error is LlmException) return error;
    if (error is LlamaException) return LlmException(error.message, error);
    return LlmException(error.toString(), error);
  }

  /// Appends the expected JSON shape to the last user message.
  static List<LlmMessage> _withShapeHint(
    List<LlmMessage> messages,
    Map<String, Object?> schema,
  ) {
    final lastUser = messages.lastIndexWhere((m) => m.role == LlmRole.user);
    if (lastUser < 0) return messages;
    final hint =
        '\n\nReply with only this JSON object, filled in, and nothing else:\n'
        '${describeJsonShape(schema)}';
    return [
      for (var i = 0; i < messages.length; i++)
        i == lastUser ? LlmMessage.user(messages[i].text + hint) : messages[i],
    ];
  }

  static List<LlamaChatMessage> _toLlama(List<LlmMessage> messages) => [
    for (final message in messages)
      LlamaChatMessage.fromText(
        role: switch (message.role) {
          LlmRole.system => LlamaChatRole.system,
          LlmRole.user => LlamaChatRole.user,
          LlmRole.assistant => LlamaChatRole.assistant,
        },
        text: message.text,
      ),
  ];

  static GenerationParams _toParams(LlmParams params) => GenerationParams(
    maxTokens: params.maxTokens,
    temp: params.temperature,
    topP: params.topP,
    topK: params.topK,
    seed: params.seed,
    reusePromptPrefix: params.reusePromptPrefix,
  );

  static LlmUsage? _usage(LlamaGenerationUsage? usage) {
    if (usage == null) return null;
    return LlmUsage(
      promptTokens: usage.promptTokens,
      cachedPromptTokens: usage.cachedPromptTokens ?? 0,
      completionTokens: usage.completionTokens,
      duration: usage.duration,
      timeToFirstToken: usage.timeToFirstToken,
    );
  }

  Future<LlmPerf?> _perf() async {
    try {
      final data = await _engine.getPerformanceContext();
      if (data == null) return null;
      return LlmPerf(
        promptTokens: data.promptEvalTokens,
        promptMs: data.promptEvalMs,
        generatedTokens: data.evalTokens,
        generationMs: data.evalMs,
      );
    } on Object {
      return null;
    }
  }
}

class _Request {
  bool cancelled = false;
}
