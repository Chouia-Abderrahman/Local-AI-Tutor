/// Text comparison for verification: a tolerant quote search that maps
/// back to the source text, content words, and a similarity score.
library;

import 'dart:math' as math;

/// A located quote: the span of the source that matched, and how closely.
class QuoteMatch {
  const QuoteMatch({
    required this.start,
    required this.end,
    required this.text,
    required this.score,
  });

  /// Offsets into the source text.
  final int start;
  final int end;

  /// The source's own text for the span (not the model's copy).
  final String text;

  /// 1.0 for an exact match after normalization.
  final double score;

  bool get isExact => score >= 1.0;
}

const _quoteMap = {
  '‘': "'",
  '’': "'",
  '‚': "'",
  '‛': "'",
  '′': "'",
  '`': "'",
  '´': "'",
  '“': '"',
  '”': '"',
  '„': '"',
  '«': '"',
  '»': '"',
  '″': '"',
};
const _dashes = {'‐', '‑', '‒', '–', '—', '―', '−'};

bool _isSpace(int c) =>
    c == 0x20 ||
    (c >= 0x09 && c <= 0x0D) ||
    c == 0xA0 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000;

class _Normalized {
  _Normalized(this.text, this.source);

  final String text;

  /// For each character of [text], its index in the original string.
  final List<int> source;
}

_Normalized _normalize(String input) {
  final out = StringBuffer();
  final source = <int>[];
  var pendingSpace = false;
  for (var i = 0; i < input.length; i++) {
    final unit = input.codeUnitAt(i);
    if (_isSpace(unit)) {
      pendingSpace = out.isNotEmpty;
      continue;
    }
    if (pendingSpace) {
      out.write(' ');
      source.add(i);
      pendingSpace = false;
    }
    var char = input[i];
    char = _quoteMap[char] ?? (_dashes.contains(char) ? '-' : char);
    final lower = char.toLowerCase();
    for (var k = 0; k < lower.length; k++) {
      out.write(lower[k]);
      source.add(i);
    }
  }
  return _Normalized(out.toString(), source);
}

/// Lowercase, straight quotes, plain hyphens, single spaces, trimmed.
String normalizeForMatch(String text) => _normalize(text).text;

/// Removes what models wrap around a copied sentence: quotation marks,
/// ellipses and surrounding whitespace.
String stripQuoteWrapping(String text) => text
    .trim()
    .replaceAll(RegExp('^[\\s"\'“”‘’«»„]+|[\\s"\'“”‘’«»„]+\$'), '')
    .replaceAll(RegExp(r'^(\.\.\.|…)\s*|\s*(\.\.\.|…)$'), '')
    .trim();

final _token = RegExp(r'[\p{L}\p{N}]+', unicode: true);

const _negations = {
  'not', 'no', 'never', 'none', 'cannot', "n't", 'without', //
  'ne', 'pas', 'jamais', 'aucun', 'aucune', 'sans',
  'nunca', 'ningún', 'ninguna', 'sin',
  'nicht', 'kein', 'keine', 'nie', 'ohne',
  'non', 'mai', 'senza',
  'não',
};

/// Finds [quote] in [source]. Tries an exact match after normalization,
/// then a word-level fuzzy match (F-score of the longest common word
/// subsequence) of at least [minScore]. A fuzzy match is refused when the
/// two disagree on negation words, since one "not" can flip a sentence.
QuoteMatch? findQuote(String source, String quote, {double minScore = 0.85}) {
  final cleaned = stripQuoteWrapping(quote);
  if (cleaned.isEmpty) return null;
  final hay = _normalize(source);
  final needle = _normalize(cleaned).text.replaceAll(RegExp(r'[.;,:]+$'), '');
  if (needle.length < 8) return null;

  final exact = hay.text.indexOf(needle);
  if (exact >= 0) {
    return _match(source, hay, exact, exact + needle.length, 1.0);
  }

  final hayTokens = _token.allMatches(hay.text).toList();
  final quoteTokens = [for (final m in _token.allMatches(needle)) m.group(0)!];
  final n = quoteTokens.length;
  if (n < 3 || hayTokens.isEmpty) return null;

  QuoteMatch? best;
  final anchors = quoteTokens.take(3).toList();
  for (var i = 0; i < hayTokens.length; i++) {
    final anchorIndex = anchors.indexOf(hayTokens[i].group(0)!);
    if (anchorIndex < 0) continue;
    final start = i - anchorIndex;
    if (start < 0) continue;
    for (final length in {
      n,
      (n * 0.85).floor(),
      (n * 1.15).ceil(),
      n - 1,
      n + 1,
    }) {
      if (length < 3 || start + length > hayTokens.length) continue;
      final window = [
        for (var k = start; k < start + length; k++) hayTokens[k].group(0)!,
      ];
      final common = _lcs(quoteTokens, window);
      final score = 2 * common / (n + length);
      if (score < minScore || (best != null && score <= best.score)) continue;
      if (_negationsDiffer(quoteTokens, window)) continue;
      best = _match(
        source,
        hay,
        hayTokens[start].start,
        hayTokens[start + length - 1].end,
        score,
      );
    }
  }
  return best;
}

QuoteMatch _match(
  String source,
  _Normalized hay,
  int normStart,
  int normEnd,
  double score,
) {
  final start = hay.source[normStart];
  var end = hay.source[normEnd - 1] + 1;
  // Extend to include sentence punctuation right after the match.
  while (end < source.length && '.!?'.contains(source[end])) {
    end++;
  }
  return QuoteMatch(
    start: start,
    end: end,
    text: source.substring(start, end),
    score: score,
  );
}

bool _negationsDiffer(List<String> a, List<String> b) {
  bool has(List<String> tokens) =>
      tokens.any((t) => _negations.contains(t) || t.endsWith("n't"));
  return has(a) != has(b);
}

int _lcs(List<String> a, List<String> b) {
  var previous = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0);
    for (var j = 1; j <= b.length; j++) {
      current[j] = a[i - 1] == b[j - 1]
          ? previous[j - 1] + 1
          : math.max(previous[j], current[j - 1]);
    }
    previous = current;
  }
  return previous[b.length];
}

const _stopwords = {
  // English
  'a', 'an', 'the', 'and', 'or', 'but', 'of', 'to', 'in', 'on', 'at', 'by',
  'for', 'with', 'from', 'as', 'is', 'are', 'was', 'were', 'be', 'been',
  'being', 'it', 'its', 'this', 'that', 'these', 'those', 'which', 'what',
  'who', 'whom', 'when', 'where', 'why', 'how', 'into', 'than', 'then',
  'there', 'their', 'they', 'them', 'he', 'she', 'his', 'her', 'we', 'you',
  'your', 'our', 'has', 'have', 'had', 'do', 'does', 'did', 'can', 'could',
  'will', 'would', 'should', 'may', 'might', 'must', 'also', 'such', 'so',
  'if', 'about', 'some', 'any', 'each', 'other', 'more', 'most', 'very',
  'one', 'ones',
  // French
  'le', 'la', 'les', 'un', 'une', 'des', 'du', 'de', 'et', 'ou', 'est',
  'sont', 'dans', 'en', 'au', 'aux', 'par', 'pour', 'sur', 'avec', 'que',
  'qui', 'ce', 'cette', 'ces', 'se', 'sa', 'son', 'ses', 'il', 'elle',
  // Spanish
  'el', 'los', 'las', 'unos', 'unas', 'del', 'al', 'y', 'o', 'es',
  'por', 'para', 'con', 'como', 'su', 'sus', 'lo',
  // German
  'der', 'die', 'das', 'und', 'oder', 'ist', 'sind', 'ein', 'eine', 'den',
  'dem', 'mit', 'von', 'zu', 'im', 'auf', 'für',
};

/// Lowercased content words in order, lightly stemmed (a trailing plural
/// "s" is dropped), without stopwords. Numbers count as content.
///
/// With [stem] false the words are kept as written (lowercased), for
/// queries sent to search engines.
List<String> contentSequence(String text, {bool stem = true}) => [
  for (final match in _token.allMatches(normalizeForMatch(text)))
    if (!_stopwords.contains(match.group(0)!) &&
        (match.group(0)!.length >= 3 ||
            RegExp(r'\d').hasMatch(match.group(0)!)))
      stem ? _stem(match.group(0)!) : match.group(0)!,
];

String _stem(String word) =>
    word.length > 4 && word.endsWith('s') && !word.endsWith('ss')
    ? word.substring(0, word.length - 1)
    : word;

/// The set of [contentSequence].
Set<String> contentWords(String text) => contentSequence(text).toSet();

/// Order-aware closeness of two short texts: F-score of the longest common
/// subsequence of their content words. "From lower to higher" and "from
/// higher to lower" share every word but score 0.5.
double sequenceSimilarity(String a, String b) {
  final x = contentSequence(a);
  final y = contentSequence(b);
  if (x.isEmpty || y.isEmpty) {
    return normalizeForMatch(a) == normalizeForMatch(b) ? 1 : 0;
  }
  return 2 * _lcs(x, y) / (x.length + y.length);
}

/// Dice coefficient of content words: 1 for the same words, 0 for none
/// shared.
double similarity(String a, String b) {
  final x = contentWords(a);
  final y = contentWords(b);
  if (x.isEmpty && y.isEmpty) {
    return normalizeForMatch(a) == normalizeForMatch(b) ? 1 : 0;
  }
  if (x.isEmpty || y.isEmpty) return 0;
  return 2 * x.intersection(y).length / (x.length + y.length);
}

/// Share of [part]'s content words that also occur in [whole] (1 when
/// [part] has none).
double coverage(String part, String whole) {
  final x = contentWords(part);
  if (x.isEmpty) return 1;
  final y = contentWords(whole);
  return x.where(y.contains).length / x.length;
}

/// Whether [phrase] occurs in [text] as whole words, ignoring case.
bool containsPhrase(String text, String phrase) {
  final p = normalizeForMatch(phrase);
  if (p.isEmpty) return false;
  final pattern = RegExp(
    '(?<![\\p{L}\\p{N}])${RegExp.escape(p)}(?![\\p{L}\\p{N}])',
    unicode: true,
  );
  return pattern.hasMatch(normalizeForMatch(text));
}
