import 'package:alertaescolar/components/admin/dashboard/admin_dashboard_content.dart';
import 'package:alertaescolar/components/admin/navigation/admin_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../providers/theme_provider.dart';

import '../qr_and_notifications/attendance_control_view.dart';
import '../students/students_directory_view.dart';
import '../profile/admin_profile_view.dart';
import '../school/school_settings_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              AdminDashboardContent(screenSize: screenSize),
              const AttendanceControlView(),
              const StudentsDirectoryView(),
              const SchoolSettingsView(),
              const AdminProfileView(),
            ],
          ),
          bottomNavigationBar: AdminBottomNavigation(
            selectedIndex: _selectedIndex,
            onIndexChanged: (index) => setState(() => _selectedIndex = index),
            screenSize: screenSize,
          ),
        );
      },
    );
  }
}
