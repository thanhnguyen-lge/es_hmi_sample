import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Simple MaterialApp test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Text('Hello World'),
      ),
    ));

    // Verify that our simple app displays 'Hello World'.
    expect(find.text('Hello World'), findsOneWidget);
  });
}
