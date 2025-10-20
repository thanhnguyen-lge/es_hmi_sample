import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/chart_data_models.dart';
import '../providers/chart_provider.dart';

/// Enum to identify which line is being dragged.
enum _ActiveLine { none, red, blue }

class LineSetTempChart extends StatefulWidget {
  final ChartProvider chartProvider;

  const LineSetTempChart({super.key, required this.chartProvider});

  @override
  State<StatefulWidget> createState() => _LineSetTempChartState();
}

class _LineSetTempChartState extends State<LineSetTempChart> {
  double lineRedValue = 10; // nét liền đỏ
  double lineBlueValue = 20; // nét liền xanh
  static const double minX = -30, maxX = 50;
  double redDotYValue = 0.93; // Y-value for the draggable red dot
  static const double minY = 0, maxY = 1;

  // Tracks which line is currently being dragged.
  _ActiveLine _activeLine = _ActiveLine.none;
  bool _isDraggingRedDot = false;

  // Helper to convert dy to Y-axis value
  double _dyToValue(double dy, double height) =>
      (height - dy) / height * (maxY - minY) + minY;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.3,
      child: LayoutBuilder(builder: (context, constraints) {
        return LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 10,
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey[400],
                strokeWidth: 1,
                dashArray: [6, 4],
              ),
              drawHorizontalLine: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: _buildLineChartTitles(),
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: false,
              touchSpotThreshold: 20.0,
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                if (event is FlPanStartEvent) {
                  if (response?.lineBarSpots?.isNotEmpty ?? false) {
                    final spot = response!.lineBarSpots!.first;
                    // Check if we are touching the draggable red dot.
                    // It's in the first bar (index 0) and is the first spot (spotIndex 0).
                    if (spot.barIndex == 0 && spot.spotIndex == 0) {
                      setState(() {
                        _isDraggingRedDot = true;
                      });
                    }
                  }
                } else if (event is FlPanUpdateEvent) {
                  if (_isDraggingRedDot) {
                    final chartHeight = constraints.maxHeight;
                    final newY =
                        _dyToValue(event.details.localPosition.dy, chartHeight);
                    setState(() {
                      // Clamp the value to be within the chart's Y range
                      redDotYValue = newY.clamp(minY, maxY);
                    });
                  }
                } else if (event is FlPanEndEvent || event is FlLongPressEnd) {
                  setState(() {
                    _isDraggingRedDot = false;
                  });
                }
              },
            ),
            lineBarsData: [
              // Top light red line (thicker, with white-filled circles at ends)
              LineChartBarData(
                spots: [
                  FlSpot(lineRedValue, redDotYValue),
                  FlSpot(lineRedValue - 30, 0.7),
                  FlSpot(-30, 0.7),
                ],
                isCurved: false,
                color: Colors.red[200],
                barWidth: 3.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, idx) {
                    // Draggable dot is the first one (index 0)
                    // if (idx == 0) {
                    return FlDotCirclePainter(
                      radius: _isDraggingRedDot ? 10 : 8,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: Colors.red[200]!,
                    );
                    // }
                    // return FlDotCirclePainter(
                    //     radius: 0, color: Colors.transparent);
                  },
                ),
              ),
              // Lower dark red line
              LineChartBarData(
                spots: [
                  FlSpot(-20, 0.6),
                  FlSpot(10, 0.5),
                ],
                isCurved: false,
                color: Colors.red,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, idx) {
                    if (spot.x == -30 || spot.x == 10) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: Colors.red,
                        strokeWidth: 0,
                        strokeColor: Colors.transparent,
                      );
                    }
                    return FlDotCirclePainter(
                        radius: 0, color: Colors.transparent);
                  },
                ),
              ),
              LineChartBarData(
                spots: [
                  FlSpot(-20, 0.6),
                  FlSpot(-30, 0.6),
                ],
                isCurved: false,
                color: Colors.red,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, idx) {
                    if (spot.x == -30 || spot.x == 10) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: Colors.red,
                        strokeWidth: 0,
                        strokeColor: Colors.transparent,
                      );
                    }
                    return FlDotCirclePainter(
                        radius: 0, color: Colors.transparent);
                  },
                ),
              ),
              // Top blue line
              LineChartBarData(
                spots: [
                  FlSpot(20, 0.74),
                  FlSpot(50, 0.74),
                ],
                isCurved: false,
                color: Colors.lightBlueAccent,
                barWidth: 3.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, idx) {
                    if (spot.x == 20 || spot.x == 50) {
                      return FlDotCirclePainter(
                        radius: 7,
                        color: Colors.lightBlueAccent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    }
                    return FlDotCirclePainter(
                        radius: 0, color: Colors.transparent);
                  },
                ),
              ),
              // Lower dark blue line
              LineChartBarData(
                spots: [
                  FlSpot(20, 0.63),
                  FlSpot(50, 0.44),
                ],
                isCurved: false,
                color: Colors.blue[800],
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, idx) {
                    if (spot.x == 20 || spot.x == 50) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: Colors.blue[800]!,
                        strokeWidth: 0,
                        strokeColor: Colors.transparent,
                      );
                    }
                    return FlDotCirclePainter(
                        radius: 0, color: Colors.transparent);
                  },
                ),
              ),
              // Add gray dots to axis intersections
              // Bottom horizontal gray line
              LineChartBarData(
                spots: [
                  FlSpot(-30, 0),
                  FlSpot(50, 0),
                ],
                isCurved: false,
                color: Colors.grey[500],
                barWidth: 2,
                dotData: FlDotData(show: true),
              ),

              LineChartBarData(
                spots: [
                  FlSpot(-30, 0),
                  FlSpot(-30, 1),
                ],
                isCurved: false,
                color: Colors.grey[500],
                barWidth: 2,
                dotData: FlDotData(show: true),
              ),
              // Axis dots
              LineChartBarData(
                spots: [
                  FlSpot(-30, 0),
                  FlSpot(-20, 0),
                  FlSpot(-10, 0),
                  FlSpot(0, 0),
                  FlSpot(10, 0),
                  FlSpot(20, 0),
                  FlSpot(30, 0),
                  FlSpot(40, 0),
                  FlSpot(50, 0),
                ],
                isCurved: false,
                color: Colors.transparent,
                barWidth: 0,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, idx) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.grey[600]!,
                      strokeWidth: 0,
                      strokeColor: Colors.transparent,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _bottomTitleText(int value) => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          value.toString(), // update text as needed
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );

  FlTitlesData _buildLineChartTitles() {
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      // ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            // Show bottom titles only on the four main marker positions
            final int intValue = value.toInt();
            // Show bottom titles for values from -30 to 50 at intervals of 10.
            if (intValue >= -30 && intValue <= 50 && intValue % 10 == 0) {
              return _bottomTitleText(intValue);
            }
            return const SizedBox.shrink();
          },
          reservedSize: 30,
        ),
      ),
      leftTitles: const AxisTitles(),
    );
  }
}
