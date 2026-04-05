import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kurdish_calendar/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // showOnboarding: false → go straight to MainShell (no repeating animations).
    await tester.pumpWidget(
      ProviderScope(
        child: KurdishCalendarApp(showOnboarding: false),
      ),
    );

    // Let entrance animations complete in the fake clock.
    await tester.pump(const Duration(seconds: 2));

    // Verify the app shell rendered.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Unmount to stop any remaining timers before test teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

