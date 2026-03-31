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

    // Verify the login screen title appears
    expect(find.text('ساڵنامەی کوردستان'), findsWidgets);
  });
}
