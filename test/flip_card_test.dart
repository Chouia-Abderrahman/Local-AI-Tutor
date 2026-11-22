import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/features/study/widgets/flip_card.dart';

// The card turns the way the finger goes, from either face.

Widget _harness({required bool startFlipped}) {
  var flipped = startFlipped;
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 400,
          child: StatefulBuilder(
            builder: (context, setState) => FlipCard(
              isFlipped: flipped,
              onFlip: () => setState(() => flipped = !flipped),
              front: const SizedBox.expand(child: Text('front')),
              back: const SizedBox.expand(child: Text('back')),
            ),
          ),
        ),
      ),
    ),
  );
}

/// sin of the card's turn angle: its sign says which edge is near.
double _sin(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find
        .descendant(of: find.byType(FlipCard), matching: find.byType(Transform))
        .first,
  );
  return transform.transform.storage[8];
}

void main() {
  // A positive angle brings the right edge towards you and moves it left, so
  // the near edge follows a leftward finger: dragging left must raise the
  // angle and dragging right lower it, from the front and from the back.
  for (final startFlipped in [false, true]) {
    for (final right in [true, false]) {
      testWidgets('a ${right ? 'right' : 'left'} swipe turns the card '
          '${right ? 'right' : 'left'} from the '
          '${startFlipped ? 'back' : 'front'}', (tester) async {
        await tester.pumpWidget(_harness(startFlipped: startFlipped));
        await tester.pumpAndSettle();
        final before = _sin(tester);
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(FlipCard)),
        );
        await gesture.moveBy(Offset(right ? 40 : -40, 0));
        await tester.pump();
        await gesture.moveBy(Offset(right ? 40 : -40, 0));
        await tester.pump();
        final during = _sin(tester);
        // The angle starts at 0 (front) or half a turn (back), where sin is
        // 0. Right lowers it: sin goes negative from the front and
        // positive from the back.
        final expected = (right != startFlipped) ? -1 : 1;
        expect(
          (during - before).sign,
          expected,
          reason: 'the near edge goes with the finger',
        );
        await gesture.up();
        await tester.pumpAndSettle();
      });
    }
  }

  testWidgets('a swipe past halfway turns the card over, either way', (
    tester,
  ) async {
    for (final dx in [200.0, -200.0]) {
      await tester.pumpWidget(_harness(startFlipped: false));
      await tester.pumpAndSettle();
      expect(find.text('front'), findsOneWidget);
      await tester.drag(find.byType(FlipCard), Offset(dx, 0));
      await tester.pumpAndSettle();
      expect(find.text('back'), findsOneWidget);
      // And back again with a swipe in the other direction.
      await tester.drag(find.byType(FlipCard), Offset(-dx, 0));
      await tester.pumpAndSettle();
      expect(find.text('front'), findsOneWidget);
    }
  });

  testWidgets('a short swipe springs back', (tester) async {
    await tester.pumpWidget(_harness(startFlipped: false));
    await tester.drag(find.byType(FlipCard), const Offset(30, 0));
    await tester.pumpAndSettle();
    expect(find.text('front'), findsOneWidget);
  });
}
