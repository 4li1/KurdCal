import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kurdish_calendar/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KurdishCalendarApp(),
      ),
    );

    // Let delayed entrance animations schedule and complete in the fake clock.
    await tester.pump(const Duration(seconds: 2));

    // Verify the login screen title appears
    expect(find.text('ساڵنامەی کوردستان'), findsWidgets);

    // Unmount the app to stop any repeating animation timers before test teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
