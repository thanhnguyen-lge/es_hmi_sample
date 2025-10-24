import 'package:flutter/material.dart';

import '../models/chart_data_helper.dart';
import '../models/chart_data_models.dart';

/// 차트 데이터와 UI 상태를 관리하는 Provider 클래스
class ChartProvider extends ChangeNotifier {
  // Private fields
  List<BarChartDataModel> _barChartData = <BarChartDataModel>[];
  PieChartDataModel _pieChartData = ChartDataHelper.getEmptyPieChartData();
  List<LineChartDataModel> _lineChartData = <LineChartDataModel>[];
  List<StackedBarChartData> _stackedBarChartData = <StackedBarChartData>[];
  TemperatureCurveData _temperatureCurveData = TemperatureCurveData.sample();
  ChartType _currentChartType = ChartType.bar;
  ChartColorScheme _colorScheme = ChartColorScheme.defaultScheme;
  bool _isLoading = false;

  // Cached values for performance optimization
  double? _cachedMaxBarChartValue;
  List<LegendItem>? _cachedLegends;

  // Getters
  List<BarChartDataModel> get barChartData =>
      List<BarChartDataModel>.unmodifiable(_barChartData);
  PieChartDataModel get pieChartData => _pieChartData;
  List<LineChartDataModel> get lineChartData =>
      List<LineChartDataModel>.unmodifiable(_lineChartData);
  List<StackedBarChartData> get stackedBarChartData =>
      List<StackedBarChartData>.unmodifiable(_stackedBarChartData);
  TemperatureCurveData get temperatureCurveData => _temperatureCurveData;
  ChartType get currentChartType => _currentChartType;
  bool get isBarChart => _currentChartType == ChartType.bar;
  bool get isPieChart => _currentChartType == ChartType.pie;
  bool get isLineChart => _currentChartType == ChartType.line;
  bool get isStackedBarChart => _currentChartType == ChartType.stackedBar;
  bool get isDonutChart => _currentChartType == ChartType.donut;
  bool get isSetTempChart => _currentChartType == ChartType.setTemp;
  ChartColorScheme get colorScheme => _colorScheme;
  bool get isLoading => _isLoading;

  /// 차트 데이터 총 개수
  int get barChartDataCount => _barChartData.length;

  /// 막대 그래프 최대값 계산 (캐시 적용)
  double get maxBarChartValue {
    _cachedMaxBarChartValue ??=
        ChartDataHelper.getMaxValueFromBarData(_barChartData);
    return _cachedMaxBarChartValue!;
  }

  /// 범례 데이터 (캐시 적용)
  List<LegendItem> get legends {
    _cachedLegends ??= ChartDataHelper.getBarChartLegends();
    return _cachedLegends!;
  }

  /// 초기 데이터 로드
  void initializeData() {
    _setLoading(true);

    try {
      _barChartData = ChartDataHelper.getSampleBarChartData();
      _pieChartData = ChartDataHelper.getSamplePieChartData();
      _lineChartData = ChartDataHelper.getSampleLineChartData();
      _stackedBarChartData = _generateSampleStackedBarData();

      debugPrint(
          'ChartProvider: 데이터 초기화 완료 - Bar: ${_barChartData.length}개, Pie: ${_pieChartData.currentUsage}/${_pieChartData.totalCapacity}, Line: ${_lineChartData.length}개 시리즈, StackedBar: ${_stackedBarChartData.length}개');
    } catch (e) {
      debugPrint('ChartProvider: 데이터 초기화 오류 - $e');
      _barChartData = ChartDataHelper.getEmptyBarChartData(7);
      _pieChartData = ChartDataHelper.getEmptyPieChartData();
      _lineChartData = ChartDataHelper.getEmptyLineChartData();
      _stackedBarChartData = <StackedBarChartData>[];
    } finally {
      _setLoading(false);
    }
  }

  /// 막대 그래프 특정 인덱스의 특정 카테고리 데이터 업데이트
  void updateBarDataCategory(int index, String category, double value) {
    if (index < 0 || index >= _barChartData.length) {
      debugPrint('ChartProvider: 잘못된 인덱스 - $index');
      return;
    }

    if (value < 0) {
      debugPrint('ChartProvider: 음수 값은 허용되지 않음 - $value');
      return;
    }

    final BarChartDataModel currentData = _barChartData[index];
    BarChartDataModel updatedData;

    switch (category.toLowerCase()) {
      case 'base':
      case 'baseusage':
        updatedData = currentData.copyWith(baseUsage: value);
      case 'ac':
      case 'acusage':
        updatedData = currentData.copyWith(acUsage: value);
      case 'heating':
      case 'heatingusage':
        updatedData = currentData.copyWith(heatingUsage: value);
      case 'etc':
      case 'etcusage':
        updatedData = currentData.copyWith(etcUsage: value);
      default:
        debugPrint('ChartProvider: 알 수 없는 카테고리 - $category');
        return;
    }

    _barChartData[index] = updatedData;
    notifyListeners();

    debugPrint(
        'ChartProvider: 막대 그래프 데이터 업데이트 - 인덱스: $index, 카테고리: $category, 값: $value');
  }

  /// 막대 그래프 전체 데이터 업데이트
  void updateBarData(
    int index, {
    double? baseUsage,
    double? acUsage,
    double? heatingUsage,
    double? etcUsage,
  }) {
    if (index < 0 || index >= _barChartData.length) {
      debugPrint('ChartProvider: 잘못된 인덱스 - $index');
      return;
    }

    final BarChartDataModel currentData = _barChartData[index];
    final BarChartDataModel updatedData = currentData.copyWith(
      baseUsage: baseUsage,
      acUsage: acUsage,
      heatingUsage: heatingUsage,
      etcUsage: etcUsage,
    );

    _barChartData[index] = updatedData;
    notifyListeners();

    debugPrint('ChartProvider: 막대 그래프 전체 데이터 업데이트 - 인덱스: $index');
  }

  /// 원형 그래프 현재 사용량 업데이트
  void updatePieCurrentUsage(double currentUsage) {
    if (currentUsage < 0) {
      debugPrint('ChartProvider: 음수 사용량은 허용되지 않음 - $currentUsage');
      return;
    }

    if (currentUsage > _pieChartData.totalCapacity) {
      debugPrint(
          'ChartProvider: 사용량이 총 용량을 초과함 - $currentUsage > ${_pieChartData.totalCapacity}');
      return; // 업데이트를 거부
    }

    _pieChartData = _pieChartData.copyWith(currentUsage: currentUsage);
    notifyListeners();

    debugPrint('ChartProvider: 원형 그래프 현재 사용량 업데이트 - $currentUsage');
  }

  /// 원형 그래프 총 용량 업데이트
  void updatePieTotalCapacity(double totalCapacity) {
    if (totalCapacity <= 0) {
      debugPrint('ChartProvider: 총 용량은 0보다 커야 함 - $totalCapacity');
      return;
    }

    _pieChartData = _pieChartData.copyWith(totalCapacity: totalCapacity);
    notifyListeners();

    debugPrint('ChartProvider: 원형 그래프 총 용량 업데이트 - $totalCapacity');
  }

  /// 원형 그래프 데이터 전체 업데이트
  void updatePieData({
    double? currentUsage,
    double? totalCapacity,
    Color? primaryColor,
    Color? backgroundColor,
  }) {
    // 유효성 검사
    if (currentUsage != null && currentUsage < 0) {
      debugPrint('ChartProvider: 음수 사용량은 허용되지 않음 - $currentUsage');
      return;
    }

    if (totalCapacity != null && totalCapacity <= 0) {
      debugPrint('ChartProvider: 총 용량은 0보다 커야 함 - $totalCapacity');
      return;
    }

    _pieChartData = _pieChartData.copyWith(
      currentUsage: currentUsage,
      totalCapacity: totalCapacity,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
    );
    notifyListeners();

    debugPrint('ChartProvider: 원형 그래프 전체 데이터 업데이트');
  }

  /// 온도 곡선 데이터 업데이트
  void updateTemperatureCurveData(TemperatureCurveData newData) {
    _temperatureCurveData = newData;
    notifyListeners();
    debugPrint('ChartProvider: 온도 곡선 데이터 업데이트');
  }

  /// 온도 곡선 포인트 업데이트
  void updateTemperatureCurvePoint(
      int lineIndex, int pointIndex, double newTargetTemp) {
    if (lineIndex < 0 || lineIndex >= _temperatureCurveData.lines.length) {
      debugPrint('ChartProvider: 잘못된 라인 인덱스 - $lineIndex');
      return;
    }

    final TemperatureCurveLine line = _temperatureCurveData.lines[lineIndex];
    if (pointIndex < 0 || pointIndex >= line.points.length) {
      debugPrint('ChartProvider: 잘못된 포인트 인덱스 - $pointIndex');
      return;
    }

    final List<TemperatureCurvePoint> newPoints =
        List<TemperatureCurvePoint>.from(line.points);
    newPoints[pointIndex] = newPoints[pointIndex].copyWith(
      targetTemp: newTargetTemp,
    );

    final List<TemperatureCurveLine> newLines =
        List<TemperatureCurveLine>.from(_temperatureCurveData.lines);
    newLines[lineIndex] = line.copyWith(points: newPoints);

    _temperatureCurveData = _temperatureCurveData.copyWith(lines: newLines);
    notifyListeners();

    debugPrint(
        'ChartProvider: 온도 곡선 포인트 업데이트 - Line: $lineIndex, Point: $pointIndex, Temp: $newTargetTemp');
  }

  /// 차트 타입 전환 (막대 → 원형 → 라인 → 스택형 막대 → 도넛 → 반쪽 도넛 → 온도 설정 곡선)
  void toggleChartType() {
    switch (_currentChartType) {
      case ChartType.bar:
        _currentChartType = ChartType.pie;
      case ChartType.pie:
        _currentChartType = ChartType.line;
      case ChartType.line:
        _currentChartType = ChartType.stackedBar;
      case ChartType.stackedBar:
        _currentChartType = ChartType.donut;
      case ChartType.donut:
        _currentChartType = ChartType.halfDonut;
      case ChartType.halfDonut:
        _currentChartType = ChartType.setTemp;
      case ChartType.setTemp:
        _currentChartType = ChartType.bar;
    }
    notifyListeners();

    debugPrint('ChartProvider: 차트 타입 전환 - ${_currentChartType.displayName}');
  }

  /// 특정 차트 타입으로 설정
  void setChartType(ChartType chartType) {
    if (_currentChartType != chartType) {
      _currentChartType = chartType;
      notifyListeners();

      debugPrint('ChartProvider: 차트 타입 설정 - ${_currentChartType.displayName}');
    }
  }

  /// 색상 스키마 업데이트
  void updateColorScheme(ChartColorScheme newColorScheme) {
    _colorScheme = newColorScheme;
    notifyListeners();

    debugPrint('ChartProvider: 색상 스키마 업데이트');
  }

  /// 특정 색상 업데이트
  void updateColor(String colorType, Color color) {
    switch (colorType.toLowerCase()) {
      case 'base':
        _colorScheme = _colorScheme.copyWith(baseUsageColor: color);
      case 'ac':
        _colorScheme = _colorScheme.copyWith(acUsageColor: color);
      case 'heating':
        _colorScheme = _colorScheme.copyWith(heatingUsageColor: color);
      case 'etc':
        _colorScheme = _colorScheme.copyWith(etcUsageColor: color);
      default:
        debugPrint('ChartProvider: 알 수 없는 색상 타입 - $colorType');
        return;
    }

    notifyListeners();
    debugPrint('ChartProvider: $colorType 색상 업데이트');
  }

  /// 모든 데이터 초기화
  void resetData() {
    _setLoading(true);

    try {
      _barChartData = ChartDataHelper.getSampleBarChartData();
      _pieChartData = ChartDataHelper.getSamplePieChartData();
      _colorScheme = ChartColorScheme.defaultScheme;
      _currentChartType = ChartType.bar;

      debugPrint('ChartProvider: 모든 데이터 초기화 완료');
    } finally {
      _setLoading(false);
    }
  }

  /// 빈 데이터로 초기화
  void resetToEmpty() {
    _setLoading(true);

    try {
      _barChartData = ChartDataHelper.getEmptyBarChartData(7);
      _pieChartData = ChartDataHelper.getEmptyPieChartData();
      _colorScheme = ChartColorScheme.defaultScheme;
      _currentChartType = ChartType.bar;

      debugPrint('ChartProvider: 빈 데이터로 초기화 완료');
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정 (private)
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 막대 그래프에 새로운 날짜 데이터 추가
  void addBarChartData(String label) {
    final BarChartDataModel newData = BarChartDataModel(
      label: label,
      baseUsage: 0.0,
      acUsage: 0.0,
      heatingUsage: 0.0,
      etcUsage: 0.0,
    );

    _barChartData.add(newData);
    notifyListeners();

    debugPrint('ChartProvider: 새로운 막대 그래프 데이터 추가 - $label');
  }

  /// 샘플 데이터 추가
  void addSampleData() {
    final List<BarChartDataModel> sampleData =
        ChartDataHelper.getSampleBarChartData();
    if (sampleData.isNotEmpty) {
      final BarChartDataModel newData = sampleData.first.copyWith(
        label: '${DateTime.now().month}/${DateTime.now().day}',
      );
      _barChartData.add(newData);
      notifyListeners();
      debugPrint('ChartProvider: 샘플 데이터 추가 - ${newData.label}');
    }
  }

  /// 막대 그래프 데이터 제거
  void removeBarChartData(int index) {
    if (index >= 0 && index < _barChartData.length) {
      final String removedLabel = _barChartData[index].label;
      _barChartData.removeAt(index);
      notifyListeners();

      debugPrint('ChartProvider: 막대 그래프 데이터 제거 - $removedLabel');
    }
  }

  /// 디버그 정보 출력
  void debugPrintState() {
    debugPrint('=== ChartProvider 상태 ===');
    debugPrint('차트 타입: ${_currentChartType.displayName}');
    debugPrint('로딩 중: $_isLoading');
    debugPrint('막대 그래프 데이터 수: ${_barChartData.length}');
    debugPrint(
        '원형 그래프: ${_pieChartData.currentUsage}/${_pieChartData.totalCapacity} (${_pieChartData.percentage.toStringAsFixed(1)}%)');
    debugPrint('스택형 막대 그래프 데이터 수: ${_stackedBarChartData.length}');
    debugPrint('========================');
  }

  /// 스택형 막대 차트 샘플 데이터 생성
  List<StackedBarChartData> _generateSampleStackedBarData() {
    return <StackedBarChartData>[
      StackedBarChartData.fromUsageData(
        category: 'Jan',
        dhwUsage: 45.0,
        coolUsage: 15.0,
        heatUsage: 8.0,
        lastYearTotal: 95.0, // 작년 총 사용량
        lastYearDhw: 50.0,
        lastYearCool: 30.0,
        lastYearHeat: 15.0,
      ),
      StackedBarChartData.fromUsageData(
        category: 'Feb',
        dhwUsage: 42.0,
        coolUsage: 12.0,
        heatUsage: 18.0,
        lastYearTotal: 88.0,
        lastYearDhw: 48.0,
        lastYearCool: 20.0,
        lastYearHeat: 20.0,
      ),
      StackedBarChartData.fromUsageData(
        category: 'Mar',
        dhwUsage: 48.0,
        coolUsage: 20.0,
        heatUsage: 5.0,
        lastYearTotal: 80.0,
        lastYearDhw: 46.0,
        lastYearCool: 25.0,
        lastYearHeat: 9.0,
      ),
      StackedBarChartData.fromUsageData(
        category: 'Apr',
        dhwUsage: 50.0,
        coolUsage: 25.0,
        heatUsage: 2.0,
        lastYearTotal: 85.0,
        lastYearDhw: 49.0,
        lastYearCool: 30.0,
        lastYearHeat: 6.0,
      ),
      StackedBarChartData.fromUsageData(
        category: 'May',
        dhwUsage: 52.0,
        coolUsage: 35.0,
        heatUsage: 1.0,
        lastYearTotal: 98.0,
        lastYearDhw: 50.0,
        lastYearCool: 45.0,
        lastYearHeat: 3.0,
      ),
      StackedBarChartData.fromUsageData(
        category: 'Jun',
        dhwUsage: 55.0,
        coolUsage: 45.0,
        heatUsage: 0.0,
        lastYearTotal: 110.0,
        lastYearDhw: 52.0,
        lastYearCool: 55.0,
        lastYearHeat: 3.0,
      ),
    ];
  }

  /// 스택형 막대 차트 데이터 업데이트
  void updateStackedBarChartData(List<StackedBarChartData> newData) {
    _stackedBarChartData = List<StackedBarChartData>.from(newData);
    notifyListeners();

    debugPrint(
        'ChartProvider: 스택형 막대 차트 데이터 업데이트 - ${_stackedBarChartData.length}개');
  }

  /// 스택형 막대 차트 데이터 추가
  void addStackedBarChartData(StackedBarChartData newData) {
    _stackedBarChartData.add(newData);
    notifyListeners();

    debugPrint('ChartProvider: 스택형 막대 차트 데이터 추가 - ${newData.category}');
  }

  /// 스택형 막대 차트 데이터 제거
  void removeStackedBarChartData(int index) {
    if (index >= 0 && index < _stackedBarChartData.length) {
      final String removedCategory = _stackedBarChartData[index].category;
      _stackedBarChartData.removeAt(index);
      notifyListeners();

      debugPrint('ChartProvider: 스택형 막대 차트 데이터 제거 - $removedCategory');
    }
  }

  /// 스택형 막대 차트 최대값 계산
  double get maxStackedBarChartValue {
    if (_stackedBarChartData.isEmpty) {
      return 100.0;
    }

    return _stackedBarChartData
        .map((StackedBarChartData item) => item.totalUsage)
        .reduce((double max, double current) => current > max ? current : max);
  }

  /// 캐시 클리어 및 리스너 알림
  @override
  void notifyListeners() {
    // Clear all cached values when data changes
    _cachedMaxBarChartValue = null;
    _cachedLegends = null;
    super.notifyListeners();
  }
}
