import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chart_sample_app/providers/chart_provider.dart';
import 'package:chart_sample_app/models/chart_data_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('스택형 막대 차트 통합 테스트', () {
    testWidgets('스택형 막대 차트 기본 기능 테스트', (WidgetTester tester) async {
      // Given - Provider 직접 테스트 (UI 렌더링 없이)
      final chartProvider = ChartProvider()..initializeData();

      // When - 스택형 차트로 직접 전환
      chartProvider.setChartType(ChartType.stackedBar);

      // Then - 기본 기능들이 작동하는지 확인
      expect(chartProvider.isStackedBarChart, true);
      expect(chartProvider.stackedBarChartData.length, greaterThan(0));
      expect(chartProvider.maxStackedBarChartValue, greaterThan(0));
    });

    testWidgets('스택형 막대 차트 데이터 관리 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When - 스택형 차트 데이터 업데이트
      final newData = [
        StackedBarChartData.fromUsageData(
          category: 'TestMonth1',
          baseUsage: 60.0,
          acUsage: 40.0,
          heatingUsage: 10.0,
          etcUsage: 20.0,
        ),
        StackedBarChartData.fromUsageData(
          category: 'TestMonth2',
          baseUsage: 55.0,
          acUsage: 35.0,
          heatingUsage: 15.0,
          etcUsage: 25.0,
        ),
      ];

      chartProvider.updateStackedBarChartData(newData);
      chartProvider.setChartType(ChartType.stackedBar);

      // Then - 업데이트된 데이터가 반영되었는지 확인
      expect(chartProvider.stackedBarChartData.length, 2);
      expect(chartProvider.stackedBarChartData[0].category, 'TestMonth1');
      expect(chartProvider.stackedBarChartData[1].category, 'TestMonth2');
      expect(chartProvider.isStackedBarChart, true);
    });

    testWidgets('스택형 막대 차트 데이터 조작 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();
      final initialCount = chartProvider.stackedBarChartData.length;

      // When - 데이터 추가
      final newItem = StackedBarChartData.fromUsageData(
        category: 'NewMonth',
        baseUsage: 40.0,
        acUsage: 30.0,
        heatingUsage: 8.0,
        etcUsage: 12.0,
      );

      chartProvider.addStackedBarChartData(newItem);

      // Then - 데이터가 추가되었는지 확인
      expect(chartProvider.stackedBarChartData.length, initialCount + 1);
      expect(chartProvider.stackedBarChartData.last.category, 'NewMonth');

      // When - 데이터 제거
      chartProvider.removeStackedBarChartData(0);

      // Then - 데이터가 제거되었는지 확인
      expect(chartProvider.stackedBarChartData.length, initialCount);
    });

    testWidgets('스택형 막대 차트 계산 기능 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When - 데이터 확인
      final data = chartProvider.stackedBarChartData;

      if (data.isNotEmpty) {
        final firstItem = data.first;

        // Then - 계산 기능들이 올바르게 작동하는지 확인
        expect(firstItem.totalUsage, greaterThan(0));
        expect(firstItem.getValue('Base'), greaterThanOrEqualTo(0));
        expect(firstItem.getValue('AC'), greaterThanOrEqualTo(0));
        expect(firstItem.getValue('Heating'), greaterThanOrEqualTo(0));
        expect(firstItem.getValue('Other'), greaterThanOrEqualTo(0));

        // 백분율 합이 100%인지 확인
        final percentages = firstItem.percentages;
        final totalPercentage =
            percentages.values.fold(0.0, (sum, pct) => sum + pct);
        expect(totalPercentage, closeTo(100.0, 0.01));
      }
    });
  });
}
