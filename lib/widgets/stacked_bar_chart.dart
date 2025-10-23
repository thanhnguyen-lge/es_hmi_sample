import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/chart_data_models.dart';

/// 스택형 막대 차트 위젯
///
/// fl_chart 라이브러리를 사용하여 4개 카테고리(Base, AC, Heating, Other)의
/// 에너지 사용량을 스택형 막대 차트로 표시합니다.
class StackedBarChart extends StatefulWidget {
  const StackedBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.xAxisTitle,
    required this.yAxisTitle,
    this.maxY,
    this.showLegend = true,
    this.showTooltip = true,
    this.enableInteraction = true,
    this.margin,
    this.animationDuration = const Duration(milliseconds: 800),
  });
  final List<StackedBarChartData> data;
  final String title;
  final String xAxisTitle;
  final String yAxisTitle;
  final double? maxY;
  final bool showLegend;
  final bool showTooltip;
  final bool enableInteraction;
  final EdgeInsets? margin;
  final Duration animationDuration;

  @override
  State<StackedBarChart> createState() => _StackedBarChartState();
}

class _StackedBarChartState extends State<StackedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedGroupIndex;
  int? _touchedBarIndex; // 0: 올해, 1: 작년

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 제목
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // 차트 영역
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: widget.maxY ?? _calculateMaxY(),
                    barTouchData: widget.enableInteraction
                        ? _buildBarTouchData()
                        : BarTouchData(enabled: false),
                    titlesData: _buildTitlesData(),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: (widget.maxY ?? _calculateMaxY()) / 5,
                      getDrawingHorizontalLine: (double value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    barGroups: _createBarGroups(),
                  ),
                );
              },
            ),
          ),

          // 범례
          if (widget.showLegend) ...<Widget>[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  /// 막대 터치 데이터 설정
  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: widget.enableInteraction,
      touchTooltipData: widget.showTooltip
          ? BarTouchTooltipData(
              getTooltipColor: (BarChartGroupData touchedSpot) =>
                  Colors.blueGrey.shade700,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (BarChartGroupData group, int groupIndex,
                  BarChartRodData rod, int rodIndex) {
                return _buildTooltipItem(group, groupIndex, rod, rodIndex);
              },
            )
          : null,
      touchCallback: (FlTouchEvent event, BarTouchResponse? barTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              barTouchResponse == null ||
              barTouchResponse.spot == null) {
            _touchedGroupIndex = null;
            _touchedBarIndex = null;
            return;
          }
          _touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          _touchedBarIndex = barTouchResponse.spot!.touchedRodDataIndex;
        });
      },
    );
  }

  /// 툴팁 아이템 생성
  BarTooltipItem? _buildTooltipItem(BarChartGroupData group, int groupIndex,
      BarChartRodData rod, int rodIndex) {
    if (groupIndex >= widget.data.length) {
      return null;
    }

    final StackedBarChartData data = widget.data[groupIndex];
    final StringBuffer tooltip = StringBuffer();

    tooltip.writeln(data.category);

    // rodIndex 0: 올해 데이터 (스택형), rodIndex 1: 작년 데이터 (회색)
    if (rodIndex == 0) {
      // 올해 데이터
      tooltip.writeln('올해 총 사용량: ${data.totalUsage.toStringAsFixed(1)}kWh');
      tooltip.writeln();

      // 각 스택 아이템 정보 추가
      data.values.forEach((String key, double value) {
        final double percentage = data.getPercentage(key);
        tooltip.writeln(
            '$key: ${value.toStringAsFixed(1)}kWh (${percentage.toStringAsFixed(1)}%)');
      });
    } else if (rodIndex == 1 && data.lastYearTotal != null) {
      // 작년 데이터
      tooltip.writeln('작년 총 사용량: ${data.lastYearTotal!.toStringAsFixed(1)}kWh');
      tooltip.writeln();

      // 작년 세부 데이터가 있으면 표시
      if (data.lastYearValues != null && data.lastYearValues!.isNotEmpty) {
        final double lastYearSum = data.lastYearValues!.values
            .fold(0.0, (double sum, double value) => sum + value);

        data.lastYearValues!.forEach((String key, double value) {
          final double percentage =
              lastYearSum > 0 ? (value / lastYearSum) * 100 : 0.0;
          tooltip.writeln(
              '$key: ${value.toStringAsFixed(1)}kWh (${percentage.toStringAsFixed(1)}%)');
        });
        tooltip.writeln();
      }

      // 증감율 계산
      final double diff = data.totalUsage - data.lastYearTotal!;
      final double changePercent = (diff / data.lastYearTotal!) * 100;
      if (diff > 0) {
        tooltip.write('전년 대비 ↑${changePercent.toStringAsFixed(1)}% 증가');
      } else if (diff < 0) {
        tooltip.write('전년 대비 ↓${changePercent.abs().toStringAsFixed(1)}% 감소');
      } else {
        tooltip.write('전년 대비 동일');
      }
    }

    return BarTooltipItem(
      tooltip.toString().trim(),
      const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  /// 축 제목 및 라벨 설정
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        axisNameWidget: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            widget.xAxisTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            final int index = value.toInt();
            if (index >= 0 && index < widget.data.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  widget.data[index].category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return const Text('');
          },
          reservedSize: 40,
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: RotatedBox(
          quarterTurns: 1,
          child: Text(
            widget.yAxisTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          interval: (widget.maxY ?? _calculateMaxY()) / 5,
          getTitlesWidget: (double value, TitleMeta meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            );
          },
          reservedSize: 50,
        ),
      ),
    );
  }

  /// 막대 그룹 생성
  List<BarChartGroupData> _createBarGroups() {
    return widget.data
        .asMap()
        .entries
        .map((MapEntry<int, StackedBarChartData> entry) {
      final int index = entry.key;
      final StackedBarChartData item = entry.value;
      final bool isTouched = index == _touchedGroupIndex;

      // 올해 데이터 막대 (스택형)
      final List<BarChartRodData> barRods = <BarChartRodData>[
        BarChartRodData(
          toY: item.totalUsage * _animation.value,
          rodStackItems: _createStackItems(item),
          width: isTouched ? 28 : 24,
          borderRadius: BorderRadius.circular(2),
        ),
      ];

      // 작년 데이터 막대 - 있는 경우에만 추가
      if (item.lastYearTotal != null && item.lastYearTotal! > 0) {
        final bool isLastYearTouched = isTouched && _touchedBarIndex == 1;

        // 작년 막대가 터치되었고 세부 데이터가 있으면 스택형으로, 아니면 회색 단색으로
        if (isLastYearTouched && item.lastYearValues != null) {
          barRods.add(
            BarChartRodData(
              toY: item.lastYearTotal! * _animation.value,
              rodStackItems: _createLastYearStackItems(item),
              width: 28,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        } else {
          barRods.add(
            BarChartRodData(
              toY: item.lastYearTotal! * _animation.value,
              color: Colors.grey.shade400,
              width: isTouched && _touchedBarIndex == 1 ? 28 : 24,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }
      }

      return BarChartGroupData(
        x: index,
        barsSpace: 0, // 막대 사이 간격 없음
        barRods: barRods,
        showingTooltipIndicators: isTouched ? <int>[0] : <int>[],
      );
    }).toList();
  }

  /// 스택 아이템 생성 (올해 데이터)
  List<BarChartRodStackItem> _createStackItems(StackedBarChartData item) {
    final List<BarChartRodStackItem> stackItems = <BarChartRodStackItem>[];
    double cumulativeSum = 0;

    // 스택 순서 정의 (아래에서 위로)
    final List<String> stackOrder = <String>['DHW only', 'Cool', 'Heat'];

    for (final String key in stackOrder) {
      if (item.values.containsKey(key)) {
        final double value = item.getValue(key);
        final Color color = item.getColor(key);

        stackItems.add(
          BarChartRodStackItem(
            cumulativeSum,
            cumulativeSum + value,
            color,
          ),
        );
        cumulativeSum += value;
      }
    }

    return stackItems;
  }

  /// 작년 데이터 스택 아이템 생성
  List<BarChartRodStackItem> _createLastYearStackItems(
      StackedBarChartData item) {
    final List<BarChartRodStackItem> stackItems = <BarChartRodStackItem>[];

    if (item.lastYearValues == null) {
      return stackItems;
    }

    double cumulativeSum = 0;

    // 스택 순서 정의 (아래에서 위로)
    final List<String> stackOrder = <String>['DHW only', 'Cool', 'Heat'];

    for (final String key in stackOrder) {
      if (item.lastYearValues!.containsKey(key)) {
        final double value = item.lastYearValues![key] ?? 0.0;
        final Color color = item.getColor(key);

        stackItems.add(
          BarChartRodStackItem(
            cumulativeSum,
            cumulativeSum + value,
            color,
          ),
        );
        cumulativeSum += value;
      }
    }

    return stackItems;
  }

  /// 최대 Y값 계산
  double _calculateMaxY() {
    if (widget.data.isEmpty) {
      return 100;
    }

    // 올해 데이터의 최대값
    final double maxUsage = widget.data
        .map((StackedBarChartData item) => item.totalUsage)
        .reduce((double max, double current) => current > max ? current : max);

    // 작년 데이터의 최대값 (있는 경우)
    final double maxLastYear = widget.data
        .where((StackedBarChartData item) => item.lastYearTotal != null)
        .map((StackedBarChartData item) => item.lastYearTotal!)
        .fold(
            0.0, (double max, double current) => current > max ? current : max);

    // 두 값 중 더 큰 값 사용
    final double maxValue = maxUsage > maxLastYear ? maxUsage : maxLastYear;

    // 여유를 두기 위해 10% 추가
    return (maxValue * 1.1).ceilToDouble();
  }

  /// 범례 생성
  Widget _buildLegend() {
    // 모든 데이터에서 고유한 카테고리 추출
    final Set<String> categories = <String>{};
    final Map<String, Color> categoryColors = <String, Color>{};

    for (final StackedBarChartData item in widget.data) {
      categories.addAll(item.values.keys);
      categoryColors.addAll(item.colors);
    }

    // 정해진 순서로 정렬
    final List<String> orderedCategories = <String>[
      'DHW only',
      'Cool',
      'Heat',
    ];
    final List<String> displayCategories = orderedCategories
        .where((String category) => categories.contains(category))
        .toList();

    // Last Year 범례 추가 (작년 데이터가 있는 경우)
    final bool hasLastYearData = widget.data.any((StackedBarChartData item) =>
        item.lastYearTotal != null && item.lastYearTotal! > 0);
    if (hasLastYearData) {
      displayCategories.add('Last Year');
      categoryColors['Last Year'] = Colors.grey.shade400;
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: displayCategories.map((String category) {
        final Color color = categoryColors[category] ?? Colors.grey;
        return _buildLegendItem(category, color);
      }).toList(),
    );
  }

  /// 범례 아이템 생성
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
