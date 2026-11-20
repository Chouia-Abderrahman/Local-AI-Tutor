/// Text pulled out of a file, before cleanup and structuring.
///
/// PDF extraction fills in line geometry (position and glyph height), which
/// heading detection uses. Plain text and Markdown set [TextLine.headingLevel]
/// directly instead.
library;

class TextLine {
  const TextLine(
    this.text, {
    this.top = 0,
    this.left = 0,
    this.height = 0,
    this.headingLevel,
  });

  final String text;

  /// Distance from the top of the page, in PDF points.
  final double top;
  final double left;

  /// Median glyph height, roughly the font size. 0 when unknown.
  final double height;

  /// Set by the plain-text reader for Markdown headings (1 = top level).
  final int? headingLevel;

  TextLine copyWith({String? text, int? headingLevel}) => TextLine(
    text ?? this.text,
    top: top,
    left: left,
    height: height,
    headingLevel: headingLevel ?? this.headingLevel,
  );
}

class PageText {
  const PageText({
    required this.number,
    required this.lines,
    this.width = 0,
    this.height = 0,
    this.hasImages = false,
  });

  /// 1-based page number.
  final int number;
  final List<TextLine> lines;
  final double width;
  final double height;

  /// The page shows images; with almost no text it is probably scanned.
  final bool hasImages;

  int get charCount => lines.fold(0, (sum, line) => sum + line.text.length);
}

/// One PDF bookmark.
class OutlineEntry {
  const OutlineEntry({
    required this.title,
    required this.page,
    required this.level,
  });

  final String title;

  /// 1-based page the bookmark points to.
  final int page;

  /// 1 = top level.
  final int level;
}

class ExtractedDocument {
  const ExtractedDocument({
    required this.title,
    required this.pages,
    this.outline = const [],
    this.isPlainText = false,
  });

  final String title;
  final List<PageText> pages;
  final List<OutlineEntry> outline;
  final bool isPlainText;
}
