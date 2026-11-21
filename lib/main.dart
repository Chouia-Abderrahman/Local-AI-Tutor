import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lets the background-work service talk to the app.
  FlutterForegroundTask.initCommunicationPort();
  // The importer opens PDFs without a viewer widget, which needs this first.
  await pdfrxFlutterInitialize();
  // The bundled font's license, for the licenses page.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Source Sans 3',
    ], await rootBundle.loadString('assets/fonts/SourceSans3-LICENSE.md'));
  });
  runApp(const ProviderScope(child: StudyApp()));
}
