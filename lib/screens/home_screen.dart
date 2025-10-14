import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
import '../widgets/chart_area.dart';
import '../widgets/control_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Chart Sample',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: true,
      ),
      body: Consumer<ChartProvider>(
        builder:
            (BuildContext context, ChartProvider chartProvider, Widget? child) {
          if (chartProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // 반응형 브레이크포인트: 768px
              final bool isTabletOrDesktop = constraints.maxWidth >= 768;

              if (isTabletOrDesktop) {
                // 데스크톱/태블릿: 좌우 분할 레이아웃
                return _buildDesktopLayout(context, chartProvider);
              } else {
                // 모바일: 상하 분할 또는 탭 레이아웃
                return _buildMobileLayout(context, chartProvider);
              }
            },
          );
        },
      ),
    );
  }

  /// 데스크톱/태블릿용 좌우 분할 레이아웃
  Widget _buildDesktopLayout(
      BuildContext context, ChartProvider chartProvider) {
    return SafeArea(
      child: Row(
        children: <Widget>[
          // 차트 영역 (왼쪽, 70% 너비)
          const Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ChartArea(),
            ),
          ),

          // 구분선
          Container(
            width: 1,
            color: Theme.of(context).dividerColor,
          ),

          // 컨트롤 패널 (오른쪽, 30% 너비)
          const Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ControlPanel(),
            ),
          ),
        ],
      ),
    );
  }

  /// 모바일용 상하 분할 레이아웃
  Widget _buildMobileLayout(BuildContext context, ChartProvider chartProvider) {
    return Column(
      children: <Widget>[
        // 차트 영역 (상단, 60% 높이)
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: const ChartArea(),
          ),
        ),

        // 구분선
        Container(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),

        // 컨트롤 패널 (하단, 40% 높이)
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: const ControlPanel(),
          ),
        ),
      ],
    );
  }
}
