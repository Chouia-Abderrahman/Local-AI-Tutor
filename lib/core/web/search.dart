import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../db/database.dart';
import '../text/matching.dart';
import 'web_client.dart';

class SearchHit {
  const SearchHit({required this.title, required this.url, this.text});

  final String title;
  final String url;

  /// Full text when the provider returns it directly (Wikipedia), so no
  /// page fetch is needed.
  final String? text;
}

abstract interface class SearchProvider {
  String get name;
  Future<List<SearchHit>> search(String query, {String? language, int limit});
}

/// Wikipedia through its API: no key, plain-text extracts, the document's
/// language edition first.
class WikipediaSearch implements SearchProvider {
  WikipediaSearch(this.web);

  final WebClient web;

  @override
  String get name => 'Wikipedia';

  @override
  Future<List<SearchHit>> search(
    String query, {
    String? language,
    int limit = 3,
  }) async {
    final lang = language == null || language == 'und' ? 'en' : language;
    final base = Uri.https('$lang.wikipedia.org', '/w/api.php');
    final found = await web.getJson(
      base.replace(
        queryParameters: {
          'action': 'query',
          'list': 'search',
          'srsearch': query,
          'srlimit': '$limit',
          'format': 'json',
          'utf8': '1',
        },
      ),
    );
    final results = ((found['query'] as Map?)?['search'] as List?) ?? const [];
    final titles = [for (final r in results) '${(r as Map)['title']}'];
    if (titles.isEmpty) return const [];
    final pages = await web.getJson(
      base.replace(
        queryParameters: {
          'action': 'query',
          'prop': 'extracts',
          'explaintext': '1',
          'exlimit': '$limit',
          'titles': titles.join('|'),
          'format': 'json',
          'utf8': '1',
        },
      ),
    );
    final byTitle = <String, String>{};
    for (final page
        in ((pages['query'] as Map?)?['pages'] as Map?)?.values ?? const []) {
      final map = page as Map;
      byTitle['${map['title']}'] = '${map['extract'] ?? ''}';
    }
    return [
      for (final title in titles)
        if ((byTitle[title] ?? '').isNotEmpty)
          SearchHit(
            title: title,
            url:
                'https://$lang.wikipedia.org/wiki/${Uri.encodeComponent(title.replaceAll(' ', '_'))}',
            text: byTitle[title],
          ),
    ];
  }
}

/// A SearXNG instance the user runs (its JSON format must be enabled).
class SearxSearch implements SearchProvider {
  SearxSearch(this.web, this.baseUrl);

  final WebClient web;
  final String baseUrl;

  @override
  String get name => 'SearXNG';

  @override
  Future<List<SearchHit>> search(
    String query, {
    String? language,
    int limit = 4,
  }) async {
    final json = await web.getJson(
      Uri.parse(baseUrl).replace(
        path: '/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          if (language != null && language != 'und') 'language': language,
        },
      ),
    );
    return [
      for (final r in (json['results'] as List? ?? const []).take(limit))
        SearchHit(title: '${(r as Map)['title']}', url: '${r['url']}'),
    ];
  }
}

/// A search query from a claim: its content words, most specific first,
/// at most eight. Never whole passages of the document.
String searchQueryFor(String claim) {
  final words = contentSequence(claim, stem: false).toSet().toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  return words.take(8).join(' ');
}

/// A passage of a web page and how well it matches the claim.
class WebPassage {
  const WebPassage({
    required this.text,
    required this.title,
    required this.url,
    required this.score,
  });

  final String text;
  final String title;
  final String url;
  final double score;
}

/// Splits [text] into ~120-word passages and returns the [limit] that cover
/// the most of [claim]'s content words.
List<WebPassage> rankPassages(
  String claim,
  String text, {
  required String title,
  required String url,
  int limit = 2,
  int wordsPerPassage = 120,
}) {
  final passages = <String>[];
  final buffer = <String>[];
  for (final paragraph in text.split(RegExp(r'\n\s*\n'))) {
    final words = paragraph.trim().split(RegExp(r'\s+'));
    if (paragraph.trim().isEmpty) continue;
    if (buffer.length + words.length > wordsPerPassage && buffer.isNotEmpty) {
      passages.add(buffer.join(' '));
      buffer.clear();
    }
    buffer.addAll(words);
    while (buffer.length > wordsPerPassage * 1.5) {
      passages.add(buffer.take(wordsPerPassage).join(' '));
      buffer.removeRange(0, wordsPerPassage);
    }
  }
  if (buffer.isNotEmpty) passages.add(buffer.join(' '));

  final scored = [
    for (final p in passages)
      WebPassage(text: p, title: title, url: url, score: coverage(claim, p)),
  ]..sort((a, b) => b.score.compareTo(a.score));
  return scored.where((p) => p.score > 0).take(limit).toList();
}

/// Writes a query to the web activity log.
Future<void> logWebQuery(
  AppDatabase db, {
  required String query,
  required String provider,
  required List<String> urls,
}) => db
    .into(db.webLogEntries)
    .insert(
      WebLogEntriesCompanion.insert(
        query: query,
        provider: provider,
        urlsJson: Value(jsonEncode(urls)),
      ),
    );
