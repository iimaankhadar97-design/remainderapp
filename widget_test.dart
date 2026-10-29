import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remainder_app/main.dart';

void main() {
  testWidgets('Reminder App UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title 'Reminders' exists.
    expect(find.text('Reminders'), findsOneWidget);

    // Verify that there is a FAB to add reminders.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}