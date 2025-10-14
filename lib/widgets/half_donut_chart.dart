import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/chart_data_models.dart';

/// 반쪽 도넛 차트 위젯
///
/// fl_chart 라이브러리를 사용하여 반원형 도넛 차트를 표시합니다.
/// 게이지나 진행률 표시에 적합한 디자인입니다.
class HalfDonutChart extends StatefulWidget {
  const HalfDonutChart({
    super.key,
    required this.data,
    required this.title,
    this.centerText = '사용량',
    this.showPercentage = true,
    this.showValues = true,
    this.enableInteraction = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.margin,
  });
  final PieChartDataModel data;
  final String title;
  final String centerText;
  final bool showPercentage;
  final bool showValues;
  final bool enableInteraction;
  final Duration animationDuration;
  final EdgeInsets? margin;

  @override
  State<HalfDonutChart> createState() => _HalfDonutChartState();
}

class _HalfDonutChartState extends State<HalfDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedIndex;

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
          if (widget.title.isNotEmpty) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],

          // 차트 영역
          // Expanded(
          //   child: _buildChartArea(),
          // ),
          Container(
            alignment: Alignment.center,
            height: 300,
            child: _buildChartArea(),
          ),

          // 범례
          _buildLegend(),
        ],
      ),
    );
  }

  /// 차트 영역 빌드
  Widget _buildChartArea() {
    return Stack(
      children: <Widget>[
        // 반쪽 도넛 차트
        AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) {
            return PieChart(
              PieChartData(
                startDegreeOffset: 180,
                sectionsSpace: 0,
                centerSpaceRadius: 80,
                sections: _buildPieChartSections(),
                pieTouchData: widget.enableInteraction
                    ? _buildPieChartTouchData()
                    : PieTouchData(enabled: false),
              ),
            );
          },
        ),

        // 중앙 텍스트
        _buildCenterText(),
      ],
    );
  }

  /// 파이 차트 섹션 생성
  List<PieChartSectionData> _buildPieChartSections() {
    final double animatedPercentage = widget.data.percentage * _animation.value;

    // 사용자가 제공한 예제와 동일한 방식
    // 전체를 60으로 나누고, 30을 투명하게 하여 반원 효과
    final double usageRatio = animatedPercentage / 100.0;
    final double usageValue = usageRatio * 30; // 상단 반원의 사용량 부분
    final double remainingValue = (1.0 - usageRatio) * 30; // 상단 반원의 남은 부분

    return <PieChartSectionData>[
      // 사용량 섹션
      PieChartSectionData(
        color: widget.data.primaryColor,
        value: usageValue,
        title: widget.showPercentage
            ? '${animatedPercentage.toStringAsFixed(1)}%'
            : '',
        radius: _touchedIndex == 0 ? 65 : 60, // 터치했을 때만 확대
        showTitle: widget.showPercentage,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: <Shadow>[
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
      ),

      // 남은 용량 섹션
      PieChartSectionData(
        color: widget.data.backgroundColor,
        value: remainingValue,
        title: widget.showPercentage
            ? '${(100 - animatedPercentage).toStringAsFixed(1)}%'
            : '',
        radius: _touchedIndex == 1 ? 65 : 60, // 터치했을 때만 확대, 기본 크기는 동일하게
        showTitle: widget.showPercentage,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),

      // 투명한 섹션 (하단 반원을 숨김)
      PieChartSectionData(
        color: Colors.transparent,
        value: 30, // 하단 반원 전체를 투명하게
        title: '',
        radius: 0,
        showTitle: false,
      ),
    ];
  }

  /// 파이 차트 터치 데이터 설정
  PieTouchData _buildPieChartTouchData() {
    return PieTouchData(
      enabled: widget.enableInteraction,
      touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              pieTouchResponse == null ||
              pieTouchResponse.touchedSection == null) {
            _touchedIndex = null;
            return;
          }
          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
        });
      },
    );
  }

  /// 중앙 텍스트 빌드
  Widget _buildCenterText() {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 60), // 반원이므로 텍스트를 더 아래로 이동
          Text(
            widget.centerText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              final double animatedCurrentUsage =
                  widget.data.currentUsage * _animation.value;
              return Text(
                animatedCurrentUsage.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.data.primaryColor,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              final double animatedTotalCapacity =
                  widget.data.totalCapacity * _animation.value;
              return Text(
                '/ ${animatedTotalCapacity.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade500,
                ),
              );
            },
          ),
          Text(
            'kWh',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 범례 빌드
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildLegendItem(
            label: '현재 사용량',
            color: widget.data.primaryColor,
            value: widget.showValues
                ? '${widget.data.currentUsage.toStringAsFixed(1)} kWh'
                : null,
          ),
          _buildLegendItem(
            label: '남은 용량',
            color: widget.data.backgroundColor,
            value: widget.showValues
                ? '${(widget.data.totalCapacity - widget.data.currentUsage).toStringAsFixed(1)} kWh'
                : null,
          ),
        ],
      ),
    );
  }

  /// 범례 아이템 생성
  Widget _buildLegendItem({
    required String label,
    required Color color,
    String? value,
  }) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (value != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
