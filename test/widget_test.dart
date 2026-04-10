import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oleksandrai_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This might require MockFirebase if initialization fails in test environment, 
    // but for a basic "fix errors" session, we just fix the class name.
    await tester.pumpWidget(const OleksandrAIApp());

    // Verify that our app name exists in the tree
    expect(find.text('OleksandrAI'), findsWidgets);
  });
}
