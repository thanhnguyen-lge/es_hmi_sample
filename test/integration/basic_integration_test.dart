import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Integration Test', () {
    testWidgets('Simple app starts without error', (WidgetTester tester) async {
      // 간단한 테스트 앱 생성
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test App')),
            body: const Center(
              child: Text('Hello Test'),
            ),
          ),
        ),
      );

      // 기본적으로 Material App이 로드되었는지 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Hello Test'), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('Material Design components work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Test Button'),
                ),
                const Text('Test Text'),
              ],
            ),
          ),
        ),
      );

      // Material Design 컴포넌트들이 작동하는지 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.text('Test Text'), findsOneWidget);
    });
  });
}
