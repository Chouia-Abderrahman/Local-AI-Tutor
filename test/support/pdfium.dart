import 'dart:io';

import 'package:pdfrx/pdfrx.dart';

/// Initializes pdfrx for host tests.
///
/// `pdfrxFlutterInitialize()` needs path_provider, which `flutter test` lacks,
/// and the PDFium loader looks next to the Flutter tester rather than in the
/// native assets the build hook downloaded. Point it at those directly.
Future<void> initPdfiumForTests() async {
  final candidates = [
    'build/native_assets/linux/libpdfium.so',
    ...Directory('.dart_tool/hooks_runner/shared/pdfium_dart/build')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('linux-x64/libpdfium.so')),
  ];
  for (final path in candidates) {
    if (File(path).existsSync()) {
      Pdfrx.pdfiumModulePath ??= File(path).absolute.path;
      break;
    }
  }
  await pdfrxInitialize(tmpPath: Directory.systemTemp.createTempSync().path);
}
