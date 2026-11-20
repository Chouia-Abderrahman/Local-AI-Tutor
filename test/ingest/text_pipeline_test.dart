import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/ingest/chunker.dart';
import 'package:pdf_study_assistant/core/ingest/content_kind.dart';
import 'package:pdf_study_assistant/core/ingest/extracted.dart';
import 'package:pdf_study_assistant/core/ingest/language.dart';
import 'package:pdf_study_assistant/core/ingest/pipeline.dart';
import 'package:pdf_study_assistant/core/ingest/plain_text.dart';
import 'package:pdf_study_assistant/core/ingest/structure.dart';
import 'package:pdf_study_assistant/core/ingest/text_cleanup.dart';

TextLine _line(
  String text,
  double top, {
  double height = 10,
  double left = 72,
}) => TextLine(text, top: top, left: left, height: height);

void main() {
  group('cleanup', () {
    test('normalizeLine fixes ligatures and odd spaces', () {
      expect(normalizeLine('eﬃcient   de­fine​'), 'efficient define');
    });

    test('joinLines undoes end-of-line hyphenation only before lowercase', () {
      expect(joinLines('the exam-', 'ple shows'), 'the example shows');
      expect(joinLines('a well-', 'Known case'), 'a well- Known case');
      expect(joinLines('first', 'second'), 'first second');
    });

    test('running headers, footers and page numbers are removed', () {
      const topics = ['cells', 'osmosis', 'energy', 'enzymes', 'genes'];
      final pages = [
        for (var n = 1; n <= 5; n++)
          PageText(
            number: n,
            height: 800,
            lines: [
              _line('Biology Basics - Chapter $n', 20),
              _line('$n', 780),
              _line('Body text about ${topics[n - 1]}.', 100),
              _line('More about ${topics[n - 1]} here.', 115),
            ],
          ),
      ];
      final cleaned = removeRunningHeadersAndFooters(pages);
      for (final page in cleaned) {
        final topic = topics[page.number - 1];
        expect(page.lines.map((l) => l.text), [
          'Body text about $topic.',
          'More about $topic here.',
        ]);
      }
    });
  });

  group('structure', () {
    test('outline entries become nested sections at their heading lines', () {
      final doc = ExtractedDocument(
        title: 'Bio',
        outline: const [
          OutlineEntry(title: '1 Cells', page: 1, level: 1),
          OutlineEntry(title: '1.1 Membranes', page: 1, level: 2),
          OutlineEntry(title: '2 Energy', page: 2, level: 1),
        ],
        pages: [
          PageText(
            number: 1,
            height: 800,
            lines: [
              _line('Preface text before any heading.', 50),
              _line('1 Cells', 100, height: 16),
              _line('Intro to cells.', 130),
              _line('1.1 Membranes', 160, height: 12),
              _line('Membranes are lipid bilayers.', 190),
            ],
          ),
          PageText(
            number: 2,
            height: 800,
            lines: [
              _line('2 Energy', 100, height: 16),
              _line('ATP stores energy.', 130),
            ],
          ),
        ],
      );
      final root = buildStructure(doc);
      expect(root.paragraphs.single.text, 'Preface text before any heading.');
      expect(root.children.map((s) => s.title), ['1 Cells', '2 Energy']);
      final cells = root.children.first;
      expect(cells.paragraphs.single.text, 'Intro to cells.');
      expect(cells.children.single.title, '1.1 Membranes');
      expect(cells.children.single.path, ['1 Cells', '1.1 Membranes']);
      expect(
        cells.children.single.paragraphs.single.text,
        'Membranes are lipid bilayers.',
      );
      expect(root.children.last.pageStart, 2);
    });

    test('without an outline, taller and numbered lines become headings', () {
      final body = [
        for (var i = 0; i < 12; i++) 'Body line number $i keeps going here',
      ];
      final doc = ExtractedDocument(
        title: 'Bio',
        pages: [
          PageText(
            number: 1,
            height: 800,
            lines: [
              _line('Cells', 60, height: 18),
              for (final (i, text) in body.indexed) _line(text, 100.0 + i * 14),
              _line('1.2 Osmosis', 300, height: 10.5),
              _line('Water moves across membranes.', 330),
            ],
          ),
        ],
      );
      final root = buildStructure(doc);
      expect(root.children.single.title, 'Cells');
      expect(root.children.single.children.single.title, '1.2 Osmosis');
    });

    test('a large vertical gap starts a new paragraph; tight lines join', () {
      final doc = ExtractedDocument(
        title: 'T',
        pages: [
          PageText(
            number: 1,
            height: 800,
            lines: [
              _line('First paragraph line one', 100),
              _line('continues here.', 115),
              _line('Second paragraph.', 145),
            ],
          ),
        ],
      );
      final root = buildStructure(doc);
      expect(root.paragraphs.map((p) => p.text), [
        'First paragraph line one continues here.',
        'Second paragraph.',
      ]);
    });

    test('a sentence cut by a page break continues on the next page', () {
      final doc = ExtractedDocument(
        title: 'T',
        pages: [
          PageText(
            number: 1,
            height: 800,
            lines: [_line('Water moves toward', 700)],
          ),
          PageText(
            number: 2,
            height: 800,
            lines: [_line('the side with more solutes.', 80)],
          ),
        ],
      );
      final paragraph = buildStructure(doc).paragraphs.single;
      expect(paragraph.text, 'Water moves toward the side with more solutes.');
      expect((paragraph.pageStart, paragraph.pageEnd), (1, 2));
    });
  });

  group('chunking', () {
    SectionNode sectionWith(List<String> paragraphs) {
      final node = SectionNode(title: 'S', level: 1, pageStart: 1);
      for (final text in paragraphs) {
        node.paragraphs.add(Paragraph(text, pageStart: 1, pageEnd: 1));
      }
      return node;
    }

    String words(int n, [String word = 'word']) =>
        List.filled(n, word).join(' ');

    test('packs paragraphs up to the target size', () {
      final chunks = chunkSection(
        sectionWith([for (var i = 0; i < 10; i++) words(100)]),
      );
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.tokenEstimate, lessThanOrEqualTo(650 * 1.25));
      }
    });

    test('splits an overlong paragraph at sentence ends', () {
      final sentence = '${words(40)}.';
      final paragraph = List.filled(30, sentence).join(' ');
      final chunks = chunkSection(sectionWith([paragraph]));
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.text.trim(), endsWith('.'));
      }
    });

    test('a short tail joins the previous chunk', () {
      final chunks = chunkSection(sectionWith([words(340), words(30)]));
      expect(chunks, hasLength(1));
    });

    test('splitSentences', () {
      expect(splitSentences('One. Two? "Three!" Four'), [
        'One.',
        'Two?',
        '"Three!"',
        'Four',
      ]);
    });
  });

  group('content kinds', () {
    ContentKind kind(
      String text, {
      List<String> path = const ['Body'],
      int page = 10,
    }) => classifyChunk(
      text: text,
      headingPath: path,
      pageStart: page,
      documentPages: 100,
    );

    test('by section title, in several languages', () {
      expect(kind('anything', path: ['Contents']), ContentKind.toc);
      expect(kind('anything', path: ['Table des matières']), ContentKind.toc);
      expect(kind('anything', path: ['Bibliographie']), ContentKind.refs);
      expect(
        kind('anything', path: ['Part 2', '12 References']),
        ContentKind.refs,
      );
      expect(kind('anything', path: ['Index']), ContentKind.bookIndex);
    });

    test('by text patterns', () {
      expect(
        kind('1 Cells ........ 3\n1.1 Membranes ....... 3\n2 Energy ....... 4'),
        ContentKind.toc,
      );
      expect(
        kind(
          'Smith, J. (2019). Membranes. J. Cells, 12, pp. 45. doi:10.1/x. '
          'Lee, K. et al. (2021). Energy. https://example.org',
        ),
        ContentKind.refs,
      );
      expect(
        kind('Copyright 2026 Press. All rights reserved. ISBN 0-00.', page: 2),
        ContentKind.front,
      );
      expect(
        kind(
          '∫∂x/∂t = ∑ αβ + (x² − y²) / 2π ≤ ∞ ∀ε>0 ∃δ>0 |x−y|<δ ⇒ |f(x)−f(y)|<ε',
        ),
        ContentKind.math,
      );
      expect(
        kind('Osmosis is the movement of water across a membrane.'),
        ContentKind.study,
      );
    });
  });

  group('language', () {
    test('Latin-script languages by common words', () {
      expect(
        detectLanguage(
          'The cell is the basic unit of life and it is found in all organisms that are living.',
        ),
        'en',
      );
      expect(
        detectLanguage(
          "La cellule est l'unité de base du vivant et elle est présente dans tous les organismes.",
        ),
        'fr',
      );
      expect(
        detectLanguage(
          'La célula es la unidad básica de la vida y se encuentra en todos los organismos vivos.',
        ),
        'es',
      );
    });

    test('other scripts by character range', () {
      expect(
        detectLanguage(
          'الخلية هي الوحدة الأساسية للحياة وتوجد في جميع الكائنات الحية',
        ),
        'ar',
      );
      expect(detectLanguage('Клетка является основной единицей жизни'), 'ru');
    });

    test('too little text is undetermined', () {
      expect(detectLanguage('Osmosis'), 'und');
    });
  });

  group('plain text and Markdown', () {
    test('Markdown headings build the tree; blank lines split paragraphs', () {
      final doc = readPlainText(
        '# Cells\n\nCells are small.\nThey divide.\n\n## Osmosis\n\n'
        'Water **moves** across [membranes](http://x).\n',
        title: 'Notes',
        markdown: true,
      );
      final root = buildStructure(doc);
      final cells = root.children.single;
      expect(cells.title, 'Cells');
      expect(cells.paragraphs.single.text, 'Cells are small. They divide.');
      expect(
        cells.children.single.paragraphs.single.text,
        'Water moves across membranes.',
      );
    });

    test('plain text finds numbered and all-caps headings', () {
      final doc = readPlainText(
        'INTRODUCTION\nSome intro text.\n\n1. Cells\nCell text.\n\n1.1 Membranes\nMembrane text.',
        title: 'Notes',
      );
      final root = buildStructure(doc);
      expect(root.children.map((s) => s.title), ['INTRODUCTION', '1. Cells']);
      expect(root.children.last.children.single.title, '1.1 Membranes');
    });
  });

  test('processDocument marks contents and references, keeps study text', () {
    final doc = readPlainText(
      '# Contents\n\n1 Cells ........ 3\n2 Energy ........ 4\n3 More ........ 5\n\n'
      '# Cells\n\nOsmosis is the movement of water across a selectively permeable membrane.\n\n'
      '# References\n\nSmith, J. (2019). Membranes. doi:10.1/x',
      title: 'Bio',
      markdown: true,
    );
    final processed = processDocument(doc);
    expect(processed.chunks.map((c) => c.kind), [
      ContentKind.toc,
      ContentKind.study,
      ContentKind.refs,
    ]);
    expect(processed.studyChunks.single.text, startsWith('Osmosis'));
    expect(processed.language, 'en');
  });
}
