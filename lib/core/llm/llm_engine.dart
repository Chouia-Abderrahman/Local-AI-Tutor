/// The app's view of a local language model.
///
/// Everything above this interface (question generation, chat, fact checks)
/// is written against it, so the runtime can be swapped and tests can use
/// `FakeLlmEngine` instead of a real model.
library;

/// Who wrote a chat message.
enum LlmRole { system, user, assistant }

/// One message sent to the model.
class LlmMessage {
  const LlmMessage(this.role, this.text);
  const LlmMessage.system(this.text) : role = LlmRole.system;
  const LlmMessage.user(this.text) : role = LlmRole.user;
  const LlmMessage.assistant(this.text) : role = LlmRole.assistant;

  final LlmRole role;
  final String text;
}

/// Sampling settings for one request.
class LlmParams {
  const LlmParams({
    this.maxTokens = 512,
    this.temperature = 0.2,
    this.topP = 0.95,
    this.topK = 40,
    this.seed,
    this.reusePromptPrefix = true,
  });

  final int maxTokens;
  final double temperature;
  final double topP;
  final int topK;
  final int? seed;

  /// Reuse the cached start of the previous prompt when this prompt begins
  /// the same way. Prompts put the document chunk first so that several
  /// requests about one chunk only read it once.
  final bool reusePromptPrefix;
}

/// Model settings fixed at load time.
class LlmLoadOptions {
  const LlmLoadOptions({this.contextSize = 4096});

  /// Maximum prompt plus reply length, in tokens. Memory grows with it.
  final int contextSize;
}

/// Token accounting for one finished request.
class LlmUsage {
  const LlmUsage({
    required this.promptTokens,
    required this.cachedPromptTokens,
    required this.completionTokens,
    this.duration,
    this.timeToFirstToken,
  });

  final int promptTokens;

  /// Prompt tokens that were reused from the previous request's cache.
  final int cachedPromptTokens;
  final int completionTokens;
  final Duration? duration;
  final Duration? timeToFirstToken;
}

/// Timing counters for one request, as measured by the runtime.
class LlmPerf {
  const LlmPerf({
    required this.promptTokens,
    required this.promptMs,
    required this.generatedTokens,
    required this.generationMs,
  });

  final int promptTokens;
  final double promptMs;
  final int generatedTokens;
  final double generationMs;

  double get promptTokensPerSecond =>
      promptMs <= 0 ? 0 : promptTokens * 1000 / promptMs;

  double get generationTokensPerSecond =>
      generationMs <= 0 ? 0 : generatedTokens * 1000 / generationMs;
}

class LlmResult {
  const LlmResult({
    required this.text,
    this.usage,
    this.perf,
    this.truncated = false,
    this.cancelled = false,
  });

  final String text;
  final LlmUsage? usage;
  final LlmPerf? perf;

  /// Generation stopped because it reached `maxTokens`.
  final bool truncated;
  final bool cancelled;
}

class LlmJsonResult {
  const LlmJsonResult({
    required this.json,
    required this.raw,
    this.usage,
    this.perf,
    this.usedGrammar = false,
  });

  final Map<String, Object?> json;
  final String raw;
  final LlmUsage? usage;
  final LlmPerf? perf;

  /// The plain-text attempt failed validation and the slower
  /// grammar-constrained retry produced this result.
  final bool usedGrammar;
}

/// One streamed piece of a reply. The final chunk has [isLast] set, an empty
/// [text], and [usage] when the runtime reports it.
class LlmChunk {
  const LlmChunk(
    this.text, {
    this.isLast = false,
    this.usage,
    this.truncated = false,
  });

  final String text;
  final bool isLast;
  final LlmUsage? usage;
  final bool truncated;
}

class LlmException implements Exception {
  LlmException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// The model was asked for something before a model was loaded.
class LlmNotLoadedException extends LlmException {
  LlmNotLoadedException() : super('No AI model is loaded.');
}

/// The reply hit `maxTokens` before the JSON object was complete.
class LlmTruncatedException extends LlmException {
  LlmTruncatedException(int maxTokens)
    : super('The reply was cut off at $maxTokens tokens.');
}

class LlmCancelledException extends LlmException {
  LlmCancelledException() : super('Generation was cancelled.');
}

/// A local language model. Implementations run one request at a time;
/// concurrent calls wait their turn.
abstract interface class LlmEngine {
  bool get isLoaded;

  /// File name of the loaded model, such as `Qwen3.5-4B-Q4_K_M.gguf`.
  String? get modelName;

  Future<void> load(
    String modelPath, {
    LlmLoadOptions options = const LlmLoadOptions(),
  });

  Future<void> unload();

  /// Streams a plain-text reply. Cancelling the subscription stops generation.
  Stream<LlmChunk> stream(
    List<LlmMessage> messages, {
    LlmParams params = const LlmParams(),
  });

  Future<LlmResult> complete(
    List<LlmMessage> messages, {
    LlmParams params = const LlmParams(),
  });

  /// Returns a JSON object validated against [schema]. Throws
  /// [LlmException] when the model cannot produce a valid object.
  Future<LlmJsonResult> completeJson(
    List<LlmMessage> messages, {
    required Map<String, Object?> schema,
    LlmParams params = const LlmParams(),
  });

  Future<int> countTokens(String text);

  /// Name of the compute backend in use, for diagnostics (for example `CPU`).
  Future<String> backendName();

  /// Stops the request that is currently generating, if any.
  void cancel();

  Future<void> dispose();
}
