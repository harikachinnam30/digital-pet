import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_pet/main.dart';

void main() {
  // Helper that makes sure a button is visible
  // before the automated test taps it.
  Future<void> tapButton(
    WidgetTester tester,
    String text,
  ) async {
    final finder = find.text(text);

    await tester.ensureVisible(finder);
    await tester.pump();

    await tester.tap(finder);
    await tester.pump(
      const Duration(milliseconds: 500),
    );
  }

  testWidgets(
    'Digital Pet app loads correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const DigitalPetApp(),
      );

      expect(
        find.text('Digital Pet'),
        findsOneWidget,
      );

      expect(
        find.text('Pip'),
        findsWidgets,
      );

      expect(
        find.text('Play'),
        findsOneWidget,
      );

      expect(
        find.text('Feed'),
        findsOneWidget,
      );

      expect(
        find.text('Rest'),
        findsOneWidget,
      );

      expect(
        find.text('Run'),
        findsOneWidget,
      );

      expect(
        find.text('Sleep'),
        findsOneWidget,
      );

      expect(
        find.text('Reset'),
        findsOneWidget,
      );
    },
  );

  // --------------------------------------------------
  // EXACTLY 80 DOES NOT QUALIFY
  // --------------------------------------------------

  testWidgets(
    'exactly 80 happiness does not start win timer',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PetScreen(
            winDuration: Duration(seconds: 3),
            hungerInterval: Duration(minutes: 10),
          ),
        ),
      );

      // 50 -> 65
      await tapButton(
        tester,
        'Play',
      );

      // 65 -> 80
      await tapButton(
        tester,
        'Play',
      );

      // Exactly 80 must not start the timer.
      expect(
        find.textContaining(
          'Keep it there for 3 minutes',
        ),
        findsNothing,
      );

      expect(
        find.text('YOU WON!'),
        findsNothing,
      );

      // Waiting longer should still not cause a win.
      await tester.pump(
        const Duration(seconds: 4),
      );

      expect(
        find.text('YOU WON!'),
        findsNothing,
      );
    },
  );

  // --------------------------------------------------
  // ABOVE 80 FOR FULL DURATION WINS
  // --------------------------------------------------

  testWidgets(
    'happiness above 80 continuously triggers win',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PetScreen(
            winDuration: Duration(seconds: 3),
            hungerInterval: Duration(minutes: 10),
          ),
        ),
      );

      // Run 1:
      // 50 -> 70
      await tapButton(
        tester,
        'Run',
      );

      // Run 2:
      // 70 -> 90
      await tapButton(
        tester,
        'Run',
      );

      // Above 80 should start the timer.
      expect(
        find.textContaining(
          'Keep it there for 3 minutes',
        ),
        findsOneWidget,
      );

      // Only 2 seconds.
      await tester.pump(
        const Duration(seconds: 2),
      );

      expect(
        find.text('YOU WON!'),
        findsNothing,
      );

      // Complete the 3-second test duration.
      await tester.pump(
        const Duration(seconds: 1),
      );

      await tester.pump();

      expect(
        find.text('YOU WON!'),
        findsOneWidget,
      );

      expect(
        find.text('Restart Game'),
        findsOneWidget,
      );
    },
  );

  // --------------------------------------------------
  // DROPPING BACK TO 80 CANCELS TIMER
  // --------------------------------------------------

  testWidgets(
    'dropping to exactly 80 cancels continuous win timer',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PetScreen(
            winDuration: Duration(seconds: 3),
            hungerInterval: Duration(minutes: 10),
          ),
        ),
      );

      // 50 -> 70
      await tapButton(
        tester,
        'Run',
      );

      // 70 -> 90
      await tapButton(
        tester,
        'Run',
      );

      // Timer should now be active.
      expect(
        find.textContaining(
          'Keep it there for 3 minutes',
        ),
        findsOneWidget,
      );

      // Allow 1 second of the timer to pass.
      await tester.pump(
        const Duration(seconds: 1),
      );

      expect(
        find.text('YOU WON!'),
        findsNothing,
      );

      // Sleep:
      // 90 -> 85
      await tapButton(
        tester,
        'Sleep',
      );

      // 85 -> 80
      await tapButton(
        tester,
        'Sleep',
      );

      // Exactly 80 cancels the continuous timer.
      expect(
        find.textContaining(
          'Keep it there for 3 minutes',
        ),
        findsNothing,
      );

      // Wait longer than the original timer.
      await tester.pump(
        const Duration(seconds: 4),
      );

      // It must NOT win because continuity was broken.
      expect(
        find.text('YOU WON!'),
        findsNothing,
      );

      expect(
        find.text('Reset'),
        findsOneWidget,
      );
    },
  );
}