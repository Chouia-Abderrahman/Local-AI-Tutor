import 'package:drift/drift.dart';

import '../db/database.dart';
import '../ingest/content_kind.dart';
import '../text/matching.dart';

/// A passage found for a question.
class Excerpt {
  const Excerpt({
    required this.chunkId,
    required this.sectionId,
    required this.headingPath,
    required this.pageStart,
    required this.pageEnd,
    required this.text,
    required this.score,
  });

  final int chunkId;
  final int sectionId;
  final String headingPath;
  final int pageStart;
  final int pageEnd;
  final String text;

  /// BM25 relevance (higher is better).
  final double score;

  String get pages =>
      pageStart == pageEnd ? 'p. $pageStart' : 'pp. $pageStart–$pageEnd';
}

/// Builds an FTS5 query: content words OR-ed, each as a prefix so "osmotic"
/// finds "osmosis"-like stems ("osmo*" would be too loose, so the stem keeps
/// at least five letters). Returns null when the question has no usable
/// words.
String? ftsQuery(String question) {
  final words = contentSequence(question).toSet();
  if (words.isEmpty) return null;
  return words
      .map((w) {
        final safe = w.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
        if (safe.isEmpty) return null;
        final stem = safe.length > 6
            ? safe.substring(0, safe.length - 2)
            : safe;
        return '"$stem"*';
      })
      .whereType<String>()
      .join(' OR ');
}

/// Finds the study passages of a document most relevant to [question],
/// using the FTS5 index (BM25). Works offline with no extra model.
class Retriever {
  Retriever(this.db);

  final AppDatabase db;

  Future<List<Excerpt>> search(
    int documentId,
    String question, {
    int limit = 4,
  }) async {
    final query = ftsQuery(question);
    if (query == null) return const [];
    final rows = await db
        .customSelect(
          'SELECT c.id, c.section_id, c.heading_path, c.page_start, '
          'c.page_end, c.body, -bm25(chunks_fts, 1.0, 0.5) AS score '
          'FROM chunks_fts JOIN chunks c ON c.id = chunks_fts.rowid '
          'WHERE chunks_fts MATCH ? AND c.document_id = ? AND c.kind = ? '
          'ORDER BY score DESC LIMIT ?',
          variables: [
            Variable.withString(query),
            Variable.withInt(documentId),
            Variable.withString(ContentKind.study.name),
            Variable.withInt(limit),
          ],
          readsFrom: {db.chunks},
        )
        .get();
    return [
      for (final r in rows)
        Excerpt(
          chunkId: r.read<int>('id'),
          sectionId: r.read<int>('section_id'),
          headingPath: r.read<String>('heading_path'),
          pageStart: r.read<int>('page_start'),
          pageEnd: r.read<int>('page_end'),
          text: r.read<String>('body'),
          score: r.read<double>('score'),
        ),
    ];
  }
}

/// A sentence of an answer and whether the excerpts back it up.
class AnswerSentence {
  const AnswerSentence(this.text, {required this.supported});

  final String text;
  final bool supported;
}

/// Splits [answer] into sentences and marks those whose content words are
/// mostly absent from the excerpts, or that cite an excerpt that wasn't
/// given (small models invent "[5]" when there were three). A cheap check:
/// it catches added knowledge, not subtle misreadings.
List<AnswerSentence> checkGrounding(String answer, List<Excerpt> excerpts) {
  final source = excerpts.map((e) => '${e.headingPath} ${e.text}').join(' ');
  final sentences = answer
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((s) => s.trim().isNotEmpty);
  return [
    for (final sentence in sentences)
      () {
        final cited = citedNumbers(sentence);
        final bogusCitation = cited.any((n) => n < 1 || n > excerpts.length);
        final plain = sentence.replaceAll(RegExp(r'\[\d+\]'), '');
        final supported =
            !bogusCitation &&
            (contentWords(plain).length < 3 || coverage(plain, source) >= 0.5);
        return AnswerSentence(sentence, supported: supported);
      }(),
  ];
}

/// True when most of the answer is not backed by the excerpts: the
/// document doesn't really cover the question, whatever the model said.
bool mostlyUnsupported(List<AnswerSentence> sentences) {
  final substantive = sentences
      .where((s) => contentWords(s.text).length >= 3)
      .toList();
  if (substantive.isEmpty) return false;
  return substantive.where((s) => !s.supported).length * 2 >=
      substantive.length;
}

/// Excerpt numbers cited in [answer] as "[n]".
Set<int> citedNumbers(String answer) => {
  for (final m in RegExp(r'\[(\d+)\]').allMatches(answer))
    int.parse(m.group(1)!),
};
