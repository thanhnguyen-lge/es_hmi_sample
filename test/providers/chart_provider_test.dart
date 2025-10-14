import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:chart_sample_app/providers/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartProvider Tests', () {
    late ChartProvider provider;

    setUp(() {
      provider = ChartProvider();
      provider.initializeData(); // 테스트용 데이터 초기화
    });

    group('초기화 테스트', () {
      test('Provider가 올바른 초기 상태를 가져야 함', () {
        expect(provider.isBarChart, true);
        expect(provider.isLoading, false);
        expect(provider.barChartData.length, 7); // 7일간의 데이터
        expect(provider.pieChartData.totalCapacity, greaterThan(0));
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
        const String testCategory = 'baseUsage';

        provider.updateBarDataCategory(testIndex, testCategory, testValue);

        final BarChartDataModel updatedData = provider.barChartData[testIndex];
        // baseUsage가 업데이트되었는지 확인
        expect(updatedData.baseUsage, testValue);
      });

      test('잘못된 인덱스로 막대 데이터 업데이트 시 무시', () {
        final List<BarChartDataModel> originalData =
            List<BarChartDataModel>.from(provider.barChartData);

        provider.updateBarDataCategory(-1, 'Invalid', 50.0);
        provider.updateBarDataCategory(999, 'Invalid', 50.0);

        expect(provider.barChartData.length, originalData.length);
      });

      test('음수 값으로 막대 데이터 업데이트 시 무시', () {
        final BarChartDataModel originalData = provider.barChartData[0];

        provider.updateBarDataCategory(0, 'Test', -10.0);

        expect(provider.barChartData[0].baseUsage, originalData.baseUsage);
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
        // 기본 총 용량 4800 중 75 사용시 백분율 계산
        expect(provider.pieChartData.percentage,
            closeTo(1.5625, 0.001)); // 75/4800 * 100
      });

      test('음수 현재 사용량 업데이트 시 무시', () {
        final double originalUsage = provider.pieChartData.currentUsage;

        provider.updatePieCurrentUsage(-10.0);

        expect(provider.pieChartData.currentUsage, originalUsage);
      });

      test('총 용량을 초과하는 현재 사용량 업데이트 시 무시', () {
        final double originalUsage = provider.pieChartData.currentUsage;
        final double totalCapacity = provider.pieChartData.totalCapacity;

        provider.updatePieCurrentUsage(totalCapacity + 10);

        expect(provider.pieChartData.currentUsage, originalUsage);
      });

      test('유효한 총 용량 업데이트', () {
        const double testCapacity = 200.0;
        final double originalUsage = provider.pieChartData.currentUsage;

        provider.updatePieTotalCapacity(testCapacity);

        expect(provider.pieChartData.totalCapacity, testCapacity);
        expect(provider.pieChartData.currentUsage, originalUsage);
      });

      test('0 이하의 총 용량 업데이트 시 무시', () {
        final double originalCapacity = provider.pieChartData.totalCapacity;

        provider.updatePieTotalCapacity(0);
        provider.updatePieTotalCapacity(-10);

        expect(provider.pieChartData.totalCapacity, originalCapacity);
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
        expect(provider.isPieChart, true);

        provider.toggleChartType();
        expect(provider.isLineChart, true);

        provider.toggleChartType();
        expect(provider.isStackedBarChart, true);

        provider.toggleChartType();
        expect(provider.isDonutChart, true);

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

      test('개별 색상 업데이트', () {
        const Color newBaseColor = Color(0xFF999999);

        provider.updateColor('base', newBaseColor);

        expect(provider.colorScheme.baseUsageColor, newBaseColor);
      });

      test('잘못된 색상 타입으로 개별 색상 업데이트 시 무시', () {
        final ChartColorScheme originalColorScheme = provider.colorScheme;

        provider.updateColor('invalid', const Color(0xFF999999));

        expect(provider.colorScheme.baseUsageColor,
            originalColorScheme.baseUsageColor);
        expect(provider.colorScheme.acUsageColor,
            originalColorScheme.acUsageColor);
        expect(provider.colorScheme.heatingUsageColor,
            originalColorScheme.heatingUsageColor);
        expect(provider.colorScheme.etcUsageColor,
            originalColorScheme.etcUsageColor);
      });
    });

    group('데이터 초기화 테스트', () {
      test('데이터 초기화', () {
        // 데이터 변경
        provider.updateBarData(0, baseUsage: 999.0);
        provider.updatePieCurrentUsage(99.0);

        // 초기화 - 샘플 데이터로 리셋
        provider.resetData();

        // 샘플 데이터로 복원되었는지 확인
        expect(provider.barChartData.length, 7);
        expect(provider.pieChartData.totalCapacity, 4800.0); // 실제 샘플 데이터 값
      });

      test('빈 데이터로 초기화', () {
        // 빈 데이터로 초기화 - 현재 API에 맞는 메서드 사용
        provider.resetToEmpty();

        expect(provider.barChartData.length, 7); // 7일간의 빈 데이터
        expect(
            provider.barChartData
                .every((BarChartDataModel data) => data.totalUsage == 0),
            true); // 모든 사용량이 0
        expect(provider.pieChartData.currentUsage, 0);
        expect(provider.pieChartData.totalCapacity, 100.0);
      });
    });

    group('계산된 속성 테스트', () {
      test('막대 그래프 최대값 계산', () {
        // 모든 데이터를 알려진 값으로 설정
        for (int i = 0; i < 7; i++) {
          provider.updateBarData(i,
              baseUsage: 0, acUsage: 0, heatingUsage: 0, etcUsage: 0);
        }

        // 특정 값들 설정
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
      test('잘못된 인덱스 접근 시 안전 처리', () {
        expect(
            () => provider.updateBarData(-1, baseUsage: 50.0), returnsNormally);
        expect(() => provider.updateBarData(999, baseUsage: 50.0),
            returnsNormally);
      });

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

    group('스택형 막대 차트 테스트', () {
      test('초기 스택형 차트 데이터가 유효해야 함', () {
        expect(provider.stackedBarChartData, isNotEmpty);
        expect(provider.stackedBarChartData.length, 6); // 6개월 데이터
        expect(provider.isStackedBarChart, false); // 초기값은 bar 차트
        expect(provider.maxStackedBarChartValue, greaterThan(0));
      });

      test('스택형 차트 데이터 각 항목이 유효해야 함', () {
        final List<StackedBarChartData> stackedData =
            provider.stackedBarChartData;

        for (final StackedBarChartData data in stackedData) {
          expect(data.category, isNotEmpty);
          expect(data.totalUsage, greaterThan(0));
          expect(data.values, isNotEmpty);
          expect(data.colors, isNotEmpty);

          // 각 카테고리 값들이 0 이상이어야 함
          expect(data.getValue('Base'), greaterThanOrEqualTo(0));
          expect(data.getValue('AC'), greaterThanOrEqualTo(0));
          expect(data.getValue('Heating'), greaterThanOrEqualTo(0));
          expect(data.getValue('Other'), greaterThanOrEqualTo(0));

          // 백분율 계산이 올바른지 확인
          final Map<String, double> percentages = data.percentages;
          final double totalPercentage = percentages.values
              .fold(0.0, (double sum, double pct) => sum + pct);
          expect(totalPercentage, closeTo(100.0, 0.01));
        }
      });

      test('스택형 차트 데이터 업데이트', () {
        final List<StackedBarChartData> newData = <StackedBarChartData>[
          StackedBarChartData.fromUsageData(
            category: 'Test1',
            baseUsage: 30.0,
            acUsage: 20.0,
            heatingUsage: 10.0,
            etcUsage: 15.0,
          ),
          StackedBarChartData.fromUsageData(
            category: 'Test2',
            baseUsage: 35.0,
            acUsage: 25.0,
            heatingUsage: 5.0,
            etcUsage: 20.0,
          ),
        ];

        provider.updateStackedBarChartData(newData);

        expect(provider.stackedBarChartData.length, 2);
        expect(provider.stackedBarChartData[0].category, 'Test1');
        expect(provider.stackedBarChartData[1].category, 'Test2');
        expect(provider.stackedBarChartData[0].totalUsage, 75.0);
        expect(provider.stackedBarChartData[1].totalUsage, 85.0);
      });

      test('스택형 차트 데이터 추가', () {
        final int initialCount = provider.stackedBarChartData.length;

        final StackedBarChartData newItem = StackedBarChartData.fromUsageData(
          category: 'NewMonth',
          baseUsage: 40.0,
          acUsage: 30.0,
          heatingUsage: 8.0,
          etcUsage: 12.0,
        );

        provider.addStackedBarChartData(newItem);

        expect(provider.stackedBarChartData.length, initialCount + 1);
        expect(provider.stackedBarChartData.last.category, 'NewMonth');
        expect(provider.stackedBarChartData.last.totalUsage, 90.0);
      });

      test('스택형 차트 데이터 제거', () {
        final int initialCount = provider.stackedBarChartData.length;
        expect(initialCount, greaterThan(0));

        final String firstCategory = provider.stackedBarChartData[0].category;
        provider.removeStackedBarChartData(0);

        expect(provider.stackedBarChartData.length, initialCount - 1);

        // 첫 번째 항목이 제거되었는지 확인
        if (provider.stackedBarChartData.isNotEmpty) {
          expect(
              provider.stackedBarChartData[0].category, isNot(firstCategory));
        }
      });

      test('잘못된 인덱스로 스택형 차트 데이터 제거 시도', () {
        final int initialCount = provider.stackedBarChartData.length;

        // 음수 인덱스
        provider.removeStackedBarChartData(-1);
        expect(provider.stackedBarChartData.length, initialCount);

        // 범위를 벗어난 인덱스
        provider.removeStackedBarChartData(9999);
        expect(provider.stackedBarChartData.length, initialCount);
      });

      test('최대 스택형 차트 값 계산', () {
        final double maxValue = provider.maxStackedBarChartValue;

        // 실제 데이터에서 최대값을 직접 계산
        final double actualMax = provider.stackedBarChartData
            .map((StackedBarChartData item) => item.totalUsage)
            .reduce((double a, double b) => a > b ? a : b);

        expect(maxValue, actualMax);
        expect(maxValue, greaterThan(0));
      });

      test('빈 스택형 차트 데이터에서 최대값 계산', () {
        provider.updateStackedBarChartData(<StackedBarChartData>[]);
        expect(provider.maxStackedBarChartValue, 100.0); // 기본값
      });

      test('차트 타입 전환에서 스택형 차트 포함', () {
        // bar -> pie
        provider.setChartType(ChartType.bar);
        provider.toggleChartType();
        expect(provider.currentChartType, ChartType.pie);

        // pie -> line
        provider.toggleChartType();
        expect(provider.currentChartType, ChartType.line);

        // line -> stackedBar
        provider.toggleChartType();
        expect(provider.currentChartType, ChartType.stackedBar);
        expect(provider.isStackedBarChart, true);

        // stackedBar -> donut
        provider.toggleChartType();
        expect(provider.currentChartType, ChartType.donut);
        expect(provider.isDonutChart, true);

        // donut -> bar
        provider.toggleChartType();
        expect(provider.currentChartType, ChartType.bar);
        expect(provider.isStackedBarChart, false);
        expect(provider.isDonutChart, false);
      });

      test('스택형 차트 타입 직접 설정', () {
        provider.setChartType(ChartType.stackedBar);
        expect(provider.currentChartType, ChartType.stackedBar);
        expect(provider.isStackedBarChart, true);
        expect(provider.isBarChart, false);
        expect(provider.isPieChart, false);
        expect(provider.isLineChart, false);
        expect(provider.isDonutChart, false);
      });

      test('도넛 차트 타입 직접 설정', () {
        provider.setChartType(ChartType.donut);
        expect(provider.currentChartType, ChartType.donut);
        expect(provider.isDonutChart, true);
        expect(provider.isBarChart, false);
        expect(provider.isPieChart, false);
        expect(provider.isLineChart, false);
        expect(provider.isStackedBarChart, false);
      });
    });
  });
}
