import 'package:flutter/material.dart';

/// 지원되는 차트 타입
enum ChartType {
  bar, // 막대 차트
  pie, // 원형 차트
  line, // 라인 차트
  stackedBar, // 스택형 막대 차트
  donut, // 도넛 차트
  halfDonut, // 반쪽 도넛 차트
  setTemp, // 온도 설정 곡선 차트
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
      case ChartType.setTemp:
        return '온도 설정 곡선';
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
      case ChartType.setTemp:
        return Icons.thermostat;
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
      case ChartType.setTemp:
        return Colors.deepOrange;
      case ChartType.donut:
        return Colors.teal;
      case ChartType.halfDonut:
        return Colors.indigo;
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
    this.lastYearTotal,
    this.lastYearValues,
  });

  /// 기본 생성자 (3개 카테고리용 - DHW only, Cool, Heat)
  factory StackedBarChartData.fromUsageData({
    required String category,
    required double dhwUsage,
    required double coolUsage,
    required double heatUsage,
    double? lastYearTotal,
    double? lastYearDhw,
    double? lastYearCool,
    double? lastYearHeat,
    ChartColorScheme? colorScheme,
  }) {
    final ChartColorScheme scheme =
        colorScheme ?? ChartColorScheme.defaultScheme;

    // 작년 세부 데이터
    Map<String, double>? lastYearValues;
    if (lastYearDhw != null || lastYearCool != null || lastYearHeat != null) {
      lastYearValues = <String, double>{
        'DHW only': lastYearDhw ?? 0.0,
        'Cool': lastYearCool ?? 0.0,
        'Heat': lastYearHeat ?? 0.0,
      };
    }

    return StackedBarChartData(
      category: category,
      values: <String, double>{
        'DHW only': dhwUsage,
        'Cool': coolUsage,
        'Heat': heatUsage,
      },
      colors: <String, Color>{
        'DHW only': scheme.baseUsageColor, // 노란색
        'Cool': scheme.acUsageColor, // 파란색
        'Heat': scheme.heatingUsageColor, // 빨간색
      },
      lastYearTotal: lastYearTotal,
      lastYearValues: lastYearValues,
    );
  }
  final String category; // 카테고리 (예: 'Jan', 'Feb' 등)
  final Map<String, double> values; // 각 스택 항목의 값 (key: 항목명, value: 사용량)
  final Map<String, Color> colors;
  final double? lastYearTotal; // 작년 동기 총 사용량 (비교용)
  final Map<String, double>? lastYearValues; // 작년 세부 데이터

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
    double? lastYearTotal,
    Map<String, double>? lastYearValues,
  }) {
    return StackedBarChartData(
      category: category ?? this.category,
      values: values ?? Map<String, double>.from(this.values),
      colors: colors ?? Map<String, Color>.from(this.colors),
      lastYearTotal: lastYearTotal ?? this.lastYearTotal,
      lastYearValues: lastYearValues ??
          (this.lastYearValues != null
              ? Map<String, double>.from(this.lastYearValues!)
              : null),
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

/// 온도 설정 곡선 포인트
class TemperatureCurvePoint {
  const TemperatureCurvePoint({
    required this.outdoorTemp,
    required this.targetTemp,
  });

  final double outdoorTemp; // 실외 온도 (°F)
  final double targetTemp; // 목표 온도 (°F)

  TemperatureCurvePoint copyWith({
    double? outdoorTemp,
    double? targetTemp,
  }) {
    return TemperatureCurvePoint(
      outdoorTemp: outdoorTemp ?? this.outdoorTemp,
      targetTemp: targetTemp ?? this.targetTemp,
    );
  }
}

/// 온도 설정 곡선 라인
class TemperatureCurveLine {
  const TemperatureCurveLine({
    required this.name,
    required this.points,
    required this.color,
    this.isHeating = true,
  });

  final String name; // 라인 이름 (예: Air, Water)
  final List<TemperatureCurvePoint> points; // 포인트 리스트
  final Color color; // 라인 색상
  final bool isHeating; // true: 난방, false: 냉방

  TemperatureCurveLine copyWith({
    String? name,
    List<TemperatureCurvePoint>? points,
    Color? color,
    bool? isHeating,
  }) {
    return TemperatureCurveLine(
      name: name ?? this.name,
      points: points ?? this.points,
      color: color ?? this.color,
      isHeating: isHeating ?? this.isHeating,
    );
  }
}

/// 온도 설정 곡선 차트 데이터
class TemperatureCurveData {
  const TemperatureCurveData({
    required this.lines,
    this.minOutdoorTemp = -20.0,
    this.maxOutdoorTemp = 50.0,
    this.minTargetTemp = 0.0,
    this.maxTargetTemp = 80.0,
    this.referenceTempLine,
  });

  factory TemperatureCurveData.sample() {
    return const TemperatureCurveData(
      lines: <TemperatureCurveLine>[
        // Air 구간 1: -30 ~ 5도
        TemperatureCurveLine(
          name: 'Air',
          points: <TemperatureCurvePoint>[
            TemperatureCurvePoint(outdoorTemp: -20, targetTemp: 68),
            TemperatureCurvePoint(outdoorTemp: 0, targetTemp: 65),
            TemperatureCurvePoint(outdoorTemp: 5, targetTemp: 60),
          ],
          color: Colors.red,
        ),
        // 5 ~ 20도 구간: 끊김
        // Air 구간 2: 20 ~ 50도
        TemperatureCurveLine(
          name: 'Air',
          points: <TemperatureCurvePoint>[
            TemperatureCurvePoint(outdoorTemp: 20, targetTemp: 40),
            TemperatureCurvePoint(outdoorTemp: 30, targetTemp: 30),
            TemperatureCurvePoint(outdoorTemp: 50, targetTemp: 24),
          ],
          color: Colors.red,
        ),
        // Water 구간 1: -30 ~ 5도
        TemperatureCurveLine(
          name: 'Water',
          points: <TemperatureCurvePoint>[
            TemperatureCurvePoint(outdoorTemp: -20, targetTemp: 50),
            TemperatureCurvePoint(outdoorTemp: 0, targetTemp: 35),
            TemperatureCurvePoint(outdoorTemp: 5, targetTemp: 32),
          ],
          color: Colors.blue,
        ),
        // 5 ~ 20도 구간: 끊김
        // Water 구간 2: 20 ~ 50도
        TemperatureCurveLine(
          name: 'Water',
          points: <TemperatureCurvePoint>[
            TemperatureCurvePoint(outdoorTemp: 20, targetTemp: 30),
            TemperatureCurvePoint(outdoorTemp: 30, targetTemp: 17),
            TemperatureCurvePoint(outdoorTemp: 50, targetTemp: 12),
          ],
          color: Colors.blue,
        ),
      ],
    );
  }

  final List<TemperatureCurveLine> lines; // 설정 곡선들
  final double minOutdoorTemp; // 최소 실외 온도
  final double maxOutdoorTemp; // 최대 실외 온도
  final double minTargetTemp; // 최소 목표 온도
  final double maxTargetTemp; // 최대 목표 온도
  final TemperatureCurveLine? referenceTempLine; // 기준 온도 라인

  TemperatureCurveData copyWith({
    List<TemperatureCurveLine>? lines,
    double? minOutdoorTemp,
    double? maxOutdoorTemp,
    double? minTargetTemp,
    double? maxTargetTemp,
    TemperatureCurveLine? referenceTempLine,
  }) {
    return TemperatureCurveData(
      lines: lines ?? this.lines,
      minOutdoorTemp: minOutdoorTemp ?? this.minOutdoorTemp,
      maxOutdoorTemp: maxOutdoorTemp ?? this.maxOutdoorTemp,
      minTargetTemp: minTargetTemp ?? this.minTargetTemp,
      maxTargetTemp: maxTargetTemp ?? this.maxTargetTemp,
      referenceTempLine: referenceTempLine ?? this.referenceTempLine,
    );
  }
}
