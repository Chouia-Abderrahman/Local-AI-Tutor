/// Detects a document's main language: by script for non-Latin text, by
/// common short words for Latin-script languages. Returns an ISO 639-1 code,
/// or `und` when unsure.
String detectLanguage(String text) {
  final sample = text.length > 20000 ? text.substring(0, 20000) : text;

  final scripts = <String, RegExp>{
    'ar': RegExp(r'[؀-ۿ]'),
    'ru': RegExp(r'[Ѐ-ӿ]'),
    'el': RegExp(r'[Ͱ-Ͽ]'),
    'he': RegExp(r'[֐-׿]'),
    'hi': RegExp(r'[ऀ-ॿ]'),
    'ja': RegExp(r'[぀-ヿ]'),
    'ko': RegExp(r'[가-힯]'),
    'zh': RegExp(r'[一-鿿]'),
  };
  final letters = RegExp(r'\p{L}', unicode: true).allMatches(sample).length;
  if (letters == 0) return 'und';
  for (final entry in scripts.entries) {
    if (entry.value.allMatches(sample).length / letters > 0.3) {
      // Japanese text mixes kana with Chinese characters.
      if (entry.key == 'zh' && scripts['ja']!.hasMatch(sample)) return 'ja';
      return entry.key;
    }
  }

  final words = RegExp(
    r"[\p{L}']+",
    unicode: true,
  ).allMatches(sample.toLowerCase()).map((m) => m.group(0)!).toList();
  if (words.length < 10) return 'und';
  var best = 'und';
  var bestScore = 0.0;
  for (final entry in _stopwords.entries) {
    final hits = words.where(entry.value.contains).length;
    final score = hits / words.length;
    if (score > bestScore) {
      best = entry.key;
      bestScore = score;
    }
  }
  return bestScore >= 0.08 ? best : 'und';
}

const _stopwords = {
  'en': {
    'the', 'and', 'of', 'to', 'is', 'in', 'that', 'it', 'for', 'are', //
    'with', 'as', 'this', 'by', 'from', 'which', 'be', 'or', 'an',
  },
  'fr': {
    'le', 'la', 'les', 'des', 'et', 'est', 'une', 'du', 'que', 'dans', //
    'pour', 'qui', 'sur', 'au', 'par', 'pas', 'ce', 'sont', 'aux',
  },
  'es': {
    'el', 'la', 'los', 'las', 'y', 'es', 'que', 'en', 'una', 'del', //
    'por', 'con', 'para', 'se', 'como', 'su', 'al', 'lo', 'son',
  },
  'de': {
    'der', 'die', 'das', 'und', 'ist', 'nicht', 'ein', 'eine', 'zu', //
    'mit', 'den', 'von', 'sich', 'auf', 'für', 'im', 'dem', 'des', 'werden',
  },
  'it': {
    'il', 'la', 'che', 'di', 'e', 'un', 'per', 'non', 'una', 'del', //
    'della', 'sono', 'con', 'gli', 'le', 'nel', 'si', 'da', 'è',
  },
  'pt': {
    'o', 'a', 'os', 'as', 'que', 'de', 'não', 'uma', 'um', 'do', 'da', //
    'em', 'para', 'com', 'por', 'se', 'mais', 'são', 'é',
  },
  'nl': {
    'de', 'het', 'een', 'en', 'van', 'is', 'dat', 'niet', 'op', 'te', //
    'zijn', 'met', 'voor', 'die', 'er', 'aan', 'ook', 'wordt',
  },
};
