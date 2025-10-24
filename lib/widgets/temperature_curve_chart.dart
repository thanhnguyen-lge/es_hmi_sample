import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chart_data_models.dart';
import '../providers/chart_provider.dart';

/// 온도 설정 곡선 차트 위젯
class TemperatureCurveChart extends StatefulWidget {
  const TemperatureCurveChart({
    super.key,
    required this.data,
    this.title = '온도 설정 곡선',
    this.showTitle = true,
    this.showLegend = true,
    this.enableInteraction = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.onPointTap,
  });

  final TemperatureCurveData data;
  final String title;
  final bool showTitle;
  final bool showLegend;
  final bool enableInteraction;
  final Duration animationDuration;
  final void Function(int lineIndex, int pointIndex)? onPointTap;

  @override
  State<TemperatureCurveChart> createState() => _TemperatureCurveChartState();
}

class _TemperatureCurveChartState extends State<TemperatureCurveChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedLineIndex;
  int? _touchedPointIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.showTitle) ...<Widget>[
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              return LineChart(
                _buildLineChartData(),
                duration: const Duration(milliseconds: 300),
              );
            },
          ),
        ),
        if (widget.showLegend) ...<Widget>[
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ],
    );
  }

  LineChartData _buildLineChartData() {
    return LineChartData(
      minX: widget.data.minOutdoorTemp,
      maxX: widget.data.maxOutdoorTemp,
      minY: widget.data.minTargetTemp,
      maxY: widget.data.maxTargetTemp,
      lineBarsData: _buildLines(),
      titlesData: _buildTitles(),
      gridData: _buildGrid(),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      lineTouchData: widget.enableInteraction
          ? LineTouchData(
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.lineBarSpots == null) {
                  setState(() {
                    _touchedLineIndex = null;
                    _touchedPointIndex = null;
                  });
                  return;
                }

                final int lineIndex = response.lineBarSpots!.first.barIndex;
                final int pointIndex = response.lineBarSpots!.first.spotIndex;

                setState(() {
                  _touchedLineIndex = lineIndex;
                  _touchedPointIndex = pointIndex;
                });

                // 탭 이벤트 시 편집 다이얼로그 표시
                if (event is FlTapUpEvent) {
                  _showEditDialog(lineIndex, pointIndex);
                }
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (LineBarSpot spot) =>
                    Colors.black.withValues(alpha: 0.8),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((LineBarSpot spot) {
                    return LineTooltipItem(
                      '실외: ${spot.x.toStringAsFixed(0)}°F\n'
                      '목표: ${spot.y.toStringAsFixed(0)}°F',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            )
          : const LineTouchData(enabled: false),
    );
  }

  List<LineChartBarData> _buildLines() {
    final List<LineChartBarData> lines = <LineChartBarData>[];

    // Reference line first (뒤에 그려지도록)
    if (widget.data.referenceTempLine != null) {
      lines.add(_createLineData(
        widget.data.referenceTempLine!,
        isReference: true,
      ));
    }

    // 일반 라인들
    for (int i = 0; i < widget.data.lines.length; i++) {
      final TemperatureCurveLine line = widget.data.lines[i];
      lines.add(_createLineData(line, lineIndex: i));
    }

    return lines;
  }

  LineChartBarData _createLineData(
    TemperatureCurveLine line, {
    int? lineIndex,
    bool isReference = false,
  }) {
    final List<FlSpot> spots = line.points
        .map((TemperatureCurvePoint p) =>
            FlSpot(p.outdoorTemp * _animation.value, p.targetTemp))
        .toList();

    // 냉방 라인은 점선으로 표시
    final bool isDashed = !line.isHeating;

    return LineChartBarData(
      spots: spots,
      color: line.color.withValues(alpha: isReference ? 0.5 : 1.0),
      barWidth: isReference ? 2 : 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: !isReference,
        getDotPainter:
            (FlSpot spot, double percent, LineChartBarData barData, int index) {
          final bool isTouched = lineIndex != null &&
              _touchedLineIndex == lineIndex &&
              _touchedPointIndex == index;
          return FlDotCirclePainter(
            radius: isTouched ? 6 : 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: line.color,
          );
        },
      ),
      belowBarData: BarAreaData(),
      dashArray: isDashed ? <int>[8, 4] : null,
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: const Text(
          'Target Temperature',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 10,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (value == meta.min || value == meta.max) {
              return const SizedBox.shrink();
            }
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        axisNameWidget: const Text(
          'Outdoor Temperature',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 10,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (value == meta.min || value == meta.max) {
              return const SizedBox.shrink();
            }
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  FlGridData _buildGrid() {
    return FlGridData(
      horizontalInterval: 10,
      verticalInterval: 10,
      getDrawingHorizontalLine: (double value) {
        return FlLine(
          color: Colors.grey.withValues(alpha: 0.2),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (double value) {
        return FlLine(
          color: Colors.grey.withValues(alpha: 0.2),
          strokeWidth: 1,
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    // 고유한 라인 이름들을 가져옵니다
    final Map<String, Color> uniqueLines = <String, Color>{};
    for (final TemperatureCurveLine line in widget.data.lines) {
      if (!uniqueLines.containsKey(line.name)) {
        uniqueLines[line.name] = line.color;
      }
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: <Widget>[
        ...uniqueLines.entries.map((MapEntry<String, Color> entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                entry.key == 'Air'
                    ? Icons.air
                    : entry.key == 'Water'
                        ? Icons.water_drop
                        : Icons.thermostat,
                size: 16,
                color: entry.value,
              ),
              const SizedBox(width: 4),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: entry.value,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
        if (widget.data.referenceTempLine != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.horizontal_rule,
                size: 16,
                color: widget.data.referenceTempLine!.color,
              ),
              const SizedBox(width: 4),
              Text(
                'Reference Temp.',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.data.referenceTempLine!.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        // 온도 단위 표시
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Unit: °F',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 온도 편집 다이얼로그 표시
  void _showEditDialog(int lineIndex, int pointIndex) {
    // Reference line은 편집 불가
    if (widget.data.referenceTempLine != null && lineIndex == 0) {
      return;
    }

    // Reference line이 있으면 인덱스 조정
    final int actualLineIndex =
        widget.data.referenceTempLine != null ? lineIndex - 1 : lineIndex;

    if (actualLineIndex < 0 || actualLineIndex >= widget.data.lines.length) {
      return;
    }

    final TemperatureCurveLine line = widget.data.lines[actualLineIndex];
    if (pointIndex < 0 || pointIndex >= line.points.length) {
      return;
    }

    final TemperatureCurvePoint point = line.points[pointIndex];
    final TextEditingController controller = TextEditingController(
      text: point.targetTemp.toStringAsFixed(0),
    );

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('온도 설정 변경'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${line.name} (실외 ${point.outdoorTemp.toStringAsFixed(0)}°F)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: line.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '목표 온도 (°F)',
                            border: OutlineInputBorder(),
                            suffixText: '°F',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // 증가 버튼
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_up),
                            onPressed: () {
                              final double? currentTemp =
                                  double.tryParse(controller.text);
                              if (currentTemp != null) {
                                setState(() {
                                  controller.text =
                                      (currentTemp + 1).toStringAsFixed(0);
                                });
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 32,
                          ),
                          // 감소 버튼
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () {
                              final double? currentTemp =
                                  double.tryParse(controller.text);
                              if (currentTemp != null) {
                                setState(() {
                                  controller.text =
                                      (currentTemp - 1).toStringAsFixed(0);
                                });
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    final double? newTemp = double.tryParse(controller.text);
                    if (newTemp != null) {
                      final ChartProvider provider =
                          Provider.of<ChartProvider>(context, listen: false);
                      provider.updateTemperatureCurvePoint(
                        actualLineIndex,
                        pointIndex,
                        newTemp,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
