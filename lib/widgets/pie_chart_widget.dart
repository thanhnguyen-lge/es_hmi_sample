import 'package:chart_sample_app/models/chart_data_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 원형 차트 위젯 - 터치 상호작용 지원
class PieChartWidget extends StatefulWidget {
  final PieChartDataModel data;

  const PieChartWidget({super.key, required this.data});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 0,
            startDegreeOffset: -90,
            sections: _buildPieChartSections(),
            pieTouchData: PieTouchData(
              enabled: true,
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedIndex = null;
                    return;
                  }
                  _touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        ),
      ],
    );
  }

  /// 파이 차트 섹션 데이터 구성
  List<PieChartSectionData> _buildPieChartSections() {
    return [
      PieChartSectionData(
        color: Colors.blue.shade600,
        value: widget.data.currentUsage,
        title: '${widget.data.percentage.toStringAsFixed(1)}%',
        radius: _touchedIndex == 0 ? 130 : 120, // 터치했을 때 확대
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _buildPieChartBadge(
          icon: Icons.electrical_services,
          color: Colors.blue.shade800,
        ),
        badgePositionPercentageOffset: 1.3,
      ),
      PieChartSectionData(
        color: Colors.grey.shade300,
        value: widget.data.totalCapacity - widget.data.currentUsage,
        title: '${(100 - widget.data.percentage).toStringAsFixed(1)}%',
        radius: _touchedIndex == 1 ? 130 : 120, // 터치했을 때 확대
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
        badgeWidget: _buildPieChartBadge(
          icon: Icons.battery_charging_full,
          color: Colors.grey.shade500,
        ),
        badgePositionPercentageOffset: 1.3,
      ),
    ];
  }

  /// 파이 차트 배지 위젯
  Widget _buildPieChartBadge({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
