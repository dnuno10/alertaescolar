import 'package:alertaescolar/components/headers/home_header.dart';
import 'package:alertaescolar/components/navigation/custom_bottom_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:alertaescolar/components/notifications/notification_detail_modal.dart';
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
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              HomeHeader(screenSize: screenSize),
              SliverToBoxAdapter(child: _buildMainContent(context, screenSize)),
            ],
          ),
          const StudentsView(),
          const NotificationsView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          HapticFeedback.mediumImpact();
          setState(() => _selectedIndex = index);
        },
        screenSize: screenSize,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return RecentNotificationsSection(
                screenSize: screenSize,
                onTapSeeAll: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _selectedIndex = 2);
                },
                notifications: provider.notifications,
                onNotificationTap: (String notificationId) {
                  // First mark all notifications as read and navigate to notifications view
                  if (provider.unreadCount > 0) {
                    provider.markAllAsRead();
                  }
                  setState(() => _selectedIndex = 2);

                  // After navigation, show the notification detail modal
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final notification =
                        provider.getNotificationById(notificationId);
                    if (notification != null) {
                      // Show detail modal
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: FractionallySizedBox(
                            heightFactor: 0.85,
                            child: NotificationDetailModal(
                              notification: notification,
                              screenSize: screenSize,
                            ),
                          ),
                        ),
                      );
                    }
                  });
                },
              );
            },
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
          StudentsOverviewSection(
            screenSize: screenSize,
            onTapViewAll: () {
              HapticFeedback.mediumImpact();
              setState(() => _selectedIndex = 1);
            },
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
          TodayScheduleSection(
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
          QuickActionsSection(
            screenSize: screenSize,
            onActionSelected: (index) {
              HapticFeedback.mediumImpact();
              setState(() => _selectedIndex = index);
            },
          ),
          SizedBox(
              height:
                  screenSize.height * 0.12), // Bottom padding for navigation
        ],
      ),
    );
  }
}
