import 'dart:io';
import 'dart:ui' as ui;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as mlkit;
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';

import 'extracted.dart';
import 'text_cleanup.dart';

/// Reads the text of a page that has none (a scanned page).
abstract interface class PageOcr {
  /// Lines of [pageNumber] (1-based), with positions in PDF points.
  Future<List<TextLine>> readPage(PdfDocument document, int pageNumber);

  Future<void> close();
}

/// On-device text recognition with Google ML Kit (Android and iOS). The page
/// is rendered at twice its size; recognized line boxes are scaled back to
/// PDF points so heading detection works as for text PDFs. ML Kit's bundled
/// model reads Latin script; Arabic, for one, is not supported.
class MlKitPageOcr implements PageOcr {
  MlKitPageOcr({required this.tempDir});

  final Directory tempDir;
  final _recognizer = mlkit.TextRecognizer();

  static const _scale = 2.0;

  @override
  Future<List<TextLine>> readPage(PdfDocument document, int pageNumber) async {
    final page = document.pages[pageNumber - 1];
    final rendered = await page.render(
      fullWidth: page.width * _scale,
      fullHeight: page.height * _scale,
      backgroundColor: 0xFFFFFFFF,
    );
    if (rendered == null) return const [];
    final file = File(p.join(tempDir.path, 'ocr_page_$pageNumber.png'));
    try {
      final image = await rendered.createImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (png == null) return const [];
      await file.writeAsBytes(png.buffer.asUint8List(), flush: true);
      final result = await _recognizer.processImage(
        mlkit.InputImage.fromFilePath(file.path),
      );
      final lines = <TextLine>[
        for (final block in result.blocks)
          for (final line in block.lines)
            TextLine(
              normalizeLine(line.text),
              top: line.boundingBox.top / _scale,
              left: line.boundingBox.left / _scale,
              height: line.boundingBox.height / _scale,
            ),
      ]..sort((a, b) => a.top.compareTo(b.top));
      return [
        for (final line in lines)
          if (line.text.isNotEmpty) line,
      ];
    } finally {
      rendered.dispose();
      if (file.existsSync()) await file.delete();
    }
  }

  @override
  Future<void> close() => _recognizer.close();
}
