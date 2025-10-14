import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarChartDataModel Tests', () {
    test('should create BarChartDataModel with correct values', () {
      // Arrange
      const String label = '1일';
      const double baseUsage = 40.0;
      const double acUsage = 30.0;
      const double heatingUsage = 20.0;
      const double etcUsage = 10.0;

      // Act
      final BarChartDataModel model = BarChartDataModel(
        label: label,
        baseUsage: baseUsage,
        acUsage: acUsage,
        heatingUsage: heatingUsage,
        etcUsage: etcUsage,
      );

      // Assert
      expect(model.label, equals(label));
      expect(model.baseUsage, equals(baseUsage));
      expect(model.acUsage, equals(acUsage));
      expect(model.heatingUsage, equals(heatingUsage));
      expect(model.etcUsage, equals(etcUsage));
    });

    test('should calculate total usage correctly', () {
      // Arrange
      final BarChartDataModel model = BarChartDataModel(
        label: '1일',
        baseUsage: 40.0,
        acUsage: 30.0,
        heatingUsage: 20.0,
        etcUsage: 10.0,
      );

      // Act
      final double totalUsage = model.totalUsage;

      // Assert
      expect(totalUsage, equals(100.0));
    });

    test('should handle zero values correctly', () {
      // Arrange
      final BarChartDataModel model = BarChartDataModel(
        label: '빈 날',
        baseUsage: 0.0,
        acUsage: 0.0,
        heatingUsage: 0.0,
        etcUsage: 0.0,
      );

      // Act & Assert
      expect(model.totalUsage, equals(0.0));
    });

    test('should create copy with updated values using copyWith', () {
      // Arrange
      final BarChartDataModel original = BarChartDataModel(
        label: '1일',
        baseUsage: 40.0,
        acUsage: 30.0,
        heatingUsage: 20.0,
        etcUsage: 10.0,
      );

      // Act
      final BarChartDataModel updated = original.copyWith(
        label: '수정된 날',
        baseUsage: 50.0,
      );

      // Assert
      expect(updated.label, equals('수정된 날'));
      expect(updated.baseUsage, equals(50.0));
      expect(updated.acUsage, equals(30.0)); // 변경되지 않음
      expect(updated.heatingUsage, equals(20.0)); // 변경되지 않음
      expect(updated.etcUsage, equals(10.0)); // 변경되지 않음

      // 원본은 변경되지 않음
      expect(original.label, equals('1일'));
      expect(original.baseUsage, equals(40.0));
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final BarChartDataModel model = BarChartDataModel(
        label: '1일',
        baseUsage: 40.0,
        acUsage: 30.0,
        heatingUsage: 20.0,
        etcUsage: 10.0,
      );

      // Act
      final Map<String, dynamic> json = model.toJson();

      // Assert
      expect(json['label'], equals('1일'));
      expect(json['baseUsage'], equals(40.0));
      expect(json['acUsage'], equals(30.0));
      expect(json['heatingUsage'], equals(20.0));
      expect(json['etcUsage'], equals(10.0));
    });

    test('should create from JSON correctly', () {
      // Arrange
      final Map<String, Object> json = <String, Object>{
        'label': '테스트 날',
        'baseUsage': 45.5,
        'acUsage': 35.2,
        'heatingUsage': 25.8,
        'etcUsage': 15.3,
      };

      // Act
      final BarChartDataModel model = BarChartDataModel.fromJson(json);

      // Assert
      expect(model.label, equals('테스트 날'));
      expect(model.baseUsage, equals(45.5));
      expect(model.acUsage, equals(35.2));
      expect(model.heatingUsage, equals(25.8));
      expect(model.etcUsage, equals(15.3));
    });

    test('should handle decimal values correctly', () {
      // Arrange
      final BarChartDataModel model = BarChartDataModel(
        label: '소수점 테스트',
        baseUsage: 12.34,
        acUsage: 56.78,
        heatingUsage: 9.12,
        etcUsage: 3.45,
      );

      // Act
      final double totalUsage = model.totalUsage;

      // Assert
      expect(totalUsage, closeTo(81.69, 0.01));
    });
  });

  group('PieChartDataModel Tests', () {
    test('should create PieChartDataModel with correct values', () {
      // Arrange
      const double currentUsage = 800.0;
      const double totalCapacity = 4800.0;
      const MaterialColor primaryColor = Colors.blue;
      const MaterialColor backgroundColor = Colors.grey;

      // Act
      final PieChartDataModel model = PieChartDataModel(
        currentUsage: currentUsage,
        totalCapacity: totalCapacity,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
      );

      // Assert
      expect(model.currentUsage, equals(currentUsage));
      expect(model.totalCapacity, equals(totalCapacity));
      expect(model.primaryColor, equals(primaryColor));
      expect(model.backgroundColor, equals(backgroundColor));
    });

    test('should calculate percentage correctly', () {
      // Arrange
      final PieChartDataModel model = PieChartDataModel(
        currentUsage: 800.0,
        totalCapacity: 4800.0,
        primaryColor: Colors.blue,
        backgroundColor: Colors.grey,
      );

      // Act
      final double percentage = model.percentage;

      // Assert
      expect(percentage, closeTo(16.67, 0.01));
    });

    test('should handle zero total capacity without error', () {
      // Arrange
      final PieChartDataModel model = PieChartDataModel(
        currentUsage: 100.0,
        totalCapacity: 0.0,
        primaryColor: Colors.blue,
        backgroundColor: Colors.grey,
      );

      // Act
      final double percentage = model.percentage;

      // Assert
      expect(percentage, equals(0.0));
    });

    test('should handle 100% usage correctly', () {
      // Arrange
      final PieChartDataModel model = PieChartDataModel(
        currentUsage: 1000.0,
        totalCapacity: 1000.0,
        primaryColor: Colors.red,
        backgroundColor: Colors.grey,
      );

      // Act
      final double percentage = model.percentage;

      // Assert
      expect(percentage, equals(100.0));
    });

    test('should create copy with updated values using copyWith', () {
      // Arrange
      final PieChartDataModel original = PieChartDataModel(
        currentUsage: 800.0,
        totalCapacity: 4800.0,
        primaryColor: Colors.blue,
        backgroundColor: Colors.grey,
      );

      // Act
      final PieChartDataModel updated = original.copyWith(
        currentUsage: 1200.0,
        primaryColor: Colors.red,
      );

      // Assert
      expect(updated.currentUsage, equals(1200.0));
      expect(updated.totalCapacity, equals(4800.0)); // 변경되지 않음
      expect(updated.primaryColor, equals(Colors.red));
      expect(updated.backgroundColor, equals(Colors.grey)); // 변경되지 않음

      // 원본은 변경되지 않음
      expect(original.currentUsage, equals(800.0));
      expect(original.primaryColor, equals(Colors.blue));
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final PieChartDataModel model = PieChartDataModel(
        currentUsage: 800.0,
        totalCapacity: 4800.0,
        primaryColor: Colors.blue,
        backgroundColor: Colors.grey,
      );

      // Act
      final Map<String, dynamic> json = model.toJson();

      // Assert
      expect(json['currentUsage'], equals(800.0));
      expect(json['totalCapacity'], equals(4800.0));
      expect(json['primaryColor'], isA<int>());
      expect(json['backgroundColor'], isA<int>());
    });

    test('should create from JSON with default colors', () {
      // Arrange
      final Map<String, num> json = <String, num>{
        'currentUsage': 1000.0,
        'totalCapacity': 5000.0,
        'primaryColor': 123456,
        'backgroundColor': 789012,
      };

      // Act
      final PieChartDataModel model = PieChartDataModel.fromJson(json);

      // Assert
      expect(model.currentUsage, equals(1000.0));
      expect(model.totalCapacity, equals(5000.0));
      expect(model.primaryColor, isA<Color>());
      expect(model.backgroundColor, isA<Color>());
    });
  });

  group('ChartColorScheme Tests', () {
    test('should use default color scheme correctly', () {
      // Arrange & Act
      const ChartColorScheme colorScheme = ChartColorScheme.defaultScheme;

      // Assert
      expect(colorScheme.baseUsageColor, equals(Colors.amber));
      expect(colorScheme.acUsageColor, equals(Colors.blue));
      expect(colorScheme.heatingUsageColor, equals(Colors.red));
      expect(colorScheme.etcUsageColor, equals(Colors.grey));
    });

    test('should return colors list correctly', () {
      // Arrange
      const ChartColorScheme colorScheme = ChartColorScheme.defaultScheme;

      // Act
      final List<Color> colors = colorScheme.colors;

      // Assert
      expect(colors.length, equals(4));
      expect(colors[0], equals(Colors.amber));
      expect(colors[1], equals(Colors.blue));
      expect(colors[2], equals(Colors.red));
      expect(colors[3], equals(Colors.grey));
    });

    test('should create copy with updated colors using copyWith', () {
      // Arrange
      const ChartColorScheme original = ChartColorScheme.defaultScheme;

      // Act
      final ChartColorScheme updated = original.copyWith(
        baseUsageColor: Colors.green,
        acUsageColor: Colors.purple,
      );

      // Assert
      expect(updated.baseUsageColor, equals(Colors.green));
      expect(updated.acUsageColor, equals(Colors.purple));
      expect(updated.heatingUsageColor, equals(Colors.red)); // 변경되지 않음
      expect(updated.etcUsageColor, equals(Colors.grey)); // 변경되지 않음
    });

    test('should create custom color scheme', () {
      // Arrange & Act
      const ChartColorScheme customScheme = ChartColorScheme(
        baseUsageColor: Colors.orange,
        acUsageColor: Colors.cyan,
        heatingUsageColor: Colors.pink,
        etcUsageColor: Colors.brown,
      );

      // Assert
      expect(customScheme.baseUsageColor, equals(Colors.orange));
      expect(customScheme.acUsageColor, equals(Colors.cyan));
      expect(customScheme.heatingUsageColor, equals(Colors.pink));
      expect(customScheme.etcUsageColor, equals(Colors.brown));
    });
  });
}
