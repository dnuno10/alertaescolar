import 'package:alertaescolar/components/attendance/attendance_statics_card.dart';
import 'package:alertaescolar/components/headers/home_header.dart';
import 'package:alertaescolar/components/notifications/recent_notifications_section.dart';
import 'package:alertaescolar/components/quick_actions_section.dart';
import 'package:alertaescolar/components/schedule/today_schedule_section.dart';
import 'package:alertaescolar/components/students/students_overview_section.dart';
import 'package:alertaescolar/views/students/students_view_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../../managers/user_provider.dart';
import '../../managers/student_provider.dart';
import '../../managers/notification_provider.dart';
import '../../models/models.dart';
import '../notifications/notifications_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  int _selectedPeriod = 0; // 0: 7 días, 1: 1 mes
  String? _selectedStudentIdForStats; // For statistics
  String? _selectedStudentIdForSchedule; // For schedule

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    await Future.wait([
      userProvider.loadCurrentUser(),
      studentProvider.loadStudents(),
      notificationProvider.loadNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(context, screenSize),
          const StudentsView(),
          const NotificationsView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(l10n, screenSize),
    );
  }

  Widget _buildHomeContent(BuildContext context, Size screenSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= screenSize.width * 2.25;
        final isTablet = constraints.maxWidth >= screenSize.width * 1.5;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            HomeHeader(screenSize: screenSize),
            _buildMainContent(context, isWide, isTablet, screenSize),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(
      BuildContext context, bool isWide, bool isTablet, Size screenSize) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return RecentNotificationsSection(
                  screenSize: screenSize,
                  onTapSeeAll: () => setState(() => _selectedIndex = 2),
                  notifications: provider.notifications,
                );
              },
            ),
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            AttendanceStatisticsCard(
              screenSize: screenSize,
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (value) =>
                  setState(() => _selectedPeriod = value),
              selectedStudentId: _selectedStudentIdForStats,
              onStudentSelected: (id) =>
                  setState(() => _selectedStudentIdForStats = id),
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            StudentsOverviewSection(
              screenSize: screenSize,
              onTapViewAll: () => setState(() => _selectedIndex = 1),
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            TodayScheduleSection(
              screenSize: screenSize,
              selectedStudentId: _selectedStudentIdForSchedule,
              onStudentSelected: (id) =>
                  setState(() => _selectedStudentIdForSchedule = id),
            ),
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            QuickActionsSection(
              screenSize: screenSize,
              onActionSelected: (index) =>
                  setState(() => _selectedIndex = index),
            ),
            SizedBox(
                height:
                    screenSize.height * 0.12), // Bottom padding for navigation
          ],
        ),
      ),
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
                label: l10n.homeTitle,
                index: 0,
                isSelected: _selectedIndex == 0,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.people_rounded,
                label: l10n.students,
                index: 1,
                isSelected: _selectedIndex == 1,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItemWithBadge(
                icon: Icons.notifications_rounded,
                label: l10n.notifications,
                index: 2,
                isSelected: _selectedIndex == 2,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                index: 3,
                isSelected: _selectedIndex == 3,
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

  Widget _buildNavItemWithBadge({
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
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenSize.height * 0.006),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentPurple
                          : Colors.transparent,
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
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      final unreadCount = notificationProvider.unreadCount;
                      if (unreadCount > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(screenSize.height * 0.003),
                            decoration: const BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: screenSize.height * 0.018,
                              minHeight: screenSize.height * 0.018,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
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
