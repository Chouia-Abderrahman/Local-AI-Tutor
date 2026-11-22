import 'dart:convert';

import 'llm_engine.dart';

/// Decides the reply to one request: a `String`, a JSON `Map`, or an
/// exception to throw.
typedef FakeResponder =
    Object Function(List<LlmMessage> messages, Map<String, Object?>? schema);

class FakeCall {
  const FakeCall(this.messages, this.schema);

  final List<LlmMessage> messages;
  final Map<String, Object?>? schema;

  String get userText => messages.lastWhere((m) => m.role == LlmRole.user).text;
}

/// [LlmEngine] for tests: replays scripted replies instead of running a model.
class FakeLlmEngine implements LlmEngine {
  FakeLlmEngine({this.responder});

  /// Used when the script is empty.
  FakeResponder? responder;

  /// Loading on a GPU backend fails, as it does on a phone whose GPU driver
  /// can't run the model.
  bool failOnGpu = false;

  /// Report the backend each load asked for (`CPU`, `OpenCL`, `Vulkan`)
  /// instead of `fake`.
  bool reportBackends = false;

  /// Backends that quietly run on the CPU, as a phone without that GPU
  /// driver does.
  final Set<LlmBackend> fallsBackToCpu = {};

  /// Measured speeds per backend, as tokens per second: reading, writing.
  /// Empty: no timing is reported.
  final Map<LlmBackend, (double, double)> speeds = {};

  LlmBackend _backend = LlmBackend.cpu;

  final List<Object> _script = [];

  /// Every request received, in order.
  final List<FakeCall> calls = [];

  bool _loaded = true;
  String? _modelName = 'fake-model.gguf';

  /// Adds a reply to the script: a `String`, a JSON `Map`, or an exception.
  void enqueue(Object reply) => _script.add(reply);

  @override
  bool get isLoaded => _loaded;

  @override
  String? get modelName => _modelName;

  @override
  Future<void> load(
    String modelPath, {
    LlmLoadOptions options = const LlmLoadOptions(),
  }) async {
    if (failOnGpu && options.backend != LlmBackend.cpu) {
      throw LlmException('The GPU driver could not run the model.');
    }
    _loaded = true;
    _backend = options.backend;
    _modelName = modelPath.split('/').last;
  }

  @override
  Future<void> unload() async {
    _loaded = false;
    _modelName = null;
  }

  @override
  Stream<LlmChunk> stream(
    List<LlmMessage> messages, {
    LlmParams params = const LlmParams(),
  }) async* {
    final text = _asText(_next(messages, null));
    for (final word in text.split(RegExp(r'(?<= )'))) {
      yield LlmChunk(word);
    }
    yield LlmChunk('', isLast: true, usage: _usage(messages, text));
  }

  @override
  Future<LlmResult> complete(
    List<LlmMessage> messages, {
    LlmParams params = const LlmParams(),
  }) async {
    final text = _asText(_next(messages, null));
    final usage = _usage(messages, text);
    final speed = speeds[_backend];
    return LlmResult(
      text: text,
      usage: usage,
      perf: speed == null
          ? null
          : LlmPerf(
              promptTokens: usage.promptTokens,
              promptMs: usage.promptTokens * 1000 / speed.$1,
              generatedTokens: usage.completionTokens,
              generationMs: usage.completionTokens * 1000 / speed.$2,
            ),
    );
  }

  @override
  Future<LlmJsonResult> completeJson(
    List<LlmMessage> messages, {
    required Map<String, Object?> schema,
    LlmParams params = const LlmParams(),
  }) async {
    final reply = _next(messages, schema);
    final Object? decoded = reply is String ? jsonDecode(reply) : reply;
    if (decoded is! Map) {
      throw LlmException('Fake reply is not a JSON object: $reply');
    }
    final json = Map<String, Object?>.from(decoded);
    final raw = jsonEncode(json);
    return LlmJsonResult(json: json, raw: raw, usage: _usage(messages, raw));
  }

  @override
  Future<int> countTokens(String text) async => estimateTokens(text);

  @override
  Future<String> backendName() async {
    if (!reportBackends) return 'fake';
    if (fallsBackToCpu.contains(_backend)) return 'CPU';
    return switch (_backend) {
      LlmBackend.cpu => 'CPU',
      LlmBackend.opencl => 'OpenCL',
      LlmBackend.vulkan => 'Vulkan',
    };
  }

  @override
  void cancel() {}

  @override
  Future<void> dispose() async {}

  Object _next(List<LlmMessage> messages, Map<String, Object?>? schema) {
    if (!_loaded) throw LlmNotLoadedException();
    calls.add(FakeCall(List.unmodifiable(messages), schema));
    final Object reply;
    if (_script.isNotEmpty) {
      reply = _script.removeAt(0);
    } else if (responder != null) {
      reply = responder!(messages, schema);
    } else {
      throw StateError('FakeLlmEngine has no scripted reply left.');
    }
    if (reply is Exception) throw reply;
    if (reply is Error) throw reply;
    return reply;
  }

  static String _asText(Object reply) =>
      reply is String ? reply : jsonEncode(reply);

  static LlmUsage _usage(List<LlmMessage> messages, String reply) => LlmUsage(
    promptTokens: estimateTokens(messages.map((m) => m.text).join('\n')),
    cachedPromptTokens: 0,
    completionTokens: estimateTokens(reply),
  );

  /// Rough token count used by the fake: about four characters per token.
  static int estimateTokens(String text) => (text.length / 4).ceil();
}
