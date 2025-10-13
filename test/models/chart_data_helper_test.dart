import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chart_sample_app/models/chart_data_helper.dart';
import 'package:chart_sample_app/models/chart_data_models.dart';

void main() {
  group('ChartDataHelper Tests', () {
    group('getSampleBarChartData', () {
      test('should return 7 days of sample data', () {
        // Act
        final data = ChartDataHelper.getSampleBarChartData();

        // Assert
        expect(data.length, equals(7));
      });

      test('should return data with correct labels', () {
        // Act
        final data = ChartDataHelper.getSampleBarChartData();

        // Assert
        expect(data[0].label, equals('1일'));
        expect(data[1].label, equals('2일'));
        expect(data[2].label, equals('3일'));
        expect(data[3].label, equals('4일'));
        expect(data[4].label, equals('5일'));
        expect(data[5].label, equals('6일'));
        expect(data[6].label, equals('7일'));
      });

      test('should return data with positive values', () {
        // Act
        final data = ChartDataHelper.getSampleBarChartData();

        // Assert
        for (var item in data) {
          expect(item.baseUsage, greaterThanOrEqualTo(0));
          expect(item.acUsage, greaterThanOrEqualTo(0));
          expect(item.heatingUsage, greaterThanOrEqualTo(0));
          expect(item.etcUsage, greaterThanOrEqualTo(0));
          expect(item.totalUsage, greaterThan(0));
        }
      });

      test('should return data with expected total usage values', () {
        // Act
        final data = ChartDataHelper.getSampleBarChartData();

        // Assert
        expect(data[0].totalUsage, equals(100.0)); // 40+30+20+10
        expect(data[1].totalUsage, equals(110.0)); // 50+25+15+20
        expect(data[2].totalUsage, equals(150.0)); // 70+40+25+15
        expect(data[3].totalUsage, equals(140.0)); // 60+35+30+15
        expect(data[4].totalUsage, equals(65.0)); // 30+15+10+10
        expect(data[5].totalUsage, equals(195.0)); // 90+60+35+10
        expect(data[6].totalUsage, equals(35.0)); // 15+10+5+5
      });
    });

    group('getSamplePieChartData', () {
      test('should return pie chart data with correct values', () {
        // Act
        final data = ChartDataHelper.getSamplePieChartData();

        // Assert
        expect(data.currentUsage, equals(800.0));
        expect(data.totalCapacity, equals(4800.0));
        expect(data.primaryColor, isA<Color>());
        expect(data.backgroundColor, isA<Color>());
      });

      test('should return pie chart data with correct percentage', () {
        // Act
        final data = ChartDataHelper.getSamplePieChartData();

        // Assert
        expect(data.percentage, closeTo(16.67, 0.01)); // 800/4800 * 100
      });
    });

    group('getMaxValueFromBarData', () {
      test('should return correct max value from sample data', () {
        // Arrange
        final data = ChartDataHelper.getSampleBarChartData();

        // Act
        final maxValue = ChartDataHelper.getMaxValueFromBarData(data);

        // Assert
        // 최대값은 195.0 (6일), 10% 추가하면 214.5
        expect(maxValue, closeTo(214.5, 0.1));
      });

      test('should return 100.0 for empty data', () {
        // Arrange
        final emptyData = <BarChartDataModel>[];

        // Act
        final maxValue = ChartDataHelper.getMaxValueFromBarData(emptyData);

        // Assert
        expect(maxValue, equals(100.0));
      });

      test('should handle single item correctly', () {
        // Arrange
        final singleData = [
          BarChartDataModel(
            label: '단일 데이터',
            baseUsage: 50.0,
            acUsage: 30.0,
            heatingUsage: 20.0,
            etcUsage: 10.0,
          ),
        ];

        // Act
        final maxValue = ChartDataHelper.getMaxValueFromBarData(singleData);

        // Assert
        // 총합 110.0에 10% 추가하면 121.0
        expect(maxValue, closeTo(121.0, 0.1));
      });

      test('should handle zero values correctly', () {
        // Arrange
        final zeroData = [
          BarChartDataModel(
            label: '0 데이터',
            baseUsage: 0.0,
            acUsage: 0.0,
            heatingUsage: 0.0,
            etcUsage: 0.0,
          ),
        ];

        // Act
        final maxValue = ChartDataHelper.getMaxValueFromBarData(zeroData);

        // Assert
        // 0에 10% 추가해도 0이므로 최소값 처리가 필요할 수 있음
        expect(maxValue, equals(0.0));
      });
    });

    group('getBarChartLegends', () {
      test('should return 4 legend items', () {
        // Act
        final legends = ChartDataHelper.getBarChartLegends();

        // Assert
        expect(legends.length, equals(4));
      });

      test('should return legend items with correct labels', () {
        // Act
        final legends = ChartDataHelper.getBarChartLegends();

        // Assert
        expect(legends[0].label, equals('기본 사용량'));
        expect(legends[1].label, equals('에어컨'));
        expect(legends[2].label, equals('난방'));
        expect(legends[3].label, equals('기타'));
      });

      test('should return legend items with correct colors', () {
        // Act
        final legends = ChartDataHelper.getBarChartLegends();

        // Assert
        expect(legends[0].color, equals(Colors.amber));
        expect(legends[1].color, equals(Colors.blue));
        expect(legends[2].color, equals(Colors.red));
        expect(legends[3].color, equals(Colors.grey));
      });
    });

    group('getEmptyBarChartData', () {
      test('should return correct number of empty data items', () {
        // Act
        final emptyData3 = ChartDataHelper.getEmptyBarChartData(3);
        final emptyData7 = ChartDataHelper.getEmptyBarChartData(7);

        // Assert
        expect(emptyData3.length, equals(3));
        expect(emptyData7.length, equals(7));
      });

      test('should return data with sequential labels', () {
        // Act
        final emptyData = ChartDataHelper.getEmptyBarChartData(5);

        // Assert
        expect(emptyData[0].label, equals('1일'));
        expect(emptyData[1].label, equals('2일'));
        expect(emptyData[2].label, equals('3일'));
        expect(emptyData[3].label, equals('4일'));
        expect(emptyData[4].label, equals('5일'));
      });

      test('should return data with all zero values', () {
        // Act
        final emptyData = ChartDataHelper.getEmptyBarChartData(3);

        // Assert
        for (var item in emptyData) {
          expect(item.baseUsage, equals(0.0));
          expect(item.acUsage, equals(0.0));
          expect(item.heatingUsage, equals(0.0));
          expect(item.etcUsage, equals(0.0));
          expect(item.totalUsage, equals(0.0));
        }
      });

      test('should handle zero count', () {
        // Act
        final emptyData = ChartDataHelper.getEmptyBarChartData(0);

        // Assert
        expect(emptyData.length, equals(0));
        expect(emptyData, isEmpty);
      });
    });

    group('getEmptyPieChartData', () {
      test('should return pie chart data with zero usage', () {
        // Act
        final emptyData = ChartDataHelper.getEmptyPieChartData();

        // Assert
        expect(emptyData.currentUsage, equals(0.0));
        expect(emptyData.totalCapacity, equals(100.0));
        expect(emptyData.percentage, equals(0.0));
      });

      test('should return pie chart data with default colors', () {
        // Act
        final emptyData = ChartDataHelper.getEmptyPieChartData();

        // Assert
        expect(emptyData.primaryColor, isA<Color>());
        expect(emptyData.backgroundColor, isA<Color>());
      });
    });
  });

  group('LegendItem Tests', () {
    test('should create LegendItem with correct values', () {
      // Arrange
      const label = '테스트 범례';
      const color = Colors.purple;

      // Act
      const legendItem = LegendItem(
        label: label,
        color: color,
      );

      // Assert
      expect(legendItem.label, equals(label));
      expect(legendItem.color, equals(color));
    });
  });
}
