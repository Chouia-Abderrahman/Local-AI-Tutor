/// Whether a chunk is worth writing questions about.
enum ContentKind {
  study,
  toc,
  bookIndex,
  refs,
  front,
  math;

  bool get isStudy => this == ContentKind.study;

  /// Why the chunk is skipped, for the outline screen.
  String get label => switch (this) {
    ContentKind.study => 'Study material',
    ContentKind.toc => 'Table of contents',
    ContentKind.bookIndex => 'Index',
    ContentKind.refs => 'References',
    ContentKind.front => 'Front matter',
    ContentKind.math => 'Mostly symbols',
  };
}

final _tocTitle = RegExp(
  r'^((table of )?contents|sommaire|table des mati[eè]res|[ií]ndice|contenidos?'
  r'|inhalt(sverzeichnis)?|sumario|المحتويات|فهرس المحتويات)$',
  caseSensitive: false,
);
final _refsTitle = RegExp(
  r'^(references|bibliography|works cited|sources|further reading'
  r'|r[ée]f[ée]rences( bibliographiques)?|bibliographie|referencias'
  r'|bibliograf[ií]a|literatur(verzeichnis)?|riferimenti|المراجع|المصادر)$',
  caseSensitive: false,
);
final _indexTitle = RegExp(
  r'^(index|subject index|indice anal[ií]tico|register|stichwortverzeichnis'
  r'|الفهرس)$',
  caseSensitive: false,
);
final _dotLeader = RegExp(r'(\.\s?){4,}\s*\d+|\s{3,}\d+\s*$', multiLine: true);
final _citation = RegExp(
  r'\(\d{4}[a-z]?\)|\bet al\.|\bdoi:|https?://|\bpp?\.\s?\d+|\bvol\.\s?\d+',
  caseSensitive: false,
);
final _indexEntry = RegExp(
  r'\p{L}[\p{L}\s-]{1,40},\s*\d+(\s*[,–-]\s*\d+)*',
  unicode: true,
);
final _frontMatter = RegExp(
  r'copyright|©|\bisbn\b|all rights reserved|printed in|library of congress'
  r'|tous droits réservés|dépôt légal|todos los derechos',
  caseSensitive: false,
);

/// Classifies a chunk by its section title first, then by its text.
ContentKind classifyChunk({
  required String text,
  required List<String> headingPath,
  required int pageStart,
  required int documentPages,
}) {
  for (final heading in headingPath.reversed) {
    final title = heading
        .toLowerCase()
        .replaceAll(RegExp(r'^[\d.\s]+'), '')
        .trim();
    if (_tocTitle.hasMatch(title)) return ContentKind.toc;
    if (_refsTitle.hasMatch(title)) return ContentKind.refs;
    if (_indexTitle.hasMatch(title)) return ContentKind.bookIndex;
  }

  final words = RegExp(r'\S+').allMatches(text).length;
  if (words == 0) return ContentKind.front;
  final per100 = 100 / words;

  if (_dotLeader.allMatches(text).length >= 3) return ContentKind.toc;
  if (_citation.allMatches(text).length * per100 >= 3) return ContentKind.refs;
  if (_indexEntry.allMatches(text).length * per100 >= 8) {
    return ContentKind.bookIndex;
  }
  if (pageStart <= 3 &&
      documentPages > 4 &&
      words < 250 &&
      _frontMatter.hasMatch(text)) {
    return ContentKind.front;
  }

  final letters = RegExp(r'\p{L}', unicode: true).allMatches(text).length;
  final nonSpace = text.replaceAll(RegExp(r'\s'), '').length;
  if (nonSpace > 40 && letters / nonSpace < 0.55) return ContentKind.math;

  return ContentKind.study;
}
