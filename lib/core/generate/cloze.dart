import '../text/matching.dart';

class Cloze {
  const Cloze({required this.prompt, required this.answer});

  /// The source sentence with the key term replaced by a blank.
  final String prompt;

  /// The key term exactly as it appears in the sentence.
  final String answer;
}

const clozeBlank = '_____';

/// Builds a fill-in-the-blank card from a verified source sentence by
/// blanking its key term. No model call, so it can't invent anything.
/// Returns null when the term is missing, appears more than once, is only
/// stopwords, or is most of the sentence.
Cloze? buildCloze(String sentence, String keyTerm) {
  final term = stripQuoteWrapping(keyTerm);
  if (term.isEmpty || contentWords(term).isEmpty) return null;
  if (term.split(RegExp(r'\s+')).length > 5) return null;
  if (term.length * 2 > sentence.length) return null;

  final pattern = RegExp(
    '(?<![\\p{L}\\p{N}])${_flexible(term)}(?![\\p{L}\\p{N}])',
    caseSensitive: false,
    unicode: true,
  );
  final matches = pattern.allMatches(sentence).toList();
  if (matches.length != 1) return null;
  final match = matches.single;
  return Cloze(
    prompt:
        '${sentence.substring(0, match.start)}$clozeBlank'
        '${sentence.substring(match.end)}',
    answer: sentence.substring(match.start, match.end),
  );
}

/// Escapes [term] for a regex, letting any run of whitespace match.
String _flexible(String term) =>
    term.split(RegExp(r'\s+')).map(RegExp.escape).join(r'\s+');
