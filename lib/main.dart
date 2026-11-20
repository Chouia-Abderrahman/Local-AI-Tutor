import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lets the generation foreground service talk to the app.
  FlutterForegroundTask.initCommunicationPort();
  // The importer opens PDFs without a viewer widget, which needs this first.
  await pdfrxFlutterInitialize();
  runApp(const ProviderScope(child: StudyApp()));
}
