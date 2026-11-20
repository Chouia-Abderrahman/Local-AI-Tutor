import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The importer opens PDFs without a viewer widget, which needs this first.
  await pdfrxFlutterInitialize();
  runApp(const ProviderScope(child: StudyApp()));
}
