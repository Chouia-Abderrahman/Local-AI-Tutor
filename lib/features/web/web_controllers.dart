import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/generate/json_model.dart';
import '../../core/llm/llm_engine.dart';
import '../../core/web/fact_checker.dart';
import '../../core/web/search.dart';
import '../../core/web/web_client.dart';

const _enabledKey = 'web_enabled';
const _searxKey = 'web_searx_url';

@immutable
class WebSettings {
  const WebSettings({this.enabled = false, this.searxUrl});

  final bool enabled;

  /// A SearXNG instance the user runs, for general web search.
  final String? searxUrl;
}

class WebSettingsController extends AsyncNotifier<WebSettings> {
  @override
  Future<WebSettings> build() async {
    final db = ref.watch(databaseProvider);
    return WebSettings(
      enabled: await db.getSetting(_enabledKey) == 'true',
      searxUrl: await db.getSetting(_searxKey),
    );
  }

  Future<void> setEnabled(bool enabled) async {
    await ref.read(databaseProvider).setSetting(_enabledKey, '$enabled');
    ref.invalidateSelf();
  }

  Future<void> setSearxUrl(String? url) async {
    final value = url == null || url.trim().isEmpty ? null : url.trim();
    await ref.read(databaseProvider).setSetting(_searxKey, value);
    ref.invalidateSelf();
  }
}

final webSettingsProvider =
    AsyncNotifierProvider<WebSettingsController, WebSettings>(
      WebSettingsController.new,
    );

final webClientProvider = Provider<WebClient>((ref) {
  final client = WebClient(ref.watch(databaseProvider));
  ref.onDispose(client.close);
  return client;
});

/// Search providers in order: Wikipedia, then the user's SearXNG if set.
final searchProvidersProvider = FutureProvider<List<SearchProvider>>((
  ref,
) async {
  final web = ref.watch(webClientProvider);
  final settings = await ref.watch(webSettingsProvider.future);
  return [
    WikipediaSearch(web),
    if (settings.searxUrl != null) SearxSearch(web, settings.searxUrl!),
  ];
});

final webLogProvider = StreamProvider<List<WebLogEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.webLogEntries)
        ..orderBy([
          (e) => OrderingTerm(expression: e.at, mode: OrderingMode.desc),
        ])
        ..limit(200))
      .watch();
});

/// Whether web lookups are allowed for a document (stored with it).
Future<bool> documentAllowsWeb(AppDatabase db, int documentId) async {
  final doc = await (db.select(
    db.documents,
  )..where((d) => d.id.equals(documentId))).getSingle();
  if (doc.settingsJson == null) return false;
  return (jsonDecode(doc.settingsJson!) as Map)['web'] == true;
}

Future<void> setDocumentAllowsWeb(
  AppDatabase db,
  int documentId,
  bool allowed,
) async {
  final doc = await (db.select(
    db.documents,
  )..where((d) => d.id.equals(documentId))).getSingle();
  final settings = doc.settingsJson == null
      ? <String, Object?>{}
      : Map<String, Object?>.from(jsonDecode(doc.settingsJson!) as Map);
  settings['web'] = allowed;
  await (db.update(db.documents)..where((d) => d.id.equals(documentId))).write(
    DocumentsCompanion(settingsJson: Value(jsonEncode(settings))),
  );
}

/// Asks before the first web lookup for a document (and turns web access
/// on, when it is off). Returns whether the lookup may go ahead.
Future<bool> ensureWebAllowed(
  BuildContext context,
  WidgetRef ref,
  int documentId,
) async {
  final db = ref.read(databaseProvider);
  final settings = await ref.read(webSettingsProvider.future);
  if (settings.enabled && await documentAllowsWeb(db, documentId)) return true;
  if (!context.mounted) return false;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Look this up on the web?'),
      content: Text(
        'A few words from the question are sent to Wikipedia'
        '${settings.searxUrl == null ? '' : ' and your search server'}, and '
        'the pages found are read on this phone. Nothing else leaves the '
        'phone. Every query is listed in Settings → Web access.'
        '${settings.enabled ? '' : '\n\nThis turns web access on.'}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Allow for this document'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  if (!settings.enabled) {
    await ref.read(webSettingsProvider.notifier).setEnabled(true);
  }
  await setDocumentAllowsWeb(db, documentId, true);
  return true;
}

/// A fact checker using the loaded model, or null when none is loaded.
/// A fact checker on [engine], which [ModelUse] has loaded.
Future<FactChecker> buildFactChecker(WidgetRef ref, LlmEngine engine) async {
  final db = ref.read(databaseProvider);
  return FactChecker(
    db: db,
    model: CachedJsonModel(EngineJsonModel(engine), db),
    providers: await ref.read(searchProvidersProvider.future),
    web: ref.read(webClientProvider),
  );
}
