import 'content_kind.dart';
import 'structure.dart';

/// A chunk before it is stored.
class ChunkDraft {
  ChunkDraft({
    required this.section,
    required this.text,
    required this.pageStart,
    required this.pageEnd,
  });

  final SectionNode section;
  final String text;
  final int pageStart;
  final int pageEnd;
  ContentKind kind = ContentKind.study;

  int get tokenEstimate => estimateTokens(text);
}

/// Rough model-token count without loading a tokenizer: about 1.35 tokens
/// per word in alphabetic scripts, and about one per CJK character.
int estimateTokens(String text) {
  final words = RegExp(r'\S+').allMatches(text).length;
  final cjk = RegExp(r'[぀-ヿ㐀-鿿가-힯]').allMatches(text).length;
  return (words * 1.35 + cjk * 0.9).ceil();
}

/// Packs a section's paragraphs into chunks of about [target] tokens, never
/// more than [max]. Sentences are never split, except one sentence longer
/// than [max] on its own. A short last chunk joins the one before it.
///
/// With [breakAtPages], a chunk never spans two pages. Used for text before
/// the first heading, where a title page, a contents page and a preface
/// must stay apart to be classified correctly.
List<ChunkDraft> chunkSection(
  SectionNode section, {
  int target = 450,
  int max = 650,
  int min = 120,
  bool breakAtPages = false,
}) {
  final pieces = [
    for (final paragraph in section.paragraphs)
      if (estimateTokens(paragraph.text) <= max)
        paragraph
      else
        ..._splitParagraph(paragraph, max),
  ];

  final chunks = <ChunkDraft>[];
  final buffer = <Paragraph>[];
  var tokens = 0;
  void flush() {
    if (buffer.isEmpty) return;
    chunks.add(
      ChunkDraft(
        section: section,
        text: buffer.map((p) => p.text).join('\n\n'),
        pageStart: buffer.first.pageStart,
        pageEnd: buffer.last.pageEnd,
      ),
    );
    buffer.clear();
    tokens = 0;
  }

  for (final piece in pieces) {
    final pieceTokens = estimateTokens(piece.text);
    if (buffer.isNotEmpty && tokens + pieceTokens > max) flush();
    if (breakAtPages &&
        buffer.isNotEmpty &&
        piece.pageStart != buffer.last.pageEnd) {
      flush();
    }
    buffer.add(piece);
    tokens += pieceTokens;
    if (tokens >= target) flush();
  }
  flush();

  if (chunks.length >= 2 && !breakAtPages) {
    final last = chunks.last;
    final previous = chunks[chunks.length - 2];
    if (last.tokenEstimate < min &&
        previous.tokenEstimate + last.tokenEstimate <= max * 1.25) {
      chunks
        ..removeLast()
        ..removeLast()
        ..add(
          ChunkDraft(
            section: section,
            text: '${previous.text}\n\n${last.text}',
            pageStart: previous.pageStart,
            pageEnd: last.pageEnd,
          ),
        );
    }
  }
  return chunks;
}

final _sentenceEnd = RegExp(r'(?<=[.!?…。！？])["”’)\]]*\s+');

/// Splits text into sentences. Good enough for chunk boundaries; it can
/// split after abbreviations like "e.g.", which only moves a boundary.
List<String> splitSentences(String text) {
  final sentences = <String>[];
  var start = 0;
  for (final match in _sentenceEnd.allMatches(text)) {
    final sentence = text.substring(start, match.end).trim();
    if (sentence.isNotEmpty) sentences.add(sentence);
    start = match.end;
  }
  final rest = text.substring(start).trim();
  if (rest.isNotEmpty) sentences.add(rest);
  return sentences;
}

List<Paragraph> _splitParagraph(Paragraph paragraph, int max) {
  final parts = <Paragraph>[];
  final buffer = StringBuffer();
  var tokens = 0;
  void flush() {
    if (buffer.isEmpty) return;
    parts.add(
      Paragraph(
        buffer.toString().trim(),
        pageStart: paragraph.pageStart,
        pageEnd: paragraph.pageEnd,
      ),
    );
    buffer.clear();
    tokens = 0;
  }

  for (final sentence in splitSentences(paragraph.text)) {
    final sentenceTokens = estimateTokens(sentence);
    if (sentenceTokens > max) {
      flush();
      // One enormous "sentence" (often a table or a list): cut by words.
      final words = sentence.split(RegExp(r'\s+'));
      final perPart = (max / 1.35).floor();
      for (var i = 0; i < words.length; i += perPart) {
        buffer.write(words.skip(i).take(perPart).join(' '));
        flush();
      }
      continue;
    }
    if (tokens + sentenceTokens > max) flush();
    buffer.write(buffer.isEmpty ? sentence : ' $sentence');
    tokens += sentenceTokens;
  }
  flush();
  return parts;
}
