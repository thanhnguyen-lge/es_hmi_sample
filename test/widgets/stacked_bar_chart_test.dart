import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:chart_sample_app/widgets/stacked_bar_chart.dart';

void main() {
  group('StackedBarChart Widget Tests', () {
    late List<StackedBarChartData> testData;

    setUp(() {
      testData = [
        StackedBarChartData.fromUsageData(
          category: 'Jan',
          baseUsage: 45.0,
          acUsage: 15.0,
          heatingUsage: 8.0,
          etcUsage: 12.0,
        ),
        StackedBarChartData.fromUsageData(
          category: 'Feb',
          baseUsage: 42.0,
          acUsage: 12.0,
          heatingUsage: 18.0,
          etcUsage: 10.0,
        ),
        StackedBarChartData.fromUsageData(
          category: 'Mar',
          baseUsage: 48.0,
          acUsage: 20.0,
          heatingUsage: 5.0,
          etcUsage: 15.0,
        ),
      ];
    });

    testWidgets('StackedBarChart는 올바르게 렌더링되어야 합니다',
        (WidgetTester tester) async {
      // Given
      const title = '월별 에너지 사용량';
      const xAxisTitle = '월';
      const yAxisTitle = '사용량 (kWh)';

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: title,
              xAxisTitle: xAxisTitle,
              yAxisTitle: yAxisTitle,
            ),
          ),
        ),
      );

      // Then
      expect(find.text(title), findsOneWidget);
      expect(find.byType(StackedBarChart), findsOneWidget);
    });

    testWidgets('StackedBarChart는 제목을 표시해야 합니다', (WidgetTester tester) async {
      // Given
      const title = '테스트 차트 제목';

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: title,
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
            ),
          ),
        ),
      );

      // Then
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('StackedBarChart는 범례를 표시해야 합니다', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: '테스트 차트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
              showLegend: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Base'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('Heating'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('StackedBarChart는 범례를 숨길 수 있어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: '테스트 차트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
              showLegend: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Base'), findsNothing);
      expect(find.text('AC'), findsNothing);
      expect(find.text('Heating'), findsNothing);
      expect(find.text('Other'), findsNothing);
    });

    testWidgets('StackedBarChart는 빈 데이터로 렌더링되어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: const [],
              title: '빈 차트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
            ),
          ),
        ),
      );

      // Then
      expect(find.text('빈 차트'), findsOneWidget);
      expect(find.byType(StackedBarChart), findsOneWidget);
    });

    testWidgets('StackedBarChart는 사용자 정의 애니메이션 지속시간을 가질 수 있어야 합니다',
        (WidgetTester tester) async {
      // Given
      const customDuration = Duration(milliseconds: 500);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: '애니메이션 테스트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
              animationDuration: customDuration,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(StackedBarChart), findsOneWidget);
    });

    testWidgets('StackedBarChart는 최대 Y값을 설정할 수 있어야 합니다',
        (WidgetTester tester) async {
      // Given
      const maxY = 200.0;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: '최대값 테스트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
              maxY: maxY,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(StackedBarChart), findsOneWidget);
    });

    testWidgets('StackedBarChart는 상호작용을 비활성화할 수 있어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: '상호작용 비활성화 테스트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
              enableInteraction: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(StackedBarChart), findsOneWidget);
    });

    testWidgets('StackedBarChart는 툴팁을 비활성화할 수 있어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: '툴팁 비활성화 테스트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
              showTooltip: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(StackedBarChart), findsOneWidget);
    });

    testWidgets('StackedBarChart는 사용자 정의 여백을 가질 수 있어야 합니다',
        (WidgetTester tester) async {
      // Given
      const customMargin = EdgeInsets.all(24);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: testData,
              title: '여백 테스트',
              xAxisTitle: 'X축',
              yAxisTitle: 'Y축',
              margin: customMargin,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(StackedBarChart), findsOneWidget);
    });

    group('StackedBarChart 상태 관리', () {
      testWidgets('애니메이션 컨트롤러가 올바르게 초기화되어야 합니다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StackedBarChart(
                data: testData,
                title: '애니메이션 초기화 테스트',
                xAxisTitle: 'X축',
                yAxisTitle: 'Y축',
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(StackedBarChart), findsOneWidget);

        // 애니메이션이 시작되었는지 확인
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(StackedBarChart), findsOneWidget);
      });

      testWidgets('위젯이 dispose될 때 애니메이션 컨트롤러가 정리되어야 합니다',
          (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StackedBarChart(
                data: testData,
                title: 'Dispose 테스트',
                xAxisTitle: 'X축',
                yAxisTitle: 'Y축',
              ),
            ),
          ),
        );

        expect(find.byType(StackedBarChart), findsOneWidget);

        // When - 위젯 제거
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Text('다른 위젯'),
            ),
          ),
        );

        // Then
        expect(find.byType(StackedBarChart), findsNothing);
        expect(find.text('다른 위젯'), findsOneWidget);
      });
    });

    group('StackedBarChart 데이터 처리', () {
      testWidgets('차트는 단일 데이터 포인트를 처리할 수 있어야 합니다', (WidgetTester tester) async {
        // Given
        final singleDataPoint = [
          StackedBarChartData.fromUsageData(
            category: 'Single',
            baseUsage: 30.0,
            acUsage: 10.0,
            heatingUsage: 5.0,
            etcUsage: 5.0,
          ),
        ];

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StackedBarChart(
                data: singleDataPoint,
                title: '단일 데이터 테스트',
                xAxisTitle: 'X축',
                yAxisTitle: 'Y축',
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(StackedBarChart), findsOneWidget);
        expect(find.text('단일 데이터 테스트'), findsOneWidget);
      });

      testWidgets('차트는 대용량 데이터를 처리할 수 있어야 합니다', (WidgetTester tester) async {
        // Given
        final largeDataSet = List.generate(
          12,
          (index) => StackedBarChartData.fromUsageData(
            category: 'Month${index + 1}',
            baseUsage: 40.0 + (index * 2),
            acUsage: 10.0 + (index * 1.5),
            heatingUsage: 5.0 + (index * 0.5),
            etcUsage: 8.0 + (index * 1),
          ),
        );

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StackedBarChart(
                data: largeDataSet,
                title: '대용량 데이터 테스트',
                xAxisTitle: 'X축',
                yAxisTitle: 'Y축',
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(StackedBarChart), findsOneWidget);
        expect(find.text('대용량 데이터 테스트'), findsOneWidget);
      });
    });
  });
}
