import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/device/device_memory.dart';
import '../core/llm/llamadart_engine.dart';
import '../core/llm/llm_engine.dart';
import '../core/llm/model_store.dart';

/// The app database. Tests override this with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The single on-device model. Tests override this with `FakeLlmEngine`.
final llmEngineProvider = Provider<LlmEngine>((ref) {
  final engine = LlamadartEngine();
  ref.onDispose(() => unawaited(engine.dispose()));
  return engine;
});

final modelStoreProvider = FutureProvider<ModelStore>(
  (ref) => ModelStore.open(),
);

/// Total device RAM in bytes, or null when unknown.
final totalMemoryProvider = FutureProvider<int?>(
  (ref) => readTotalMemoryBytes(),
);
