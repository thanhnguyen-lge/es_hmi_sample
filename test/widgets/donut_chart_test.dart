import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:chart_sample_app/widgets/donut_chart.dart';

void main() {
  group('DonutChart Widget Tests', () {
    late PieChartDataModel testData;

    setUp(() {
      testData = PieChartDataModel(
        currentUsage: 75.0,
        totalCapacity: 100.0,
        primaryColor: Colors.blue,
        backgroundColor: Colors.grey,
      );
    });

    testWidgets('DonutChart는 올바르게 렌더링되어야 합니다', (WidgetTester tester) async {
      // Given
      const title = '에너지 사용률';

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              title: title,
              showPercentage: true,
              showValues: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text(title), findsOneWidget);
      expect(find.byType(DonutChart), findsOneWidget);
    });

    testWidgets('DonutChart는 제목을 표시해야 합니다', (WidgetTester tester) async {
      // Given
      const title = '테스트 도넛 차트';

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              title: title,
            ),
          ),
        ),
      );

      // Then
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('DonutChart는 퍼센티지를 표시해야 합니다', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              showPercentage: true,
              showValues: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('75.0%'), findsOneWidget);
    });

    testWidgets('DonutChart는 현재/총계 값을 표시해야 합니다', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              showPercentage: false,
              showValues: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('75 / 100'), findsOneWidget);
    });

    testWidgets('DonutChart는 퍼센티지와 값을 모두 표시할 수 있어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              showPercentage: true,
              showValues: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('75.0%'), findsOneWidget);
      expect(find.text('75 / 100'), findsOneWidget);
    });

    testWidgets('DonutChart는 퍼센티지와 값을 숨길 수 있어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              showPercentage: false,
              showValues: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('75.0%'), findsNothing);
      expect(find.text('75 / 100'), findsNothing);
    });

    testWidgets('DonutChart는 중앙 텍스트를 표시할 수 있어야 합니다',
        (WidgetTester tester) async {
      // Given
      const centerText = '사용량';

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              centerText: centerText,
              showPercentage: true,
              showValues: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text(centerText), findsOneWidget);
    });

    testWidgets('DonutChart는 빈 제목으로 렌더링되어야 합니다', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              title: '', // 빈 제목
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(DonutChart), findsOneWidget);
      // 빈 제목은 표시되지 않아야 함
    });

    testWidgets('DonutChart는 사용자 정의 중앙 공간 반지름을 가질 수 있어야 합니다',
        (WidgetTester tester) async {
      // Given
      const customRadius = 80.0;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              centerSpaceRadius: customRadius,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(DonutChart), findsOneWidget);
    });

    testWidgets('DonutChart는 상호작용을 비활성화할 수 있어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              enableInteraction: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(DonutChart), findsOneWidget);
    });

    testWidgets('DonutChart는 사용자 정의 애니메이션 지속시간을 가질 수 있어야 합니다',
        (WidgetTester tester) async {
      // Given
      const customDuration = Duration(milliseconds: 500);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              animationDuration: customDuration,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(DonutChart), findsOneWidget);
    });

    testWidgets('DonutChart는 사용자 정의 여백을 가질 수 있어야 합니다',
        (WidgetTester tester) async {
      // Given
      const customMargin = EdgeInsets.all(24);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              data: testData,
              margin: customMargin,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(DonutChart), findsOneWidget);
    });

    group('DonutChart 상태 관리', () {
      testWidgets('애니메이션 컨트롤러가 올바르게 초기화되어야 합니다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DonutChart(
                data: testData,
                title: '애니메이션 테스트',
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(DonutChart), findsOneWidget);

        // 애니메이션이 시작되었는지 확인
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(DonutChart), findsOneWidget);
      });

      testWidgets('위젯이 dispose될 때 애니메이션 컨트롤러가 정리되어야 합니다',
          (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DonutChart(
                data: testData,
                title: 'Dispose 테스트',
              ),
            ),
          ),
        );

        expect(find.byType(DonutChart), findsOneWidget);

        // When - 위젯 제거
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Text('다른 위젯'),
            ),
          ),
        );

        // Then
        expect(find.byType(DonutChart), findsNothing);
        expect(find.text('다른 위젯'), findsOneWidget);
      });
    });

    group('DonutChart 데이터 처리', () {
      testWidgets('차트는 0% 사용률을 처리할 수 있어야 합니다', (WidgetTester tester) async {
        // Given
        final zeroUsageData = PieChartDataModel(
          currentUsage: 0.0,
          totalCapacity: 100.0,
          primaryColor: Colors.blue,
          backgroundColor: Colors.grey,
        );

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DonutChart(
                data: zeroUsageData,
                title: '0% 사용률 테스트',
                showPercentage: true,
                showValues: true,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(DonutChart), findsOneWidget);
        expect(find.text('0.0%'), findsOneWidget);
        expect(find.text('0 / 100'), findsOneWidget);
      });

      testWidgets('차트는 100% 사용률을 처리할 수 있어야 합니다', (WidgetTester tester) async {
        // Given
        final fullUsageData = PieChartDataModel(
          currentUsage: 100.0,
          totalCapacity: 100.0,
          primaryColor: Colors.red,
          backgroundColor: Colors.grey,
        );

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DonutChart(
                data: fullUsageData,
                title: '100% 사용률 테스트',
                showPercentage: true,
                showValues: true,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(DonutChart), findsOneWidget);
        expect(find.text('100.0%'), findsOneWidget);
        expect(find.text('100 / 100'), findsOneWidget);
      });

      testWidgets('차트는 소수점 값을 올바르게 표시해야 합니다', (WidgetTester tester) async {
        // Given
        final decimalData = PieChartDataModel(
          currentUsage: 33.33,
          totalCapacity: 100.0,
          primaryColor: Colors.green,
          backgroundColor: Colors.grey,
        );

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DonutChart(
                data: decimalData,
                title: '소수점 테스트',
                showPercentage: true,
                showValues: true,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(DonutChart), findsOneWidget);
        expect(find.text('33.3%'), findsOneWidget);
        expect(find.text('33 / 100'), findsOneWidget);
      });
    });

    group('DonutChart 반응형 기능', () {
      testWidgets('차트는 작은 화면에서 적응적으로 렌더링되어야 합니다', (WidgetTester tester) async {
        // Given
        tester.view.physicalSize = const Size(400, 600);
        tester.view.devicePixelRatio = 1.0;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DonutChart(
                data: testData,
                title: '반응형 테스트',
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(DonutChart), findsOneWidget);

        // Reset view
        addTearDown(tester.view.reset);
      });

      testWidgets('차트는 큰 화면에서 적응적으로 렌더링되어야 합니다', (WidgetTester tester) async {
        // Given
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DonutChart(
                data: testData,
                title: '큰 화면 테스트',
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(DonutChart), findsOneWidget);

        // Reset view
        addTearDown(tester.view.reset);
      });
    });
  });
}
