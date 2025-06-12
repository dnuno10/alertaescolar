import 'package:alertaescolar/components/headers/home_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../components/admin/admin_stats_card.dart';
import '../../components/admin/admin_quick_actions.dart';
import '../../components/admin/recent_attendance_card.dart';
import '../../components/admin/admin_main_actions.dart';
import '../../components/headers/admin_header.dart';
import 'attendance_control_view.dart';
import 'students_directory_view.dart';
import 'reports_view.dart';
import 'admin_profile_view.dart';
import 'school_settings_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardContent(context, screenSize),
              const AttendanceControlView(),
              const StudentsDirectoryView(),
              const SchoolSettingsView(),
              const AdminProfileView(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(l10n, screenSize),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, Size screenSize) {
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

  Widget _buildBottomNavigationBar(AppLocalizations l10n, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.getLargeRadius(screenSize))),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.06),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, -screenSize.height * 0.008),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: screenSize.width * 0.03,
            right: screenSize.width * 0.03,
            top: screenSize.height * 0.008,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: l10n.adminDashboard,
                index: 0,
                isSelected: _selectedIndex == 0,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.qr_code_scanner_rounded,
                label: l10n.attendanceControl,
                index: 1,
                isSelected: _selectedIndex == 1,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.group_rounded,
                label: l10n.studentsDirectory,
                index: 2,
                isSelected: _selectedIndex == 2,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.school_rounded,
                label: l10n.schoolSettings,
                index: 3,
                isSelected: _selectedIndex == 3,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                index: 4,
                isSelected: _selectedIndex == 4,
                context: context,
                screenSize: screenSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required BuildContext context,
    required Size screenSize,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.02,
              vertical: screenSize.height * 0.01),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentPurple.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenSize.height * 0.006),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.accentPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.8),
                ),
                child: Icon(
                  icon,
                  size: screenSize.height * 0.025,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.getTextSecondaryColor(context),
                ),
              ),
              SizedBox(height: screenSize.height * 0.003),
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: isSelected
                      ? AppTheme.accentPurple
                      : AppTheme.getTextSecondaryColor(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
