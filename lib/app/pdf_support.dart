import 'package:pdfrx/pdfrx.dart';

Future<void>? _ready;

/// Prepares PDFium (through pdfrx) the first time a PDF is opened. It used
/// to run before the first frame, so a slow or stuck start-up kept the app
/// on the splash screen; nothing needs it until a document is imported.
Future<void> ensurePdfSupport() {
  return _ready ??= () async {
    try {
      await pdfrxFlutterInitialize();
    } on Object {
      _ready = null; // Try again next time instead of caching the failure.
      rethrow;
    }
  }();
}
