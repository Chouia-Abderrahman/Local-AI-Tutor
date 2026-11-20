import 'chunker.dart';
import 'content_kind.dart';
import 'extracted.dart';
import 'language.dart';
import 'structure.dart';
import 'text_cleanup.dart';

/// A document after cleanup, structuring and chunking, ready to store.
class ProcessedDocument {
  const ProcessedDocument({
    required this.root,
    required this.chunks,
    required this.language,
    required this.pageCount,
    required this.nearlyEmptyPages,
  });

  /// Root of the section tree. Its own paragraphs (text before the first
  /// heading) are stored as a section named after the document.
  final SectionNode root;
  final List<ChunkDraft> chunks;
  final String language;
  final int pageCount;

  /// Pages with almost no text: probably scanned, candidates for OCR.
  final List<int> nearlyEmptyPages;

  Iterable<ChunkDraft> get studyChunks => chunks.where((c) => c.kind.isStudy);
}

ProcessedDocument processDocument(ExtractedDocument doc) {
  final pages = doc.isPlainText
      ? doc.pages
      : removeRunningHeadersAndFooters(doc.pages);
  final root = buildStructure(
    ExtractedDocument(
      title: doc.title,
      pages: pages,
      outline: doc.outline,
      isPlainText: doc.isPlainText,
    ),
  );

  final chunks = <ChunkDraft>[];
  for (final node in [root, ...root.descendants]) {
    for (final chunk in chunkSection(node, breakAtPages: node.level == 0)) {
      chunk.kind = classifyChunk(
        text: chunk.text,
        headingPath: node.level == 0 ? [doc.title] : node.path,
        pageStart: chunk.pageStart,
        documentPages: pages.length,
      );
      chunks.add(chunk);
    }
  }

  final sample = StringBuffer();
  for (final chunk in chunks.where((c) => c.kind.isStudy)) {
    if (sample.length > 20000) break;
    sample.writeln(chunk.text);
  }

  return ProcessedDocument(
    root: root,
    chunks: chunks,
    language: detectLanguage(sample.toString()),
    pageCount: doc.pages.length,
    nearlyEmptyPages: [
      if (!doc.isPlainText)
        for (final page in doc.pages)
          if (page.charCount < 20) page.number,
    ],
  );
}
