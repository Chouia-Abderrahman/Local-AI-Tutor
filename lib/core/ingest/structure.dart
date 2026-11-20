import 'dart:math' as math;

import 'extracted.dart';
import 'text_cleanup.dart';

/// A paragraph of cleaned text, with the pages it spans.
class Paragraph {
  Paragraph(this.text, {required this.pageStart, required this.pageEnd});

  String text;
  final int pageStart;
  int pageEnd;
}

/// A node of the document's topic tree.
class SectionNode {
  SectionNode({
    required this.title,
    required this.level,
    required this.pageStart,
    this.parent,
  });

  final String title;

  /// 0 for the document root, 1 for top-level sections.
  final int level;
  final int pageStart;
  int pageEnd = 0;
  final SectionNode? parent;
  final List<SectionNode> children = [];
  final List<Paragraph> paragraphs = [];

  List<String> get path => [
    if (parent != null && parent!.level > 0) ...parent!.path,
    title,
  ];

  Iterable<SectionNode> get descendants sync* {
    for (final child in children) {
      yield child;
      yield* child.descendants;
    }
  }
}

/// Builds the section tree for a document and fills it with paragraphs.
///
/// Headings come from, in order of preference: the PDF outline, Markdown
/// headings, then lines that look like headings (taller text, numbering).
/// A document with none of these gets one section per 10 pages.
SectionNode buildStructure(ExtractedDocument doc) {
  final root = SectionNode(title: doc.title, level: 0, pageStart: 1);
  final pages = doc.pages;
  if (pages.isEmpty) return root;

  final markers = _headingMarkers(doc);
  final markerAt = <(int, int), _Marker>{
    for (final marker in markers) (marker.page, marker.lineIndex): marker,
  };
  // Outline entries whose title wasn't found on the page start at the top.
  final pageStarts = <int, List<_Marker>>{};
  for (final marker in markers.where((m) => m.lineIndex < 0)) {
    pageStarts.putIfAbsent(marker.page, () => []).add(marker);
  }

  var current = root;
  SectionNode open(_Marker marker) {
    var parent = current;
    while (parent.level >= marker.level && parent.parent != null) {
      parent = parent.parent!;
    }
    final node = SectionNode(
      title: marker.title,
      level: marker.level,
      pageStart: marker.page,
      parent: parent,
    );
    parent.children.add(node);
    return node;
  }

  if (markers.isEmpty && pages.length > 10) {
    // No structure at all: fixed page ranges.
    for (var start = 1; start <= pages.length; start += 10) {
      final end = math.min(start + 9, pages.length);
      pageStarts[start] = [
        _Marker(title: 'Pages $start–$end', level: 1, page: start),
      ];
    }
  }

  final bodyHeight = _bodyLineHeight(pages);
  Paragraph? paragraph;
  TextLine? previousLine;
  for (final page in pages) {
    for (final marker in pageStarts[page.number] ?? const <_Marker>[]) {
      current = open(marker);
      paragraph = null;
    }
    for (final (index, line) in page.lines.indexed) {
      final marker = markerAt[(page.number, index)];
      if (marker != null) {
        current = open(marker);
        paragraph = null;
        previousLine = line;
        continue;
      }
      final text = line.text.trim();
      if (text.isEmpty) {
        paragraph = null;
        continue;
      }
      final startsNew =
          paragraph == null ||
          (previousLine != null &&
              _isParagraphBreak(previousLine, line, bodyHeight)) ||
          _isListItem(text);
      if (startsNew) {
        paragraph = Paragraph(
          text,
          pageStart: page.number,
          pageEnd: page.number,
        );
        current.paragraphs.add(paragraph);
      } else {
        paragraph.text = joinLines(paragraph.text, text);
        paragraph.pageEnd = page.number;
      }
      previousLine = line;
    }
    // A paragraph continues onto the next page only mid-sentence.
    if (paragraph != null && endsSentence(paragraph.text)) paragraph = null;
    previousLine = null;
  }

  _assignPageEnds(root);
  return root;
}

class _Marker {
  _Marker({
    required this.title,
    required this.level,
    required this.page,
    this.lineIndex = -1,
  });

  final String title;
  final int level;
  final int page;

  /// Line on [page] that holds the heading, or -1 for the top of the page.
  final int lineIndex;
}

List<_Marker> _headingMarkers(ExtractedDocument doc) {
  if (doc.outline.length >= 2) return _outlineMarkers(doc);
  final markdown = [
    for (final page in doc.pages)
      for (final (index, line) in page.lines.indexed)
        if (line.headingLevel != null)
          _Marker(
            title: line.text.trim(),
            level: line.headingLevel!,
            page: page.number,
            lineIndex: index,
          ),
  ];
  if (markdown.isNotEmpty || doc.isPlainText) return markdown;
  return _detectedHeadingMarkers(doc.pages);
}

/// Places each outline entry on the line of its page that holds its title.
List<_Marker> _outlineMarkers(ExtractedDocument doc) {
  final byNumber = {for (final page in doc.pages) page.number: page};
  final used = <(int, int)>{};
  return [
    for (final entry in doc.outline)
      if (byNumber.containsKey(entry.page))
        () {
          final page = byNumber[entry.page]!;
          final wanted = _titleKey(entry.title);
          var lineIndex = -1;
          for (final (index, line) in page.lines.indexed) {
            final key = _titleKey(line.text);
            if (key.isEmpty || used.contains((page.number, index))) continue;
            if (key == wanted ||
                (wanted.length > 8 &&
                    (key.startsWith(wanted) || wanted.startsWith(key)) &&
                    key.length * 2 > wanted.length)) {
              lineIndex = index;
              used.add((page.number, index));
              break;
            }
          }
          return _Marker(
            title: entry.title.trim(),
            level: entry.level,
            page: entry.page,
            lineIndex: lineIndex,
          );
        }(),
  ];
}

String _titleKey(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

final _numbered = RegExp(r'^((\d+)(\.\d+){0,3})\.?\s+\S');
final _chapterWord = RegExp(
  r'^(chapter|chapitre|capítulo|kapitel|part|partie|unit|section|lesson)\s+\w+',
  caseSensitive: false,
);

/// Finds heading lines by glyph height and numbering.
List<_Marker> _detectedHeadingMarkers(List<PageText> pages) {
  final body = _bodyLineHeight(pages);
  if (body <= 0) return const [];

  final candidates = <(int page, int index, TextLine line)>[];
  for (final page in pages) {
    for (final (index, line) in page.lines.indexed) {
      if (_looksLikeHeading(line, body)) {
        candidates.add((page.number, index, line));
      }
    }
  }
  // Too many "headings" means the heuristic is reading body text.
  final totalLines = pages.fold<int>(0, (n, p) => n + p.lines.length);
  if (candidates.isEmpty ||
      candidates.length > math.max(12, totalLines * 0.25)) {
    return const [];
  }

  // Bigger text = higher level. Glyph boxes vary with the letters in a line
  // (descenders, capitals), so heights within 20% of a group's tallest
  // member share its level.
  final tall = [
    for (final c in candidates)
      if (c.$3.height >= body * 1.15) c.$3.height,
  ]..sort((a, b) => b.compareTo(a));
  final groupTops = <double>[];
  for (final height in tall) {
    if (groupTops.isEmpty || height < groupTops.last * 0.8) {
      groupTops.add(height);
    }
  }
  int levelOf(TextLine line) {
    final numbering = _numbered.firstMatch(line.text.trim());
    if (numbering != null) {
      return '.'.allMatches(numbering.group(1)!).length + 1;
    }
    for (final (index, top) in groupTops.indexed) {
      if (line.height >= top * 0.8) return math.min(index + 1, 4);
    }
    return math.min(groupTops.length + 1, 4);
  }

  return [
    for (final (page, index, line) in candidates)
      _Marker(
        title: line.text.trim(),
        level: levelOf(line),
        page: page,
        lineIndex: index,
      ),
  ];
}

bool _looksLikeHeading(TextLine line, double bodyHeight) {
  final text = line.text.trim();
  if (text.length < 2 || text.length > 100) return false;
  if (!RegExp(r'\p{L}', unicode: true).hasMatch(text)) return false;
  if (RegExp(r'[.,;:]$').hasMatch(text)) return false;
  // Contents-page entries ("2 Energy ........ 4") are not headings.
  if (RegExp(r'(\.\s?){4,}').hasMatch(text)) return false;
  final taller = line.height >= bodyHeight * 1.15;
  final numbered =
      _numbered.hasMatch(text) &&
      text.split(' ').length <= 12 &&
      !RegExp(r'^\d+(\.\d+)?\s*%').hasMatch(text);
  return taller ||
      (numbered && line.height >= bodyHeight * 0.95) ||
      _chapterWord.hasMatch(text) && text.split(' ').length <= 8;
}

/// The most common line height, weighted by characters: the body text size.
double _bodyLineHeight(List<PageText> pages) {
  final weight = <double, int>{};
  for (final page in pages) {
    for (final line in page.lines) {
      if (line.height <= 0) continue;
      final key = (line.height * 2).roundToDouble() / 2;
      weight[key] = (weight[key] ?? 0) + line.text.length;
    }
  }
  if (weight.isEmpty) return 0;
  return weight.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

/// A vertical gap clearly larger than normal line spacing, or a jump back up
/// the page (a new column), starts a new paragraph.
bool _isParagraphBreak(TextLine previous, TextLine line, double bodyHeight) {
  if (previous.height <= 0 || line.height <= 0) {
    // Plain text: the reader marks paragraph breaks with empty lines.
    return false;
  }
  final gap = line.top - previous.top;
  if (gap < 0) return true;
  final spacing = math.max(bodyHeight, previous.height) * 1.9;
  if (gap > spacing) return true;
  // An indented first line after a finished sentence.
  return endsSentence(previous.text) &&
      line.left > previous.left + math.max(bodyHeight, 4) * 1.2;
}

bool _isListItem(String text) =>
    RegExp(r'^([•▪◦\-–*]|\(?[0-9]{1,2}[.)]|\(?[a-z][.)])\s').hasMatch(text);

/// A section ends on the last page that holds its own text or its
/// subsections' text.
int _assignPageEnds(SectionNode node) {
  var end = node.pageStart;
  for (final paragraph in node.paragraphs) {
    end = math.max(end, paragraph.pageEnd);
  }
  for (final child in node.children) {
    end = math.max(end, _assignPageEnds(child));
  }
  node.pageEnd = end;
  return end;
}
