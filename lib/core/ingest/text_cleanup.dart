import 'extracted.dart';

/// Normalizes one line of extracted text: ligatures, odd spaces and hyphens,
/// curly quotes left alone (the quote matcher handles those).
String normalizeLine(String text) {
  var out = text;
  _ligatures.forEach((from, to) => out = out.replaceAll(from, to));
  out = out
      .replaceAll('­', '') // soft hyphen
      .replaceAll(RegExp('[​-‍﻿]'), '') // zero-width
      .replaceAll(RegExp('[  -   　\t]'), ' ')
      .replaceAll(RegExp(' {2,}'), ' ');
  return out.trim();
}

const _ligatures = {
  'ﬀ': 'ff',
  'ﬁ': 'fi',
  'ﬂ': 'fl',
  'ﬃ': 'ffi',
  'ﬄ': 'ffl',
  'ﬅ': 'st',
  'ﬆ': 'st',
};

/// Removes running headers, footers and bare page numbers.
///
/// A line counts as a running header or footer when, with digits ignored, it
/// sits at the edge of at least 40% of pages (and of at least 3 pages). The
/// edge is the first two and last two lines, plus anything in the top or
/// bottom 7% of the page (PDFium often lists headers and footers first).
List<PageText> removeRunningHeadersAndFooters(List<PageText> pages) {
  final edgeCounts = <String, int>{};
  for (final page in pages) {
    final keys = {for (final line in _edgeLines(page)) _edgeKey(line)};
    for (final key in keys) {
      if (key.isNotEmpty) edgeCounts[key] = (edgeCounts[key] ?? 0) + 1;
    }
  }
  final threshold = pages.length < 3
      ? 1 << 30
      : (pages.length * 0.4).ceil().clamp(3, 1 << 30);
  final repeated = {
    for (final entry in edgeCounts.entries)
      if (entry.value >= threshold) entry.key,
  };

  return [
    for (final page in pages)
      PageText(
        number: page.number,
        width: page.width,
        height: page.height,
        hasImages: page.hasImages,
        lines: [
          for (final (index, line) in page.lines.indexed)
            if (!(_isEdge(page, index) &&
                (repeated.contains(_edgeKey(line)) ||
                    _isPageNumber(line.text))))
              line,
        ],
      ),
  ];
}

Iterable<TextLine> _edgeLines(PageText page) sync* {
  for (final (index, line) in page.lines.indexed) {
    if (_isEdge(page, index)) yield line;
  }
}

bool _isEdge(PageText page, int index) {
  if (index < 2 || index >= page.lines.length - 2) return true;
  final top = page.lines[index].top;
  return page.height > 0 &&
      (top < page.height * 0.07 || top > page.height * 0.93);
}

String _edgeKey(TextLine line) =>
    line.text.toLowerCase().replaceAll(RegExp(r'\d+'), '#').trim();

final _pageNumber = RegExp(
  r'^(page|p\.|seite|página)?\s*([0-9]{1,4}|[ivxlcdm]{1,7})(\s*(/|of|sur|de)\s*[0-9]{1,4})?$',
  caseSensitive: false,
);

bool _isPageNumber(String text) => _pageNumber.hasMatch(text.trim());

/// Joins two lines of one paragraph, undoing end-of-line hyphenation
/// (`exam-` + `ple` becomes `example`).
String joinLines(String previous, String next) {
  if (previous.isEmpty) return next;
  if (next.isEmpty) return previous;
  final hyphenated = RegExp(r'\p{L}-$', unicode: true).hasMatch(previous);
  final continuesLower = RegExp(r'^\p{Ll}', unicode: true).hasMatch(next);
  if (hyphenated && continuesLower) {
    return previous.substring(0, previous.length - 1) + next;
  }
  return '$previous $next';
}

/// True when [text] ends a sentence.
bool endsSentence(String text) =>
    RegExp(r'''[.!?:;…。！？]["'”’)\]]*$''').hasMatch(text.trimRight());
