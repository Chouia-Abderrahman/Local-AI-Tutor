import 'extracted.dart';
import 'text_cleanup.dart';

/// Lines per virtual page, so text files get usable "page" references.
const _linesPerPage = 60;

/// Turns a `.txt` or `.md` file into pages of lines. Blank lines are kept
/// (they separate paragraphs). Markdown headings, and in plain text short
/// numbered or all-caps lines, become headings.
ExtractedDocument readPlainText(
  String content, {
  required String title,
  bool markdown = false,
}) {
  final rawLines = content.replaceAll('\r\n', '\n').split('\n');
  final lines = <TextLine>[];
  var inCodeFence = false;
  for (final raw in rawLines) {
    if (markdown && raw.trimLeft().startsWith('```')) {
      inCodeFence = !inCodeFence;
      continue;
    }
    if (inCodeFence) {
      lines.add(TextLine(raw.trimRight()));
      continue;
    }
    final text = normalizeLine(raw);
    if (markdown) {
      final heading = RegExp(r'^(#{1,6})\s+(.+?)\s*#*$').firstMatch(text);
      if (heading != null) {
        lines.add(
          TextLine(
            _stripMarkdown(heading.group(2)!),
            headingLevel: heading.group(1)!.length,
          ),
        );
        continue;
      }
      lines.add(TextLine(_stripMarkdown(text)));
    } else {
      lines.add(TextLine(text, headingLevel: _plainHeadingLevel(text)));
    }
  }

  final pages = <PageText>[];
  for (var start = 0; start < lines.length; start += _linesPerPage) {
    final end = (start + _linesPerPage).clamp(0, lines.length);
    pages.add(
      PageText(number: pages.length + 1, lines: lines.sublist(start, end)),
    );
  }
  return ExtractedDocument(title: title, pages: pages, isPlainText: true);
}

String _stripMarkdown(String text) => text
    .replaceAllMapped(RegExp(r'!?\[([^\]]*)\]\([^)]*\)'), (m) => m.group(1)!)
    .replaceAll(RegExp(r'(\*\*|__|`)'), '')
    .replaceAllMapped(
      RegExp(r'(^|\s)[*_]([^*_]+)[*_](?=\s|$|[.,;:!?])'),
      (m) => '${m.group(1)}${m.group(2)}',
    )
    .replaceAll(RegExp(r'^>\s?'), '')
    .trim();

int? _plainHeadingLevel(String text) {
  if (text.isEmpty || text.length > 80 || endsSentence(text)) return null;
  final words = text.split(' ').length;
  final numbered = RegExp(
    r'^(\d+(\.\d+){0,3})\.?\s+\p{Lu}',
    unicode: true,
  ).firstMatch(text);
  if (numbered != null && words <= 10) {
    return '.'.allMatches(numbered.group(1)!).length + 1;
  }
  final letters = text.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
  if (letters.length >= 3 &&
      words <= 8 &&
      letters == letters.toUpperCase() &&
      letters != letters.toLowerCase()) {
    return 1;
  }
  if (RegExp(
        r'^(chapter|chapitre|part|partie|unit|lesson)\s+\w+',
        caseSensitive: false,
      ).hasMatch(text) &&
      words <= 8) {
    return 1;
  }
  return null;
}
