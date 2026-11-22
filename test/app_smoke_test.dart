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

    expect(find.text('Local AI Tutor'), findsOneWidget);
    expect(find.text('Library'), findsWidgets);
    expect(find.text('Set up the on-device model'), findsOneWidget);
    expect(find.text('Your study shelf is empty'), findsOneWidget);
    expect(find.text('Import a document'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('AI models'), findsOneWidget);

    // The theme can be set by hand.
    expect(
      Theme.of(tester.element(find.text('AI models'))).brightness,
      Brightness.light,
    );
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('AI models'))).brightness,
      Brightness.dark,
    );

    // Chat lists conversations; with no document there is nothing yet.
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to talk about yet'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Not set up'), findsOneWidget);

    // Dispose the scope, let drift's stream cleanup timers fire, then close
    // the database outside the fake clock.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(db.close);
  });
}
