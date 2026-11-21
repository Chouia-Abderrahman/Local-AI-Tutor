import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../db/database.dart';

/// Sent with every request. Deliberately generic: no user details.
const userAgent = 'LocalAITutor/0.8 (on-device study app)';

class WebPage {
  const WebPage({required this.url, required this.title, required this.text});

  final String url;
  final String title;

  /// Main text, paragraphs separated by blank lines.
  final String text;
}

class WebException implements Exception {
  WebException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Fetches pages politely: robots.txt respected, timeouts, a size cap,
/// HTML and plain text only, and a 7-day cache in the database. Fetched text
/// is data to read, never instructions.
class WebClient {
  WebClient(this.db, {http.Client? client}) : _client = client ?? http.Client();

  final AppDatabase db;
  final http.Client _client;
  final Map<String, List<String>> _disallowed = {};

  static const maxBytes = 2 * 1024 * 1024;
  static const timeout = Duration(seconds: 12);
  static const cacheFor = Duration(days: 7);

  Future<Map<String, Object?>> getJson(Uri uri) async {
    final response = await _client
        .get(
          uri,
          headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
        )
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw WebException('${uri.host} answered ${response.statusCode}.');
    }
    return Map<String, Object?>.from(jsonDecode(response.body) as Map);
  }

  Future<WebPage> fetchPage(String url) async {
    final cached = await (db.select(
      db.webPages,
    )..where((p) => p.url.equals(url))).getSingleOrNull();
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < cacheFor &&
        cached.httpStatus == 200) {
      return WebPage(url: url, title: cached.title ?? url, text: cached.body);
    }

    final uri = Uri.parse(url);
    if (!uri.isScheme('https') && !uri.isScheme('http')) {
      throw WebException('Only web pages can be fetched.');
    }
    if (!await _allowedByRobots(uri)) {
      throw WebException('${uri.host} asks apps not to read this page.');
    }

    final request = http.Request('GET', uri)
      ..headers['User-Agent'] = userAgent
      ..headers['Accept'] = 'text/html,text/plain;q=0.9';
    final response = await _client.send(request).timeout(timeout);
    final type = response.headers['content-type'] ?? '';
    if (!type.contains('text/html') && !type.contains('text/plain')) {
      throw WebException('Not a web page ($type).');
    }
    final bytes = <int>[];
    await for (final part in response.stream.timeout(timeout)) {
      bytes.addAll(part);
      if (bytes.length > maxBytes) break;
    }
    final body = utf8.decode(bytes, allowMalformed: true);
    final page = type.contains('text/plain')
        ? WebPage(url: url, title: uri.host, text: body)
        : extractMainText(body, url);

    await db
        .into(db.webPages)
        .insertOnConflictUpdate(
          WebPagesCompanion.insert(
            url: url,
            title: Value(page.title),
            body: page.text,
            httpStatus: response.statusCode,
            fetchedAt: DateTime.now(),
          ),
        );
    if (response.statusCode != 200) {
      throw WebException('${uri.host} answered ${response.statusCode}.');
    }
    return page;
  }

  Future<bool> _allowedByRobots(Uri uri) async {
    final rules = _disallowed[uri.host] ??= await _loadRobots(uri);
    final path = uri.path.isEmpty ? '/' : uri.path;
    return !rules.any((prefix) => prefix.isNotEmpty && path.startsWith(prefix));
  }

  /// Disallow rules for all agents ("User-agent: *").
  Future<List<String>> _loadRobots(Uri uri) async {
    try {
      final response = await _client
          .get(
            uri.replace(path: '/robots.txt', query: ''),
            headers: {'User-Agent': userAgent},
          )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return const [];
      return parseRobots(response.body);
    } on Object {
      return const [];
    }
  }

  void close() => _client.close();
}

/// Disallowed path prefixes for "User-agent: *" in a robots.txt file.
List<String> parseRobots(String text) {
  final rules = <String>[];
  var applies = false;
  var groupHasRules = false;
  for (final raw in const LineSplitter().convert(text)) {
    final line = raw.split('#').first.trim();
    if (line.isEmpty) continue;
    final colon = line.indexOf(':');
    if (colon < 0) continue;
    final key = line.substring(0, colon).trim().toLowerCase();
    final value = line.substring(colon + 1).trim();
    if (key == 'user-agent') {
      if (groupHasRules) {
        applies = false;
        groupHasRules = false;
      }
      applies = applies || value == '*';
    } else if (key == 'disallow' || key == 'allow') {
      groupHasRules = true;
      if (applies && key == 'disallow' && value.isNotEmpty) rules.add(value);
    }
  }
  return rules;
}

/// Pulls the readable text out of an HTML page: drops scripts, styles,
/// navigation and other chrome, hidden elements and comments, and keeps
/// paragraphs, list items and headings.
WebPage extractMainText(String htmlText, String url) {
  final document = html_parser.parse(htmlText);
  final title = document.querySelector('title')?.text.trim() ?? url;
  for (final selector in const [
    'script', 'style', 'noscript', 'nav', 'header', 'footer', 'aside', //
    'form', 'iframe', 'svg', 'template', '[hidden]', '[aria-hidden="true"]',
  ]) {
    for (final element in document.querySelectorAll(selector)) {
      element.remove();
    }
  }
  for (final element in document.querySelectorAll('[style]')) {
    final style = element.attributes['style']!
        .replaceAll(' ', '')
        .toLowerCase();
    if (style.contains('display:none') || style.contains('visibility:hidden')) {
      element.remove();
    }
  }
  final root =
      document.querySelector('main') ??
      document.querySelector('article') ??
      document.querySelector('#content') ??
      document.body;
  final blocks = <String>[];
  void collect(dom.Element element) {
    final tag = element.localName;
    if (const {
      'p',
      'li',
      'h1',
      'h2',
      'h3',
      'h4',
      'dd',
      'blockquote',
      'td',
    }.contains(tag)) {
      final text = element.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.length >= 20 ||
          (tag?.startsWith('h') ?? false) && text.isNotEmpty) {
        blocks.add(text);
      }
      return;
    }
    for (final child in element.children) {
      collect(child);
    }
  }

  if (root != null) collect(root);
  return WebPage(url: url, title: title, text: blocks.join('\n\n'));
}
