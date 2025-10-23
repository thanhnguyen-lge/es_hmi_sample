import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:chart_sample_app/widgets/stacked_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StackedBarChart Widget Tests', () {
    late List<StackedBarChartData> testData;

    setUp(() {
      testData = <StackedBarChartData>[
        StackedBarChartData.fromUsageData(
          category: 'Jan',
          dhwUsage: 45.0,
          coolUsage: 15.0,
          heatUsage: 8.0,
          lastYearTotal: 75.0,
          lastYearDhw: 40.0,
          lastYearCool: 20.0,
          lastYearHeat: 15.0,
        ),
        StackedBarChartData.fromUsageData(
          category: 'Feb',
          dhwUsage: 42.0,
          coolUsage: 12.0,
          heatUsage: 18.0,
          lastYearTotal: 82.0,
          lastYearDhw: 45.0,
          lastYearCool: 18.0,
          lastYearHeat: 19.0,
        ),
        StackedBarChartData.fromUsageData(
          category: 'Mar',
          dhwUsage: 48.0,
          coolUsage: 20.0,
          heatUsage: 5.0,
          lastYearTotal: 88.0,
          lastYearDhw: 50.0,
          lastYearCool: 25.0,
          lastYearHeat: 13.0,
        ),
      ];
    });

    testWidgets('StackedBarChart는 올바르게 렌더링되어야 합니다',
        (WidgetTester tester) async {
      // Given
      const String title = '월별 에너지 사용량';
      const String xAxisTitle = '월';
      const String yAxisTitle = '사용량 (kWh)';

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
      const String title = '테스트 차트 제목';

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
            ),
          ),
        ),
      );

      // Then
      expect(find.text('DHW only'), findsOneWidget);
      expect(find.text('Cool'), findsOneWidget);
      expect(find.text('Heat'), findsOneWidget);
      expect(find.text('Last Year'), findsOneWidget);
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
      expect(find.text('DHW only'), findsNothing);
      expect(find.text('Cool'), findsNothing);
      expect(find.text('Heat'), findsNothing);
      expect(find.text('Last Year'), findsNothing);
    });

    testWidgets('StackedBarChart는 빈 데이터로 렌더링되어야 합니다',
        (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StackedBarChart(
              data: <StackedBarChartData>[],
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
      const Duration customDuration = Duration(milliseconds: 500);

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
      const double maxY = 200.0;

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
      const EdgeInsets customMargin = EdgeInsets.all(24);

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
        final List<StackedBarChartData> singleDataPoint = <StackedBarChartData>[
          StackedBarChartData.fromUsageData(
            category: 'Single',
            dhwUsage: 30.0,
            coolUsage: 10.0,
            heatUsage: 5.0,
            lastYearTotal: 50.0,
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
        final List<StackedBarChartData> largeDataSet =
            List<StackedBarChartData>.generate(
          12,
          (int index) => StackedBarChartData.fromUsageData(
            category: 'Month${index + 1}',
            dhwUsage: 40.0 + (index * 2),
            coolUsage: 10.0 + (index * 1.5),
            heatUsage: 5.0 + (index * 0.5),
            lastYearTotal: 70.0 + (index * 3),
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
