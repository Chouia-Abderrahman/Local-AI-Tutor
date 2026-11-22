import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// Nothing may stand between launching the app and its first frame: the
/// Android splash screen stays until Flutter draws, so anything slow or
/// failing here looks like an app stuck on the splash. Start-up work that is
/// not needed to draw runs after `runApp`, and its errors are logged.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exceptionAsString()}');
  };
  // Errors nobody caught (a failed download, a model that would not load)
  // are logged instead of ending the app.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
  try {
    // Lets the background-work service talk to the app.
    FlutterForegroundTask.initCommunicationPort();
  } on Object catch (error) {
    debugPrint('Foreground service port: $error');
  }
  // The licenses of the bundled fonts, for the licenses page.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL-Inter.txt'));
    yield LicenseEntryWithLineBreaks([
      'Fraunces',
    ], await rootBundle.loadString('assets/fonts/OFL-Fraunces.txt'));
  });
  runApp(const ProviderScope(child: StudyApp()));
}
