import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_data_models.dart';

/// 스택형 막대 차트 위젯
///
/// fl_chart 라이브러리를 사용하여 4개 카테고리(Base, AC, Heating, Other)의
/// 에너지 사용량을 스택형 막대 차트로 표시합니다.
class StackedBarChart extends StatefulWidget {
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

  @override
  State<StackedBarChart> createState() => _StackedBarChartState();
}

class _StackedBarChartState extends State<StackedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedGroupIndex;

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
        children: [
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
              builder: (context, child) {
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
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (widget.maxY ?? _calculateMaxY()) / 5,
                      getDrawingHorizontalLine: (value) {
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
          if (widget.showLegend) ...[
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
              getTooltipColor: (touchedSpot) => Colors.blueGrey.shade700,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return _buildTooltipItem(group, groupIndex, rod, rodIndex);
              },
            )
          : null,
      touchCallback: (FlTouchEvent event, barTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              barTouchResponse == null ||
              barTouchResponse.spot == null) {
            _touchedGroupIndex = null;
            return;
          }
          _touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;
        });
      },
    );
  }

  /// 툴팁 아이템 생성
  BarTooltipItem? _buildTooltipItem(BarChartGroupData group, int groupIndex,
      BarChartRodData rod, int rodIndex) {
    if (groupIndex >= widget.data.length) return null;

    final data = widget.data[groupIndex];
    final StringBuffer tooltip = StringBuffer();

    tooltip.writeln(data.category);
    tooltip.writeln('총 사용량: ${data.totalUsage.toStringAsFixed(1)}kWh');
    tooltip.writeln('');

    // 각 스택 아이템 정보 추가
    data.values.forEach((key, value) {
      final percentage = data.getPercentage(key);
      tooltip.writeln(
          '$key: ${value.toStringAsFixed(1)}kWh (${percentage.toStringAsFixed(1)}%)');
    });

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
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
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
          getTitlesWidget: (value, meta) {
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
    return widget.data.asMap().entries.map((entry) {
      final int index = entry.key;
      final StackedBarChartData item = entry.value;
      final bool isTouched = index == _touchedGroupIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalUsage * _animation.value,
            rodStackItems: _createStackItems(item),
            width: isTouched ? 35 : 30,
            borderRadius: BorderRadius.circular(2),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: widget.maxY ?? _calculateMaxY(),
              color: Colors.grey.shade100,
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  /// 스택 아이템 생성
  List<BarChartRodStackItem> _createStackItems(StackedBarChartData item) {
    final List<BarChartRodStackItem> stackItems = [];
    double cumulativeSum = 0;

    // 스택 순서 정의 (아래에서 위로)
    final List<String> stackOrder = ['Base', 'AC', 'Heating', 'Other'];

    for (String key in stackOrder) {
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

  /// 최대 Y값 계산
  double _calculateMaxY() {
    if (widget.data.isEmpty) return 100;

    final maxUsage = widget.data
        .map((item) => item.totalUsage)
        .reduce((max, current) => current > max ? current : max);

    // 여유를 두기 위해 10% 추가
    return (maxUsage * 1.1).ceilToDouble();
  }

  /// 범례 생성
  Widget _buildLegend() {
    // 모든 데이터에서 고유한 카테고리 추출
    final Set<String> categories = {};
    final Map<String, Color> categoryColors = {};

    for (var item in widget.data) {
      categories.addAll(item.values.keys);
      categoryColors.addAll(item.colors);
    }

    // 정해진 순서로 정렬
    final List<String> orderedCategories = ['Base', 'AC', 'Heating', 'Other'];
    final List<String> displayCategories = orderedCategories
        .where((category) => categories.contains(category))
        .toList();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: displayCategories.map((category) {
        final color = categoryColors[category] ?? Colors.grey;
        return _buildLegendItem(category, color);
      }).toList(),
    );
  }

  /// 범례 아이템 생성
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
