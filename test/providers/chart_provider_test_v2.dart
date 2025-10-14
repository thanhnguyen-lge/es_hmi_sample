import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:chart_sample_app/providers/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartProvider Tests', () {
    late ChartProvider provider;

    setUp(() {
      provider = ChartProvider();
    });

    group('초기화 테스트', () {
      test('Provider가 올바른 초기 상태를 가져야 함', () {
        expect(provider.isBarChart, true);
        expect(provider.isLoading, false);
        expect(provider.barChartData.length, 7); // 7일간의 데이터
        expect(provider.pieChartData.totalCapacity, 100.0);
        expect(provider.colorScheme, isA<ChartColorScheme>());
      });

      test('초기 막대 그래프 데이터가 유효해야 함', () {
        final List<BarChartDataModel> barData = provider.barChartData;
        expect(barData.length, 7);

        for (final BarChartDataModel data in barData) {
          expect(data.baseUsage, greaterThanOrEqualTo(0));
          expect(data.acUsage, greaterThanOrEqualTo(0));
          expect(data.heatingUsage, greaterThanOrEqualTo(0));
          expect(data.etcUsage, greaterThanOrEqualTo(0));
          expect(data.label, isNotEmpty);
        }
      });

      test('초기 원형 그래프 데이터가 유효해야 함', () {
        final PieChartDataModel pieData = provider.pieChartData;
        expect(pieData.currentUsage, greaterThanOrEqualTo(0));
        expect(pieData.totalCapacity, greaterThan(0));
        expect(pieData.percentage, greaterThanOrEqualTo(0));
        expect(pieData.percentage, lessThanOrEqualTo(100));
      });
    });

    group('막대 그래프 데이터 업데이트 테스트', () {
      test('유효한 인덱스로 막대 데이터 카테고리 업데이트', () {
        const int testIndex = 0;
        const double testValue = 50.0;
        const String testCategory = 'TestCategory';

        provider.updateBarDataCategory(testIndex, testCategory, testValue);

        final BarChartDataModel updatedData = provider.barChartData[testIndex];
        // baseUsage가 업데이트되었는지 확인
        expect(updatedData.baseUsage, testValue);
      });

      test('막대 데이터 개별 카테고리 업데이트', () {
        const int testIndex = 2;
        const double testValue = 75.0;

        provider.updateBarData(testIndex, baseUsage: testValue);

        expect(provider.barChartData[testIndex].baseUsage, testValue);
      });

      test('막대 데이터 전체 카테고리 업데이트', () {
        const int testIndex = 1;

        provider.updateBarData(
          testIndex,
          baseUsage: 10.0,
          acUsage: 20.0,
          heatingUsage: 30.0,
          etcUsage: 40.0,
        );

        final BarChartDataModel updatedData = provider.barChartData[testIndex];
        expect(updatedData.baseUsage, 10.0);
        expect(updatedData.acUsage, 20.0);
        expect(updatedData.heatingUsage, 30.0);
        expect(updatedData.etcUsage, 40.0);
      });
    });

    group('원형 그래프 데이터 업데이트 테스트', () {
      test('유효한 현재 사용량 업데이트', () {
        const double testUsage = 75.0;

        provider.updatePieCurrentUsage(testUsage);

        expect(provider.pieChartData.currentUsage, testUsage);
        expect(provider.pieChartData.percentage, 75.0); // 100 중 75
      });

      test('유효한 총 용량 업데이트', () {
        const double testCapacity = 200.0;
        final double originalUsage = provider.pieChartData.currentUsage;

        provider.updatePieTotalCapacity(testCapacity);

        expect(provider.pieChartData.totalCapacity, testCapacity);
        expect(provider.pieChartData.currentUsage, originalUsage);
      });

      test('전체 원형 데이터 업데이트', () {
        const double testUsage = 80.0;
        const double testCapacity = 150.0;

        provider.updatePieData(
          currentUsage: testUsage,
          totalCapacity: testCapacity,
        );

        expect(provider.pieChartData.currentUsage, testUsage);
        expect(provider.pieChartData.totalCapacity, testCapacity);
      });
    });

    group('차트 타입 전환 테스트', () {
      test('차트 타입 토글', () {
        expect(provider.isBarChart, true);

        provider.toggleChartType();
        expect(provider.isBarChart, false);

        provider.toggleChartType();
        expect(provider.isBarChart, true);
      });

      test('특정 차트 타입 설정', () {
        provider.setChartType(ChartType.pie);
        expect(provider.isBarChart, false);

        provider.setChartType(ChartType.bar);
        expect(provider.isBarChart, true);
      });
    });

    group('색상 스키마 테스트', () {
      test('색상 스키마 업데이트', () {
        const ChartColorScheme newColorScheme = ChartColorScheme(
          baseUsageColor: Color(0xFF111111),
          acUsageColor: Color(0xFF222222),
          heatingUsageColor: Color(0xFF333333),
          etcUsageColor: Color(0xFF444444),
        );

        provider.updateColorScheme(newColorScheme);

        expect(
            provider.colorScheme.baseUsageColor, newColorScheme.baseUsageColor);
        expect(provider.colorScheme.acUsageColor, newColorScheme.acUsageColor);
        expect(provider.colorScheme.heatingUsageColor,
            newColorScheme.heatingUsageColor);
        expect(
            provider.colorScheme.etcUsageColor, newColorScheme.etcUsageColor);
      });
    });

    group('데이터 초기화 테스트', () {
      test('데이터 초기화', () {
        // 데이터 변경
        provider.updateBarData(0, baseUsage: 999.0);
        provider.updatePieCurrentUsage(99.0);

        // 초기화
        provider.initializeData();

        // 기본 데이터로 복원되었는지 확인
        expect(provider.barChartData.length, 7);
        expect(provider.pieChartData.totalCapacity, 100.0);
      });
    });

    group('계산된 속성 테스트', () {
      test('막대 그래프 최대값 계산', () {
        // 알려진 값으로 데이터 설정
        provider.updateBarData(0,
            baseUsage: 100.0, acUsage: 0, heatingUsage: 0, etcUsage: 0);
        provider.updateBarData(1,
            baseUsage: 50.0, acUsage: 0, heatingUsage: 0, etcUsage: 0);
        provider.updateBarData(2,
            baseUsage: 30.0, acUsage: 45.0, heatingUsage: 0, etcUsage: 0);

        final double maxValue = provider.barChartData
            .map((BarChartDataModel data) => data.totalUsage)
            .reduce((double a, double b) => a > b ? a : b);
        expect(maxValue, 100.0);
      });

      test('원형 그래프 백분율 계산', () {
        provider.updatePieCurrentUsage(30.0);
        provider.updatePieTotalCapacity(100.0);

        expect(provider.pieChartData.percentage, 30.0);
      });
    });

    group('상태 변경 알림 테스트', () {
      test('데이터 변경 시 리스너에 알림', () {
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });

        provider.updateBarData(0, baseUsage: 123.0);

        expect(notified, true);
      });

      test('차트 타입 변경 시 리스너에 알림', () {
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });

        provider.toggleChartType();

        expect(notified, true);
      });
    });

    group('에러 처리 테스트', () {
      test('null 안전성 테스트', () {
        expect(provider.barChartData, isNotNull);
        expect(provider.pieChartData, isNotNull);
        expect(provider.colorScheme, isNotNull);
      });
    });

    group('디버그 유틸리티 테스트', () {
      test('디버그 상태 출력', () {
        expect(() => provider.debugPrintState(), returnsNormally);
      });
    });
  });
}
