import 'package:flutter/material.dart';

/// 지원되는 차트 타입
enum ChartType {
  bar, // 막대 차트
  pie, // 원형 차트
  line, // 라인 차트
  stackedBar, // 스택형 막대 차트
  donut, // 도넛 차트
  halfDonut, // 반쪽 도넛 차트
  lineOutDoorTemp,
  lineSetTemp,
  clusterStackBar,
}

extension ChartTypeExtension on ChartType {
  String get displayName {
    switch (this) {
      case ChartType.bar:
        return '막대 그래프';
      case ChartType.pie:
        return '원형 그래프';
      case ChartType.line:
        return '라인 그래프';
      case ChartType.stackedBar:
        return '스택형 막대 그래프';
      case ChartType.donut:
        return '도넛 그래프';
      case ChartType.halfDonut:
        return '반쪽 도넛 그래프';
      case ChartType.lineOutDoorTemp:
        return 'Line chart outdoor temp';
      case ChartType.lineSetTemp:
        return 'Line chart set temp';
      case ChartType.clusterStackBar:
        return 'Cluster Stacked Bar chart';
    }
  }

  IconData get icon {
    switch (this) {
      case ChartType.bar:
        return Icons.bar_chart;
      case ChartType.pie:
        return Icons.pie_chart;
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.stackedBar:
        return Icons.stacked_bar_chart;
      case ChartType.donut:
        return Icons.donut_large;
      case ChartType.halfDonut:
        return Icons.donut_small;
      case ChartType.lineOutDoorTemp:
      case ChartType.lineSetTemp:
        return Icons.show_chart;
      case ChartType.clusterStackBar:
        return Icons.stacked_bar_chart;
    }
  }

  Color get indicatorColor {
    switch (this) {
      case ChartType.bar:
        return Colors.blue;
      case ChartType.pie:
        return Colors.green;
      case ChartType.line:
        return Colors.orange;
      case ChartType.stackedBar:
        return Colors.purple;
      case ChartType.donut:
        return Colors.teal;
      case ChartType.halfDonut:
        return Colors.indigo;
      case ChartType.lineOutDoorTemp:
        return Colors.orange;
      case ChartType.lineSetTemp:
        return Colors.orange; 
      case ChartType.clusterStackBar:
        return Colors.purple;
    }
  }
}

/// 막대 그래프를 위한 데이터 모델
class BarChartDataModel {
  BarChartDataModel({
    required this.label,
    required this.baseUsage,
    required this.acUsage,
    required this.heatingUsage,
    required this.etcUsage,
  });

  /// JSON에서 생성
  factory BarChartDataModel.fromJson(Map<String, dynamic> json) {
    return BarChartDataModel(
      label: json['label'] as String,
      baseUsage: (json['baseUsage'] as num).toDouble(),
      acUsage: (json['acUsage'] as num).toDouble(),
      heatingUsage: (json['heatingUsage'] as num).toDouble(),
      etcUsage: (json['etcUsage'] as num).toDouble(),
    );
  }
  final String label;
  final double baseUsage;
  final double acUsage;
  final double heatingUsage;
  final double etcUsage;

  /// 총 사용량 계산
  double get totalUsage => baseUsage + acUsage + heatingUsage + etcUsage;

  /// 복사본 생성 (값 변경을 위한 메서드)
  BarChartDataModel copyWith({
    String? label,
    double? baseUsage,
    double? acUsage,
    double? heatingUsage,
    double? etcUsage,
  }) {
    return BarChartDataModel(
      label: label ?? this.label,
      baseUsage: baseUsage ?? this.baseUsage,
      acUsage: acUsage ?? this.acUsage,
      heatingUsage: heatingUsage ?? this.heatingUsage,
      etcUsage: etcUsage ?? this.etcUsage,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'baseUsage': baseUsage,
      'acUsage': acUsage,
      'heatingUsage': heatingUsage,
      'etcUsage': etcUsage,
    };
  }
}

/// 라인 차트를 위한 데이터 포인트 모델
class LineChartDataPoint {
  LineChartDataPoint({
    required this.label,
    required this.value,
    this.timestamp,
  });

  /// JSON에서 생성
  factory LineChartDataPoint.fromJson(Map<String, dynamic> json) {
    return LineChartDataPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
  final String label;
  final double value;
  final DateTime? timestamp;

  /// 복사본 생성
  LineChartDataPoint copyWith({
    String? label,
    double? value,
    DateTime? timestamp,
  }) {
    return LineChartDataPoint(
      label: label ?? this.label,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'value': value,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

/// 라인 차트를 위한 데이터 모델
class LineChartDataModel {
  LineChartDataModel({
    required this.seriesName,
    required this.dataPoints,
    this.lineColor = Colors.blue,
    this.lineWidth = 2.0,
    this.showDots = true,
  });

  /// JSON에서 생성
  factory LineChartDataModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> colorData =
        json['lineColor'] as Map<String, dynamic>;
    final Color color = Color.fromARGB(
      colorData['alpha'] as int,
      colorData['red'] as int,
      colorData['green'] as int,
      colorData['blue'] as int,
    );

    return LineChartDataModel(
      seriesName: json['seriesName'] as String,
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((dynamic pointJson) =>
              LineChartDataPoint.fromJson(pointJson as Map<String, dynamic>))
          .toList(),
      lineColor: color,
      lineWidth: (json['lineWidth'] as num).toDouble(),
      showDots: json['showDots'] as bool,
    );
  }
  final String seriesName;
  final List<LineChartDataPoint> dataPoints;
  final Color lineColor;
  final double lineWidth;
  final bool showDots;

  /// 최대값 계산
  double get maxValue => dataPoints.isEmpty
      ? 0.0
      : dataPoints
          .map((LineChartDataPoint point) => point.value)
          .reduce((double a, double b) => a > b ? a : b);

  /// 최소값 계산
  double get minValue => dataPoints.isEmpty
      ? 0.0
      : dataPoints
          .map((LineChartDataPoint point) => point.value)
          .reduce((double a, double b) => a < b ? a : b);

  /// 복사본 생성
  LineChartDataModel copyWith({
    String? seriesName,
    List<LineChartDataPoint>? dataPoints,
    Color? lineColor,
    double? lineWidth,
    bool? showDots,
  }) {
    return LineChartDataModel(
      seriesName: seriesName ?? this.seriesName,
      dataPoints: dataPoints ?? this.dataPoints,
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      showDots: showDots ?? this.showDots,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'seriesName': seriesName,
      'dataPoints':
          dataPoints.map((LineChartDataPoint point) => point.toJson()).toList(),
      'lineColor': <String, double>{
        'red': lineColor.r,
        'green': lineColor.g,
        'blue': lineColor.b,
        'alpha': lineColor.a,
      },
      'lineWidth': lineWidth,
      'showDots': showDots,
    };
  }
}

/// 원형 그래프를 위한 데이터 모델
class PieChartDataModel {
  PieChartDataModel({
    required this.currentUsage,
    required this.totalCapacity,
    required this.primaryColor,
    required this.backgroundColor,
  });

  /// JSON에서 생성 (간단한 복원 - 기본 색상 사용)
  factory PieChartDataModel.fromJson(Map<String, dynamic> json) {
    return PieChartDataModel(
      currentUsage: (json['currentUsage'] as num).toDouble(),
      totalCapacity: (json['totalCapacity'] as num).toDouble(),
      primaryColor: Colors.grey.shade600, // 기본값 사용
      backgroundColor: Colors.grey.shade300, // 기본값 사용
    );
  }
  final double currentUsage;
  final double totalCapacity;
  final Color primaryColor;
  final Color backgroundColor;

  /// 사용률 퍼센티지 계산
  double get percentage =>
      totalCapacity > 0 ? (currentUsage / totalCapacity) * 100 : 0.0;

  /// 복사본 생성 (값 변경을 위한 메서드)
  PieChartDataModel copyWith({
    double? currentUsage,
    double? totalCapacity,
    Color? primaryColor,
    Color? backgroundColor,
  }) {
    return PieChartDataModel(
      currentUsage: currentUsage ?? this.currentUsage,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// JSON으로 변환 (색상은 간단한 int 값으로)
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentUsage': currentUsage,
      'totalCapacity': totalCapacity,
      'primaryColor': primaryColor.hashCode,
      'backgroundColor': backgroundColor.hashCode,
    };
  }
}

/// 차트 색상 설정을 위한 모델
class ChartColorScheme {
  const ChartColorScheme({
    required this.baseUsageColor,
    required this.acUsageColor,
    required this.heatingUsageColor,
    required this.etcUsageColor,
  });
  final Color baseUsageColor;
  final Color acUsageColor;
  final Color heatingUsageColor;
  final Color etcUsageColor;

  /// 기본 색상 스키마
  static const ChartColorScheme defaultScheme = ChartColorScheme(
    baseUsageColor: Colors.amber, // 기본 사용량 - 노란색
    acUsageColor: Colors.blue, // 에어컨 - 파란색
    heatingUsageColor: Colors.red, // 난방 - 빨간색
    etcUsageColor: Colors.grey, // 기타 - 회색
  );

  /// 색상 리스트 반환
  List<Color> get colors => <Color>[
        baseUsageColor,
        acUsageColor,
        heatingUsageColor,
        etcUsageColor,
      ];

  /// 복사본 생성
  ChartColorScheme copyWith({
    Color? baseUsageColor,
    Color? acUsageColor,
    Color? heatingUsageColor,
    Color? etcUsageColor,
  }) {
    return ChartColorScheme(
      baseUsageColor: baseUsageColor ?? this.baseUsageColor,
      acUsageColor: acUsageColor ?? this.acUsageColor,
      heatingUsageColor: heatingUsageColor ?? this.heatingUsageColor,
      etcUsageColor: etcUsageColor ?? this.etcUsageColor,
    );
  }
}

/// 스택형 막대 차트를 위한 데이터 모델
class StackedBarChartData {
  // 각 스택 항목의 색상 (key: 항목명, value: 색상)

  const StackedBarChartData({
    required this.category,
    required this.values,
    required this.colors,
  });

  /// 기본 생성자 (4개 카테고리용)
  factory StackedBarChartData.fromUsageData({
    required String category,
    required double baseUsage,
    required double acUsage,
    required double heatingUsage,
    required double etcUsage,
    ChartColorScheme? colorScheme,
  }) {
    final ChartColorScheme scheme =
        colorScheme ?? ChartColorScheme.defaultScheme;

    return StackedBarChartData(
      category: category,
      values: <String, double>{
        'Base': baseUsage,
        'AC': acUsage,
        'Heating': heatingUsage,
        'Other': etcUsage,
      },
      colors: <String, Color>{
        'Base': scheme.baseUsageColor,
        'AC': scheme.acUsageColor,
        'Heating': scheme.heatingUsageColor,
        'Other': scheme.etcUsageColor,
      },
    );
  }
  final String category; // 카테고리 (예: 'Jan', 'Feb' 등)
  final Map<String, double> values; // 각 스택 항목의 값 (key: 항목명, value: 사용량)
  final Map<String, Color> colors;

  /// 총 사용량 계산
  double get totalUsage {
    return values.values.fold(0.0, (double sum, double value) => sum + value);
  }

  /// 각 항목의 백분율 계산
  Map<String, double> get percentages {
    if (totalUsage == 0) {
      return Map<String, double>.fromIterables(
          values.keys, List<double>.filled(values.length, 0.0));
    }

    return values.map((String key, double value) =>
        MapEntry<String, double>(key, (value / totalUsage) * 100));
  }

  /// 특정 항목의 값 반환
  double getValue(String key) => values[key] ?? 0.0;

  /// 특정 항목의 색상 반환
  Color getColor(String key) => colors[key] ?? Colors.grey;

  /// 특정 항목의 백분율 반환
  double getPercentage(String key) => percentages[key] ?? 0.0;

  /// 복사본 생성
  StackedBarChartData copyWith({
    String? category,
    Map<String, double>? values,
    Map<String, Color>? colors,
  }) {
    return StackedBarChartData(
      category: category ?? this.category,
      values: values ?? Map<String, double>.from(this.values),
      colors: colors ?? Map<String, Color>.from(this.colors),
    );
  }

  @override
  String toString() {
    return 'StackedBarChartData(category: $category, totalUsage: ${totalUsage.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StackedBarChartData &&
        other.category == category &&
        _mapEquals(other.values, values) &&
        _mapEquals(other.colors, colors);
  }

  @override
  int get hashCode {
    return category.hashCode ^ values.hashCode ^ colors.hashCode;
  }

  /// Map 비교 유틸리티
  bool _mapEquals<K, V>(Map<K, V>? map1, Map<K, V>? map2) {
    if (map1 == null && map2 == null) {
      return true;
    }
    if (map1 == null || map2 == null) {
      return false;
    }
    if (map1.length != map2.length) {
      return false;
    }

    for (final dynamic key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}
