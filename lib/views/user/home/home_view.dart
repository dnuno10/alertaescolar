import 'package:alertaescolar/components/attendance/attendance_statics_card.dart';
import 'package:alertaescolar/components/headers/home_header.dart';
import 'package:alertaescolar/components/navigation/custom_bottom_navigation_bar.dart';
import 'package:alertaescolar/components/notifications/recent_notifications_section.dart';
import 'package:alertaescolar/components/quick_actions_section.dart';
import 'package:alertaescolar/components/schedule/today_schedule_section.dart';
import 'package:alertaescolar/components/students/students_overview_section.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/views/user/students/students_view_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/notification_provider.dart';
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

    // Don't call loadCurrentUser here as it might trigger navigation
    // The user should already be loaded from main.dart initialization
    final currentUser = userProvider.currentUser;

    // Only proceed if we have a user and they're not an admin
    if (currentUser != null && currentUser.tipo != TipoUsuario.administrador) {
      await Future.wait([
        notificationProvider.loadNotifications(),
        studentProvider.loadStudentsForUser(userId: currentUser.id),
      ]);
    }
    // If user is admin or not loaded, don't load anything as they shouldn't be here
  }

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        screenSize: screenSize,
      ),
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
}
