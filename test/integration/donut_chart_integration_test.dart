import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chart_sample_app/providers/chart_provider.dart';
import 'package:chart_sample_app/models/chart_data_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('도넛 차트 통합 테스트', () {
    testWidgets('도넛 차트 기본 기능 테스트', (WidgetTester tester) async {
      // Given - Provider 직접 테스트 (UI 렌더링 없이)
      final chartProvider = ChartProvider()..initializeData();

      // When - 도넛 차트로 직접 전환
      chartProvider.setChartType(ChartType.donut);

      // Then - 기본 기능들이 작동하는지 확인
      expect(chartProvider.isDonutChart, true);
      expect(chartProvider.pieChartData.totalCapacity, greaterThan(0));
      expect(chartProvider.pieChartData.currentUsage, greaterThanOrEqualTo(0));
    });

    testWidgets('도넛 차트 데이터 관리 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When - 파이 차트 데이터 업데이트 (도넛 차트는 같은 데이터 모델 사용)
      chartProvider.updatePieData(
        currentUsage: 80.0,
        totalCapacity: 120.0,
        primaryColor: Colors.blue,
        backgroundColor: Colors.grey,
      );
      chartProvider.setChartType(ChartType.donut);

      // Then - 업데이트된 데이터가 반영되었는지 확인
      expect(chartProvider.pieChartData.currentUsage, 80.0);
      expect(chartProvider.pieChartData.totalCapacity, 120.0);
      expect(chartProvider.isDonutChart, true);
      expect(chartProvider.pieChartData.percentage, closeTo(66.67, 0.01));
    });

    testWidgets('도넛 차트 계산 기능 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When - 특정 데이터로 설정
      chartProvider.updatePieData(
        currentUsage: 75.0,
        totalCapacity: 100.0,
      );

      final data = chartProvider.pieChartData;

      // Then - 계산 기능들이 올바르게 작동하는지 확인
      expect(data.percentage, 75.0);
      expect(data.currentUsage, 75.0);
      expect(data.totalCapacity, 100.0);

      // 사용 가능량 계산
      final remaining = data.totalCapacity - data.currentUsage;
      expect(remaining, 25.0);
    });

    testWidgets('도넛 차트 타입 전환 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When & Then - 차트 타입 전환 순서 확인
      expect(chartProvider.currentChartType, ChartType.bar);

      // bar -> pie
      chartProvider.toggleChartType();
      expect(chartProvider.currentChartType, ChartType.pie);

      // pie -> line
      chartProvider.toggleChartType();
      expect(chartProvider.currentChartType, ChartType.line);

      // line -> stackedBar
      chartProvider.toggleChartType();
      expect(chartProvider.currentChartType, ChartType.stackedBar);

      // stackedBar -> donut
      chartProvider.toggleChartType();
      expect(chartProvider.currentChartType, ChartType.donut);
      expect(chartProvider.isDonutChart, true);

      // donut -> bar (순환)
      chartProvider.toggleChartType();
      expect(chartProvider.currentChartType, ChartType.bar);
      expect(chartProvider.isDonutChart, false);
    });

    testWidgets('도넛 차트 경계값 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When & Then - 0% 사용률 테스트
      chartProvider.updatePieData(
        currentUsage: 0.0,
        totalCapacity: 100.0,
      );
      chartProvider.setChartType(ChartType.donut);

      expect(chartProvider.pieChartData.percentage, 0.0);
      expect(chartProvider.pieChartData.currentUsage, 0.0);

      // When & Then - 100% 사용률 테스트
      chartProvider.updatePieData(
        currentUsage: 100.0,
        totalCapacity: 100.0,
      );

      expect(chartProvider.pieChartData.percentage, 100.0);
      expect(chartProvider.pieChartData.currentUsage, 100.0);

      // When & Then - 소수점 값 테스트
      chartProvider.updatePieData(
        currentUsage: 33.33,
        totalCapacity: 100.0,
      );

      expect(chartProvider.pieChartData.percentage, closeTo(33.33, 0.01));
      expect(chartProvider.pieChartData.currentUsage, 33.33);
    });

    testWidgets('도넛 차트 데이터 유효성 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When & Then - 음수 값 처리 (Provider에서 검증됨)
      final originalUsage = chartProvider.pieChartData.currentUsage;

      // 음수 사용량은 무시되어야 함
      chartProvider.updatePieCurrentUsage(-10.0);
      expect(chartProvider.pieChartData.currentUsage, originalUsage);

      // When & Then - 용량 초과 값 처리
      final totalCapacity = chartProvider.pieChartData.totalCapacity;
      chartProvider.updatePieCurrentUsage(totalCapacity + 10);
      expect(chartProvider.pieChartData.currentUsage, originalUsage);

      // When & Then - 0 이하 총 용량 처리
      final originalCapacity = chartProvider.pieChartData.totalCapacity;
      chartProvider.updatePieTotalCapacity(0);
      expect(chartProvider.pieChartData.totalCapacity, originalCapacity);

      chartProvider.updatePieTotalCapacity(-10);
      expect(chartProvider.pieChartData.totalCapacity, originalCapacity);
    });

    testWidgets('도넛 차트 성능 테스트', (WidgetTester tester) async {
      // Given - Provider 생성
      final chartProvider = ChartProvider()..initializeData();

      // When - 여러 번 연속으로 데이터 업데이트
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        chartProvider.updatePieData(
          currentUsage: i.toDouble(),
          totalCapacity: 100.0,
        );
        chartProvider.setChartType(ChartType.donut);
      }

      stopwatch.stop();

      // Then - 성능이 합리적인 범위 내에 있는지 확인
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1초 미만
      expect(chartProvider.pieChartData.currentUsage, 99.0);
      expect(chartProvider.isDonutChart, true);
    });
  });
}
