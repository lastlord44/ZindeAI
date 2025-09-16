import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zindeai/main.dart';

void main() {
  testWidgets('ZindeAI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZindeAIApp());

    // Verify that our app shows the welcome text.
    expect(find.text('Welcome to ZindeAI'), findsOneWidget);
    expect(find.text('Smart nutrition tracker for Turkish cuisine'), findsOneWidget);
  });
}