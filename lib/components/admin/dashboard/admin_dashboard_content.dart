import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../../app/app_theme.dart';
import '../../headers/home_header.dart';
import 'admin_main_actions.dart';
import 'admin_stats_card.dart';
import 'recent_attendance_card.dart';

class AdminDashboardContent extends StatelessWidget {
  final Size screenSize;

  const AdminDashboardContent({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.getMediumPadding(screenSize);
    final gap = AppTheme.getLargePadding(screenSize);

    Future<void> onRefresh() async {
      // Aquí pones tus recargas (stats, asistencia, etc.)
      await Future.delayed(const Duration(milliseconds: 800));
    }

    return LiquidPullToRefresh(
      onRefresh: onRefresh,
      color: AppTheme.accentPurple,
      backgroundColor: AppTheme.getBackgroundColor(context),
      height: 120,
      animSpeedFactor: 9.0,
      showChildOpacityTransition: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          HomeHeader(screenSize: screenSize),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecentAttendanceCard(screenSize: screenSize),
                  SizedBox(height: gap),
                  AdminMainActions(screenSize: screenSize),
                  SizedBox(height: gap),
                  AdminStatsCard(screenSize: screenSize),
                  SizedBox(height: gap * 0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
