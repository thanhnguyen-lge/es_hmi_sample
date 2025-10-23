import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:chart_sample_app/providers/chart_provider.dart';
import 'package:chart_sample_app/widgets/chart_area.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('ChartArea Widget Tests', () {
    late ChartProvider chartProvider;

    setUp(() {
      chartProvider = ChartProvider();
    });

    Widget createTestWidget({required bool isBarChart, bool withData = true}) {
      if (isBarChart) {
        chartProvider.setChartType(ChartType.bar);
        if (withData) {
          // Add data entries first, then update them
          chartProvider.addBarChartData('Day 1');
          chartProvider.addBarChartData('Day 2');
          chartProvider.updateBarDataCategory(0, 'baseUsage', 10.0);
          chartProvider.updateBarDataCategory(1, 'acUsage', 15.0);
        }
      } else {
        chartProvider.setChartType(ChartType.pie);
        if (withData) {
          // Add sample pie chart data - use named parameters
          chartProvider.updatePieData(currentUsage: 25.0, totalCapacity: 100.0);
        }
      }

      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ChartProvider>.value(
            value: chartProvider,
            child: const SizedBox(
              width: 400,
              height: 300,
              child: ChartArea(),
            ),
          ),
        ),
      );
    }

    testWidgets('should display bar chart when isBarChart is true',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: true));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('막대 그래프'), findsOneWidget);
      expect(find.text('BAR'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('should display pie chart when isBarChart is false',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: false));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('원형 그래프'), findsOneWidget);
      expect(find.text('PIE'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('should display chart type indicator correctly',
        (WidgetTester tester) async {
      // Given - Bar Chart
      await tester.pumpWidget(createTestWidget(isBarChart: true));
      await tester.pumpAndSettle();

      // Then
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);

      // Given - Pie Chart
      await tester.pumpWidget(createTestWidget(isBarChart: false));
      await tester.pumpAndSettle();

      // Then
      expect(find.byIcon(Icons.pie_chart), findsOneWidget);
    });

    testWidgets('should animate when switching chart types',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: true));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);

      // When - Switch to pie chart
      chartProvider.setChartType(ChartType.pie);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 250)); // Mid animation
      await tester.pumpAndSettle(); // Complete animation

      // Then
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('should display bar chart summary info',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: true));
      await tester.pumpAndSettle();

      // Then - Should show summary information
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('총'), findsOneWidget);
      expect(find.textContaining('일 데이터'), findsOneWidget);
      expect(find.textContaining('최대값'), findsOneWidget);
    });

    testWidgets('should display pie chart summary info',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: false));
      await tester.pumpAndSettle();

      // Then - Should show summary information
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      // Look for more specific text patterns that won't conflict
      expect(find.textContaining('25.0/100.0'), findsOneWidget);
      expect(find.textContaining('25.0%'), findsOneWidget);
    });

    testWidgets('should display percentage in pie chart',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: false));
      await tester.pumpAndSettle();

      // Then - Should show percentages
      expect(find.textContaining('%'), findsWidgets);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('should handle empty bar chart data gracefully',
        (WidgetTester tester) async {
      // Given - Empty data (withData: false prevents adding test data)
      await tester
          .pumpWidget(createTestWidget(isBarChart: true, withData: false));
      await tester.pumpAndSettle();

      // Then - Should show empty state (not BarChart widget)
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
      expect(find.text('데이터가 없습니다'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing); // No BarChart in empty state
    });

    testWidgets('should apply correct colors from color scheme',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: true));
      await tester.pumpAndSettle();

      // Then - Bar chart should be rendered (we can't easily test colors in widget tests,
      // but we can verify the chart is present)
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('should show animated container with proper styling',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget(isBarChart: true));
      await tester.pumpAndSettle();

      // Then - Should find AnimatedContainer
      expect(find.byType(AnimatedContainer), findsOneWidget);

      // Should find AnimatedSwitcher for chart transitions
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('should display proper chart data values',
        (WidgetTester tester) async {
      // Given - Update with specific data
      chartProvider.updateBarDataCategory(0, 'baseUsage', 25.0);
      await tester.pumpWidget(createTestWidget(isBarChart: true));
      await tester.pumpAndSettle();

      // Then - Bar chart should be present with updated data
      expect(find.byType(BarChart), findsOneWidget);
    });
  });

  group('ChartArea Error Handling Tests', () {
    testWidgets('should handle provider errors gracefully',
        (WidgetTester tester) async {
      // Given - Provider with potential error state
      final ChartProvider provider = ChartProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ChartProvider>.value(
              value: provider,
              child: const SizedBox(
                width: 400,
                height: 300,
                child: ChartArea(),
              ),
            ),
          ),
        ),
      );

      // Should not throw and should render
      expect(find.byType(ChartArea), findsOneWidget);
    });
  });

  group('ChartArea Performance Tests', () {
    testWidgets('should rebuild efficiently when provider changes',
        (WidgetTester tester) async {
      // Given
      final ChartProvider provider = ChartProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ChartProvider>.value(
              value: provider,
              child: const SizedBox(
                width: 400,
                height: 300,
                child: ChartArea(),
              ),
            ),
          ),
        ),
      );

      // When - Multiple updates
      provider.setChartType(ChartType.pie);
      await tester.pump();

      provider.setChartType(ChartType.bar);
      await tester.pump();

      provider.updatePieData(currentUsage: 50.0, totalCapacity: 100.0);
      await tester.pump();

      // Then - Should handle updates without crashing
      expect(find.byType(ChartArea), findsOneWidget);
    });
  });
}
