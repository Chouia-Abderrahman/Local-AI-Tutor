import 'dart:convert';

import 'llm_engine.dart';

/// How one backend did in the speed comparison.
enum BackendStatus {
  /// Ran, and was measured.
  ok,

  /// Asked for the GPU but the model ran on the CPU instead.
  unavailable,

  /// Could not load the model or crashed the app.
  failed,

  /// Skipped (the test was stopped, or interrupted).
  notTested,
}

class BackendResult {
  const BackendResult({
    required this.backend,
    required this.status,
    this.readTokensPerSecond = 0,
    this.writeTokensPerSecond = 0,
    this.note,
  });

  const BackendResult.failed(this.backend, String this.note)
    : status = BackendStatus.failed,
      readTokensPerSecond = 0,
      writeTokensPerSecond = 0;

  final LlmBackend backend;
  final BackendStatus status;

  /// How fast the model reads a prompt (tokens per second).
  final double readTokensPerSecond;

  /// How fast the model writes (tokens per second): what makes answers and
  /// question generation feel fast or slow.
  final double writeTokensPerSecond;

  /// Why it did not run, in words for the user.
  final String? note;

  bool get ok => status == BackendStatus.ok;

  /// A typical question: it reads a passage of this many tokens...
  static const typicalPromptTokens = 600;

  /// ...and writes this many.
  static const typicalReplyTokens = 200;

  /// Estimated seconds for a typical question (reading the passage, then
  /// writing the reply). This is what the user feels, so it decides the
  /// ranking: a GPU that reads fast but writes slowly is judged on both.
  double get typicalSeconds =>
      typicalPromptTokens / readTokensPerSecond +
      typicalReplyTokens / writeTokensPerSecond;

  Map<String, Object?> toJson() => {
    'backend': backend.name,
    'status': status.name,
    'read': readTokensPerSecond,
    'write': writeTokensPerSecond,
    'note': note,
  };

  factory BackendResult.fromJson(Map<String, Object?> json) => BackendResult(
    backend: LlmBackend.values.byName(json['backend'] as String),
    status: BackendStatus.values.byName(json['status'] as String),
    readTokensPerSecond: (json['read'] as num?)?.toDouble() ?? 0,
    writeTokensPerSecond: (json['write'] as num?)?.toDouble() ?? 0,
    note: json['note'] as String?,
  );
}

/// The latest comparison of backends for one model file.
class BackendBenchmark {
  const BackendBenchmark({
    required this.modelFile,
    required this.at,
    required this.results,
  });

  final String modelFile;
  final DateTime at;
  final List<BackendResult> results;

  BackendResult? resultFor(LlmBackend backend) =>
      results.where((r) => r.backend == backend).firstOrNull;

  /// The backend to run the model on: the one with the shortest estimated
  /// time for a typical question. The CPU wins a near tie (within 5%), as
  /// the safer choice. Null when nothing could be measured.
  BackendResult? get fastest {
    final measured = results
        .where(
          (r) =>
              r.ok && r.readTokensPerSecond > 0 && r.writeTokensPerSecond > 0,
        )
        .toList();
    if (measured.isEmpty) return null;
    final best = measured.reduce(
      (a, b) => b.typicalSeconds < a.typicalSeconds ? b : a,
    );
    final cpu = measured.where((r) => r.backend == LlmBackend.cpu).firstOrNull;
    if (cpu != null && cpu.typicalSeconds <= best.typicalSeconds * 1.05) {
      return cpu;
    }
    return best;
  }

  String toJsonString() => jsonEncode({
    'model': modelFile,
    'at': at.toUtc().toIso8601String(),
    'results': [for (final r in results) r.toJson()],
  });

  static BackendBenchmark? tryParse(String? text) {
    if (text == null) return null;
    try {
      final json = jsonDecode(text) as Map<String, Object?>;
      return BackendBenchmark(
        modelFile: json['model'] as String,
        at: DateTime.parse(json['at'] as String).toLocal(),
        results: [
          for (final r in json['results'] as List)
            BackendResult.fromJson(Map<String, Object?>.from(r as Map)),
        ],
      );
    } on Object {
      return null;
    }
  }
}
