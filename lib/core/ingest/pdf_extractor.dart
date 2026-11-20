import 'package:pdfrx/pdfrx.dart';

import 'extracted.dart';
import 'ocr.dart';
import 'text_cleanup.dart';

/// Reads a PDF's text (in reading order, one [TextLine] per line) and its
/// bookmarks, using PDFium through pdfrx.
///
/// In the app, `pdfrxFlutterInitialize()` must run before this is used.
class PdfExtractor {
  /// With [ocr], pages with almost no text (scanned pages) are read by
  /// text recognition instead.
  static Future<ExtractedDocument> extract(
    String path, {
    required String title,
    void Function(int done, int total)? onProgress,
    PageOcr? ocr,
  }) async {
    final doc = await PdfDocument.openFile(path);
    try {
      final pages = <PageText>[];
      final total = doc.pages.length;
      for (final page in doc.pages) {
        final text = await page.loadStructuredText();
        var pageText = _pageText(page, text);
        if (ocr != null && pageText.charCount < 20) {
          try {
            final lines = await ocr.readPage(doc, page.pageNumber);
            if (lines.isNotEmpty) {
              pageText = PageText(
                number: page.pageNumber,
                width: page.width,
                height: page.height,
                lines: lines,
                hasImages: true,
              );
            }
          } on Object {
            // Keep the empty page; the import reports it as unreadable.
          }
        }
        pages.add(pageText);
        onProgress?.call(page.pageNumber, total);
      }
      final outline = <OutlineEntry>[];
      void walk(List<PdfOutlineNode> nodes, int level) {
        for (final node in nodes) {
          final page = node.dest?.pageNumber;
          final title = normalizeLine(node.title);
          if (page != null && page >= 1 && page <= total && title.isNotEmpty) {
            outline.add(OutlineEntry(title: title, page: page, level: level));
          }
          walk(node.children, level + 1);
        }
      }

      walk(await doc.loadOutline(), 1);
      return ExtractedDocument(title: title, pages: pages, outline: outline);
    } finally {
      await doc.dispose();
    }
  }

  static PageText _pageText(PdfPage page, PdfPageText text) {
    final full = text.fullText;
    final rects = text.charRects;
    final lines = <TextLine>[];
    var start = 0;
    for (var i = 0; i <= full.length; i++) {
      final atBreak = i == full.length || full[i] == '\n' || full[i] == '\r';
      if (!atBreak) continue;
      if (i > start) {
        final line = normalizeLine(full.substring(start, i));
        if (line.isNotEmpty) {
          lines.add(_withGeometry(line, rects, start, i, page.height));
        }
      }
      start = i + 1;
    }
    final chars = lines.fold<int>(0, (n, l) => n + l.text.length);
    return PageText(
      number: page.pageNumber,
      width: page.width,
      height: page.height,
      lines: lines,
      // pdfrx doesn't list page images; a page with almost no text is
      // treated as possibly scanned and offered to OCR.
      hasImages: chars < 20,
    );
  }

  static TextLine _withGeometry(
    String text,
    List<PdfRect> rects,
    int start,
    int end,
    double pageHeight,
  ) {
    if (rects.length < end) return TextLine(text);
    final heights = <double>[];
    var top = double.infinity;
    var left = double.infinity;
    for (var i = start; i < end; i++) {
      final rect = rects[i];
      if (rect.height <= 0) continue;
      heights.add(rect.height);
      if (rect.left < left) left = rect.left;
      // PDF coordinates grow upward; store distance from the page top.
      final fromTop = pageHeight - rect.top;
      if (fromTop < top) top = fromTop;
    }
    if (heights.isEmpty) return TextLine(text);
    heights.sort();
    return TextLine(
      text,
      top: top,
      left: left,
      height: heights[heights.length ~/ 2],
    );
  }
}
