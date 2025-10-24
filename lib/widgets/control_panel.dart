import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chart_data_models.dart';
import '../providers/chart_provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder:
          (BuildContext context, ChartProvider chartProvider, Widget? child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildPanelTitle(context),
                const SizedBox(height: 16),
                _buildChartTypeSection(context, chartProvider),
                const SizedBox(height: 16),
                _buildDataControlSection(context, chartProvider),
                const SizedBox(height: 16),
                _buildColorControlSection(context, chartProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 패널 타이틀
  Widget _buildPanelTitle(BuildContext context) {
    return Text(
      '컨트롤 패널',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  /// 차트 타입 선택 섹션
  Widget _buildChartTypeSection(
      BuildContext context, ChartProvider chartProvider) {
    return _buildSectionCard(
      context,
      title: '차트 타입',
      icon: Icons.swap_horiz,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _buildChartTypeButton(
                  context,
                  chartProvider,
                  chartType: ChartType.bar,
                  icon: ChartType.bar.icon,
                  label: ChartType.bar.displayName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChartTypeButton(
                  context,
                  chartProvider,
                  chartType: ChartType.pie,
                  icon: ChartType.pie.icon,
                  label: ChartType.pie.displayName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildChartTypeButton(
                  context,
                  chartProvider,
                  chartType: ChartType.line,
                  icon: ChartType.line.icon,
                  label: ChartType.line.displayName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChartTypeButton(
                  context,
                  chartProvider,
                  chartType: ChartType.stackedBar,
                  icon: ChartType.stackedBar.icon,
                  label: ChartType.stackedBar.displayName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildChartTypeButton(
                  context,
                  chartProvider,
                  chartType: ChartType.donut,
                  icon: ChartType.donut.icon,
                  label: ChartType.donut.displayName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChartTypeButton(
                  context,
                  chartProvider,
                  chartType: ChartType.halfDonut,
                  icon: ChartType.halfDonut.icon,
                  label: ChartType.halfDonut.displayName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildChartTypeButton(
                  context,
                  chartProvider,
                  chartType: ChartType.setTemp,
                  icon: ChartType.setTemp.icon,
                  label: ChartType.setTemp.displayName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 데이터 조작 섹션 (슬라이더 기반)
  Widget _buildDataControlSection(
      BuildContext context, ChartProvider chartProvider) {
    return _buildSectionCard(
      context,
      title: '데이터 조작',
      icon: Icons.tune,
      child: Column(
        children: <Widget>[
          // 차트 타입별 슬라이더 표시
          ..._buildSliderControls(context, chartProvider),
          const SizedBox(height: 16),
          // 리셋 버튼
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => chartProvider.initializeData(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('데이터 초기화'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.orange.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 차트 타입별 슬라이더 컨트롤 생성
  List<Widget> _buildSliderControls(
      BuildContext context, ChartProvider chartProvider) {
    switch (chartProvider.currentChartType) {
      case ChartType.bar:
        return _buildBarChartSliders(context, chartProvider);
      case ChartType.pie:
        return _buildPieChartSliders(context, chartProvider);
      case ChartType.line:
        return _buildLineChartSliders(context, chartProvider);
      case ChartType.stackedBar:
        return _buildStackedBarChartSliders(context, chartProvider);
      case ChartType.donut:
        return _buildDonutChartSliders(context, chartProvider);
      case ChartType.halfDonut:
        return _buildHalfDonutChartSliders(context, chartProvider);
      case ChartType.setTemp:
        return _buildSetTempChartSliders(context, chartProvider);
    }
  }

  /// Bar Chart용 슬라이더들
  List<Widget> _buildBarChartSliders(
      BuildContext context, ChartProvider chartProvider) {
    if (chartProvider.barChartData.isEmpty) {
      return <Widget>[];
    }

    final BarChartDataModel data = chartProvider.barChartData.first;
    final List<Widget> sliders = <Widget>[];

    // 각 사용량 카테고리별 슬라이더
    sliders.add(_buildSlider(
      context: context,
      label: '기본 사용량',
      value: data.baseUsage,
      min: 0,
      max: 100,
      onChanged: (double value) {
        chartProvider.updateBarDataCategory(0, 'base', value);
      },
    ));

    sliders.add(const SizedBox(height: 8));

    sliders.add(_buildSlider(
      context: context,
      label: '에어컨 사용량',
      value: data.acUsage,
      min: 0,
      max: 100,
      onChanged: (double value) {
        chartProvider.updateBarDataCategory(0, 'ac', value);
      },
    ));

    sliders.add(const SizedBox(height: 8));

    sliders.add(_buildSlider(
      context: context,
      label: '난방 사용량',
      value: data.heatingUsage,
      min: 0,
      max: 100,
      onChanged: (double value) {
        chartProvider.updateBarDataCategory(0, 'heating', value);
      },
    ));

    sliders.add(const SizedBox(height: 8));

    sliders.add(_buildSlider(
      context: context,
      label: '기타 사용량',
      value: data.etcUsage,
      min: 0,
      max: 100,
      onChanged: (double value) {
        chartProvider.updateBarDataCategory(0, 'etc', value);
      },
    ));

    return sliders;
  }

  /// Pie Chart용 슬라이더들
  List<Widget> _buildPieChartSliders(
      BuildContext context, ChartProvider chartProvider) {
    final PieChartDataModel data = chartProvider.pieChartData;
    final List<Widget> sliders = <Widget>[];

    // 안전한 최대값 계산 (현재 사용량과 총 용량 중 큰 값의 1.5배)
    final double safeMaxCapacity = (data.totalCapacity > data.currentUsage
            ? data.totalCapacity
            : data.currentUsage) *
        1.5;

    sliders.add(_buildSlider(
      context: context,
      label: '현재 사용량',
      value: data.currentUsage,
      min: 0,
      max: safeMaxCapacity,
      onChanged: (double value) {
        chartProvider.updatePieCurrentUsage(value);
      },
    ));

    sliders.add(const SizedBox(height: 8));

    sliders.add(_buildSlider(
      context: context,
      label: '총 용량',
      value: data.totalCapacity,
      min: 0,
      max: safeMaxCapacity,
      onChanged: (double value) {
        chartProvider.updatePieTotalCapacity(value);
      },
    ));

    return sliders;
  }

  /// Line Chart용 슬라이더들
  List<Widget> _buildLineChartSliders(
      BuildContext context, ChartProvider chartProvider) {
    if (chartProvider.lineChartData.isEmpty) {
      return <Widget>[];
    }

    final LineChartDataModel data = chartProvider.lineChartData.first;
    final List<Widget> sliders = <Widget>[];

    // 최신 몇 개의 데이터 포인트에 대한 슬라이더 제공
    final int pointsToShow =
        data.dataPoints.length > 3 ? 3 : data.dataPoints.length;
    final List<LineChartDataPoint> recentPoints =
        data.dataPoints.take(pointsToShow).toList();

    for (int i = 0; i < recentPoints.length; i++) {
      final LineChartDataPoint point = recentPoints[i];
      sliders.add(_buildSlider(
        context: context,
        label: point.label.isNotEmpty ? point.label : '포인트 ${i + 1}',
        value: point.value,
        min: 0,
        max: 100,
        onChanged: (double value) {
          // Line chart 데이터 업데이트를 위한 간단한 구현
          // 실제로는 ChartProvider에 적절한 메서드가 필요
          // 여기서는 시뮬레이션용으로 간단하게 구현
        },
      ));
      if (i < recentPoints.length - 1) {
        sliders.add(const SizedBox(height: 8));
      }
    }

    return sliders;
  }

  /// Stacked Bar Chart용 슬라이더들
  List<Widget> _buildStackedBarChartSliders(
      BuildContext context, ChartProvider chartProvider) {
    if (chartProvider.stackedBarChartData.isEmpty) {
      return <Widget>[];
    }

    // StackedBarChartData의 실제 구조를 확인하여 적절히 구현
    // 현재는 기본적인 구조만 제공
    final List<Widget> sliders = <Widget>[];
    sliders.add(
      Text(
        '스택 차트 데이터 조작',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );

    return sliders;
  }

  /// Donut Chart용 슬라이더들 (Pie Chart와 동일)
  List<Widget> _buildDonutChartSliders(
      BuildContext context, ChartProvider chartProvider) {
    return _buildPieChartSliders(context, chartProvider);
  }

  /// Half Donut Chart용 슬라이더들 (Pie Chart와 동일)
  List<Widget> _buildHalfDonutChartSliders(
      BuildContext context, ChartProvider chartProvider) {
    return _buildPieChartSliders(context, chartProvider);
  }

  /// 개별 슬라이더 위젯
  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).primaryColor.withAlpha(50),
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withAlpha(50),
          ),
          child: Semantics(
            label: '$label 조절, 현재 값: ${value.toStringAsFixed(1)}',
            value: value.toStringAsFixed(1),
            child: Slider(
              value: min <= max ? value.clamp(min, max) : min,
              min: min,
              max: min <= max ? max : min + 1, // min이 max보다 클 경우 안전한 값 설정
              divisions: min <= max ? (max - min).toInt().clamp(1, 100) : 1,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// 색상 설정 섹션
  Widget _buildColorControlSection(
      BuildContext context, ChartProvider chartProvider) {
    return _buildSectionCard(
      context,
      title: '색상 설정',
      icon: Icons.palette,
      child: Column(
        children: <Widget>[
          _buildColorPicker(
            context,
            '기본 색상',
            chartProvider.colorScheme.baseUsageColor,
            (Color color) => chartProvider.updateColor('base', color),
          ),
          const SizedBox(height: 8),
          _buildColorPicker(
            context,
            '에어컨 색상',
            chartProvider.colorScheme.acUsageColor,
            (Color color) => chartProvider.updateColor('ac', color),
          ),
          const SizedBox(height: 8),
          _buildColorPicker(
            context,
            '난방 색상',
            chartProvider.colorScheme.heatingUsageColor,
            (Color color) => chartProvider.updateColor('heating', color),
          ),
          const SizedBox(height: 8),
          _buildColorPicker(
            context,
            '기타 색상',
            chartProvider.colorScheme.etcUsageColor,
            (Color color) => chartProvider.updateColor('etc', color),
          ),
        ],
      ),
    );
  }

  /// 섹션 카드 빌더
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(
    BuildContext context,
    ChartProvider chartProvider, {
    required ChartType chartType,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = chartProvider.currentChartType == chartType;
    return Semantics(
      label: '$label로 차트 변경',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => chartProvider.setChartType(chartType),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    return Row(
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: currentColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.palette),
          onPressed: () =>
              _showColorPicker(context, currentColor, onColorChanged),
        ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// Set Temp Chart용 슬라이더들
  List<Widget> _buildSetTempChartSliders(
      BuildContext context, ChartProvider chartProvider) {
    return <Widget>[
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.deepOrange.shade600,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '온도 설정 곡선 차트는 샘플 데이터를 표시합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• 빨간색: Air (난방/냉방)\n'
              '• 파란색: Water (난방)\n'
              '• 회색: 기준 온도\n'
              '• Air와 Water는 같은 실외 온도에서\n'
              '  각각 다른 목표 온도 설정 가능',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class BlockPicker extends StatelessWidget {
  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final List<MaterialColor> colors = <MaterialColor>[
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return Wrap(
      children: colors.map((MaterialColor color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: pickerColor == color
                  ? Border.all(width: 3)
                  : Border.all(color: Colors.grey.shade300),
            ),
          ),
        );
      }).toList(),
    );
  }
}
