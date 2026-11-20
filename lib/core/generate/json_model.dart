import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../db/database.dart';
import '../llm/llm_engine.dart';
import 'prompts.dart';

/// What the generator needs from a model: one JSON object per request.
abstract interface class JsonModel {
  String get modelName;

  Future<Map<String, Object?>> json({
    required String stage,
    required List<LlmMessage> messages,
    required Map<String, Object?> schema,
    required int maxTokens,
    double temperature,
  });
}

/// [JsonModel] over an [LlmEngine]. Counts calls and time for estimates.
class EngineJsonModel implements JsonModel {
  EngineJsonModel(this.engine);

  final LlmEngine engine;
  int calls = 0;
  Duration elapsed = Duration.zero;

  @override
  String get modelName => engine.modelName ?? 'unknown';

  @override
  Future<Map<String, Object?>> json({
    required String stage,
    required List<LlmMessage> messages,
    required Map<String, Object?> schema,
    required int maxTokens,
    double temperature = 0.2,
  }) async {
    final watch = Stopwatch()..start();
    try {
      final result = await engine.completeJson(
        messages,
        schema: schema,
        params: LlmParams(maxTokens: maxTokens, temperature: temperature),
      );
      return result.json;
    } finally {
      calls++;
      elapsed += watch.elapsed;
    }
  }
}

/// Caches outputs by a hash of everything that shaped them (prompt version,
/// model, stage, schema, messages, sampling), so an interrupted or repeated
/// run reuses finished work instead of asking the model again.
class CachedJsonModel implements JsonModel {
  CachedJsonModel(this.inner, this.db);

  final JsonModel inner;
  final AppDatabase db;
  int hits = 0;

  @override
  String get modelName => inner.modelName;

  @override
  Future<Map<String, Object?>> json({
    required String stage,
    required List<LlmMessage> messages,
    required Map<String, Object?> schema,
    required int maxTokens,
    double temperature = 0.2,
  }) async {
    final key = sha256
        .convert(
          utf8.encode(
            jsonEncode([
              promptVersion,
              inner.modelName,
              stage,
              schema,
              [
                for (final m in messages) [m.role.name, m.text],
              ],
              maxTokens,
              temperature,
            ]),
          ),
        )
        .toString();
    final cached = await (db.select(
      db.llmCacheEntries,
    )..where((e) => e.cacheKey.equals(key))).getSingleOrNull();
    if (cached != null) {
      hits++;
      return Map<String, Object?>.from(jsonDecode(cached.output) as Map);
    }
    final output = await inner.json(
      stage: stage,
      messages: messages,
      schema: schema,
      maxTokens: maxTokens,
      temperature: temperature,
    );
    await db
        .into(db.llmCacheEntries)
        .insertOnConflictUpdate(
          LlmCacheEntry(
            cacheKey: key,
            output: jsonEncode(output),
            createdAt: DateTime.now(),
          ),
        );
    return output;
  }
}
