import 'package:flutter/material.dart';
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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        HomeHeader(screenSize: screenSize),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Attendance
                RecentAttendanceCard(screenSize: screenSize),

                SizedBox(height: AppTheme.getLargePadding(screenSize)),
                // Main Actions
                AdminMainActions(screenSize: screenSize),

                SizedBox(height: AppTheme.getLargePadding(screenSize)),
                // Today's Statistics
                AdminStatsCard(screenSize: screenSize),

                SizedBox(height: AppTheme.getLargePadding(screenSize)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
