import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/app/app.dart';
import 'package:pdf_study_assistant/app/providers.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/llm/fake_llm_engine.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';

void main() {
  testWidgets('app opens on the library and asks for a model', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          llmEngineProvider.overrideWithValue(FakeLlmEngine() as LlmEngine),
        ],
        child: const StudyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsWidgets);
    expect(find.text('Set up the AI model'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('AI model'), findsOneWidget);
    expect(find.text('Not set up'), findsOneWidget);

    // Dispose the scope so drift closes cleanly before the test ends.
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
