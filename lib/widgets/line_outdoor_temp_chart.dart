import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/chart_data_models.dart';
import '../providers/chart_provider.dart';

/// Enum to identify which line is being dragged.
enum _ActiveLine { none, red, blue }

class LineOutdoorTempChart extends StatefulWidget {
  final ChartProvider chartProvider;

  const LineOutdoorTempChart({super.key, required this.chartProvider});

  @override
  State<StatefulWidget> createState() => _LineOutdoorTempChartState();
}

class _LineOutdoorTempChartState extends State<LineOutdoorTempChart> {
  double lineRedValue = 10; // nét liền đỏ
  double lineBlueValue = 20; // nét liền xanh
  static const double minX = -30, maxX = 50;

  // Tracks which line is currently being dragged.
  _ActiveLine _activeLine = _ActiveLine.none;

  // Helper: Chuyển đổi vị trí chạm sang giá trị trục X
  double _dxToTemp(double dx, double width) =>
      (dx / width) * (maxX - minX) + minX;

  @override
  Widget build(BuildContext context) {
    final List<BarChartDataModel> data = widget.chartProvider.barChartData;
    return AspectRatio(
      aspectRatio: 2.3,
      child: LayoutBuilder(builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        return LineChart(LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: 1,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: true),
          titlesData: _buildLineChartTitles(data),
          lineBarsData: [
            // Đường nét liền đỏ có thể kéo
            LineChartBarData(
              spots: [
                FlSpot(lineRedValue, 0),
                FlSpot(lineRedValue, 1),
              ],
              isCurved: false,
              color: Colors.red,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.y == 0,
                getDotPainter: (spot, percent, barData, index) {
                  final isTouched = _activeLine == _ActiveLine.red;
                  return FlDotCirclePainter(
                    radius: isTouched ? 5 : 2.5,
                    color: isTouched ? Colors.white : Colors.red,
                    strokeWidth: 2.5,
                    strokeColor: Colors.red,
                  );
                },
              ),
            ),
            // Đường nét đứt đỏ trái
            LineChartBarData(
              spots: [
                FlSpot(-10, 0),
                FlSpot(-10, 1),
              ],
              isCurved: false,
              color: Colors.red.withOpacity(0.6),
              barWidth: 2,
              dashArray: [7, 7],
              dotData: FlDotData(show: true),
            ),
            // Đường nét liền xanh có thể kéo
            LineChartBarData(
              spots: [
                FlSpot(lineBlueValue, 0),
                FlSpot(lineBlueValue, 1),
              ],
              isCurved: false,
              color: Colors.blue,
              barWidth: 2.5,
              dotData: FlDotData(show: true),
            ),
            // Đường nét đứt xanh phải
            LineChartBarData(
              spots: [
                FlSpot(30, 0),
                FlSpot(30, 1),
              ],
              isCurved: false,
              color: Colors.blue.withOpacity(0.6),
              barWidth: 2,
              dashArray: [7, 7],
              dotData: FlDotData(show: true),
            ),
          ],
          // Tô màu vùng trái (đỏ) và vùng phải (xanh)
          betweenBarsData: [
            BetweenBarsData(
              fromIndex: 0,
              toIndex: 1,
              color: Colors.red.withOpacity(0.2),
            ),
            BetweenBarsData(
              fromIndex: 2,
              toIndex: 3,
              color: Colors.blue.withOpacity(0.15),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchSpotThreshold: 30.0,
            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
              if (event is FlPanStartEvent) {
                if (response?.lineBarSpots?.isNotEmpty ?? false) {
                  final barIndex = response!.lineBarSpots!.first.barIndex;
                  // barIndex 0 is the red line, 2 is the blue line
                  if (barIndex == 0) {
                    setState(() => _activeLine = _ActiveLine.red);
                  } else if (barIndex == 2) {
                    setState(() => _activeLine = _ActiveLine.blue);
                  }
                }
              } else if (event is FlPanUpdateEvent) {
                if (_activeLine == _ActiveLine.none) return;
                final newTemp =
                    _dxToTemp(event.details.localPosition.dx, chartWidth);
                setState(() {
                  if (_activeLine == _ActiveLine.red) {
                    lineRedValue = newTemp.clamp(minX, lineBlueValue);
                  } else if (_activeLine == _ActiveLine.blue) {
                    lineBlueValue = newTemp.clamp(lineRedValue, maxX);
                  }
                });
              } else if (event is FlPanEndEvent || event is FlLongPressEnd) {
                setState(() => _activeLine = _ActiveLine.none);
              }
            },
          ),
          rangeAnnotations: RangeAnnotations(
            verticalRangeAnnotations: [
              VerticalRangeAnnotation(
                x1: -30,
                x2: lineRedValue,
                color: Colors.red.withOpacity(0.18),
              ),
              VerticalRangeAnnotation(
                x1: lineBlueValue,
                x2: 50,
                color: Colors.blue.withOpacity(0.18),
              ),
            ],
          ),
        ));
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

  FlTitlesData _buildLineChartTitles(List<BarChartDataModel> data) {
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
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
