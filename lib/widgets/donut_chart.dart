import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/chart_data_models.dart';

/// Donut Chart Widget using PieChart with center space
///
/// fl_chart 라이브러리의 PieChart를 확장하여 중앙에 공간이 있는 도넛 형태의 차트를 생성합니다.
/// 중앙에 퍼센티지와 현재/총계 값을 표시할 수 있습니다.
class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    required this.data,
    this.title = '',
    this.centerText = '',
    this.centerSpaceRadius = 60.0,
    this.showPercentage = true,
    this.showValues = true,
    this.enableInteraction = true,
    this.margin,
    this.animationDuration = const Duration(milliseconds: 800),
  });
  final PieChartDataModel data;
  final String title;
  final String centerText;
  final double centerSpaceRadius;
  final bool showPercentage;
  final bool showValues;
  final bool enableInteraction;
  final EdgeInsets? margin;
  final Duration animationDuration;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedSectionIndex;

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
        children: <Widget>[
          // 제목
          if (widget.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

          // 차트 영역
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // 반응형 centerSpaceRadius 계산
                final double responsiveCenterRadius = constraints.maxWidth < 400
                    ? widget.centerSpaceRadius * 0.7
                    : widget.centerSpaceRadius;

                return AnimatedBuilder(
                  animation: _animation,
                  builder: (BuildContext context, Widget? child) {
                    return AspectRatio(
                      aspectRatio: 1.0,
                      child: Stack(
                        children: <Widget>[
                          // PieChart
                          PieChart(
                            PieChartData(
                              centerSpaceRadius: responsiveCenterRadius,
                              sections: _createSections(),
                              sectionsSpace: 2,
                              centerSpaceColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              startDegreeOffset: 180,
                              borderData: FlBorderData(show: false),
                              pieTouchData: widget.enableInteraction
                                  ? _buildPieTouchData()
                                  : PieTouchData(enabled: false),
                            ),
                          ),

                          // 중앙 텍스트
                          if (widget.showPercentage || widget.showValues)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (widget.showPercentage)
                                    Text(
                                      '${_getDisplayedPercentage().toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _getDisplayedColor(),
                                          ),
                                    ),
                                  if (widget.showValues)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        '${_getDisplayedValue().toStringAsFixed(0)} / ${widget.data.totalCapacity.toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                      ),
                                    ),
                                  if (widget.centerText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        widget.centerText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey.shade500,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// PieChart 섹션 생성
  List<PieChartSectionData> _createSections() {
    final List<PieChartSectionData> sections = <PieChartSectionData>[];

    // 사용량 섹션 (현재 사용량)
    if (widget.data.currentUsage > 0) {
      final bool isTouched = _touchedSectionIndex == 0;
      sections.add(
        PieChartSectionData(
          color: widget.data.primaryColor,
          value: widget.data.currentUsage * _animation.value,
          title: '',
          radius: isTouched ? 65 : 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // 사용 가능량 섹션 (남은 용량)
    final double remainingCapacity =
        widget.data.totalCapacity - widget.data.currentUsage;
    if (remainingCapacity > 0) {
      final bool isTouched = _touchedSectionIndex == 1;
      sections.add(
        PieChartSectionData(
          color: widget.data.backgroundColor,
          value: remainingCapacity * _animation.value,
          title: '',
          radius: isTouched ? 65 : 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  /// PieChart 터치 데이터 구성
  PieTouchData _buildPieTouchData() {
    return PieTouchData(
      enabled: widget.enableInteraction,
      touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              pieTouchResponse == null ||
              pieTouchResponse.touchedSection == null) {
            _touchedSectionIndex = null;
            return;
          }
          _touchedSectionIndex =
              pieTouchResponse.touchedSection!.touchedSectionIndex;
        });
      },
    );
  }

  /// 현재 표시할 퍼센티지 반환
  double _getDisplayedPercentage() {
    if (_touchedSectionIndex == 0) {
      // 사용량 섹션이 선택된 경우
      return widget.data.percentage;
    } else if (_touchedSectionIndex == 1) {
      // 사용 가능량 섹션이 선택된 경우
      return 100.0 - widget.data.percentage;
    } else {
      // 기본값: 사용량 퍼센티지
      return widget.data.percentage;
    }
  }

  /// 현재 표시할 값 반환
  double _getDisplayedValue() {
    if (_touchedSectionIndex == 0) {
      // 사용량 섹션이 선택된 경우
      return widget.data.currentUsage;
    } else if (_touchedSectionIndex == 1) {
      // 사용 가능량 섹션이 선택된 경우
      return widget.data.totalCapacity - widget.data.currentUsage;
    } else {
      // 기본값: 현재 사용량
      return widget.data.currentUsage;
    }
  }

  /// 현재 표시할 색상 반환
  Color _getDisplayedColor() {
    if (_touchedSectionIndex == 0) {
      // 사용량 섹션이 선택된 경우
      return widget.data.primaryColor;
    } else if (_touchedSectionIndex == 1) {
      // 사용 가능량 섹션이 선택된 경우
      return widget.data.backgroundColor;
    } else {
      // 기본값: 주요 색상
      return widget.data.primaryColor;
    }
  }
}
