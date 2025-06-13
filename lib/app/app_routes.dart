import 'package:alertaescolar/models/alumno.dart';
import 'package:alertaescolar/views/admin/home/admin_dashboard_view.dart';
import 'package:alertaescolar/views/admin/profile/admin_profile_view.dart';
import 'package:alertaescolar/views/admin/qr_and_notifications/announcements_view.dart';
import 'package:alertaescolar/views/admin/qr_and_notifications/attendance_control_view.dart';
import 'package:alertaescolar/views/admin/schedule/schedule_management_view.dart';
import 'package:alertaescolar/views/admin/school/school_settings_view.dart';
import 'package:alertaescolar/views/admin/students/student_profile_admin_view.dart';
import 'package:alertaescolar/views/admin/students/students_directory_view.dart';
import 'package:alertaescolar/views/user/students/students_view_new.dart';
import 'package:alertaescolar/views/auth/intro_view.dart';
import 'package:alertaescolar/views/auth/login_view.dart';
import 'package:alertaescolar/views/auth/signup_view.dart';
import 'package:alertaescolar/views/auth/finish_setting_up_view.dart';
import 'package:alertaescolar/views/auth/verify_magic_link_view.dart';
import 'package:flutter/material.dart';
import '../views/user/home/home_view.dart';
import '../views/user/profile/profile_view.dart';
import '../views/user/profile/personal_data_navigation_view.dart';
import '../views/user/profile/personal_info/contact_information_view.dart';
import '../views/user/profile/personal_info/personal_information_view_new.dart'
    as personal_info;
import '../views/user/profile/password_security_view_new.dart'
    as password_security;
import '../views/user/profile/notification_settings_view_new.dart'
    as notification_settings;
import '../views/user/profile/family_information_view.dart';

import '../views/user/notifications/notifications_view.dart';

class AppRoutes {
  // Auth routes
  static const String intro = '/intro';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String register = '/register'; // Add this line
  static const String finishSettingUp = '/finish_setting_up';
  static const String verifyMagicLink = '/verify_magic_link';

  // Main app routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String students = '/students';
  static const String notifications = '/notifications';
  static const String attendance = '/attendance';
  static const String reports = '/reports';
  static const String settings = '/settings';

  // Profile section routes
  static const String personalData = '/profile/personal-data';
  static const String personalDataNavigation =
      '/profile/personal-data-navigation';
  static const String contactInformation = '/profile/contact-information';
  static const String personalInformation = '/profile/personal-information';
  static const String usernameChange = '/profile/username-change';
  static const String passwordSecurity = '/profile/password-security';
  static const String notificationSettings = '/profile/notification-settings';
  static const String familyInformation = '/profile/family-information';
  static const String accountControl = '/profile/account-control';
  static const String appSettings = '/profile/app-settings';

  // Admin section routes
  static const String adminDashboard = '/admin';
  static const String adminAttendanceControl = '/admin/attendance-control';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminStudentsDirectory = '/admin/students-directory';
  static const String adminStudentProfile = '/admin/student-profile';
  static const String adminScheduleManagement = '/admin/schedule-management';
  static const String adminSchoolSettings = '/admin/school-settings';
  static const String adminReports = '/admin/reports';
  static const String adminProfile = '/admin/profile';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeView(),
        profile: (context) => const ProfileView(),
        students: (context) => const StudentsView(),
        notifications: (context) => const NotificationsView(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case intro:
        return MaterialPageRoute(builder: (context) => const IntroView());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginView());
      case signup:
        return MaterialPageRoute(builder: (context) => const SignUpView());
      case register:
        return MaterialPageRoute(
            builder: (context) => const SignUpView()); // Add this line
      case finishSettingUp:
        return MaterialPageRoute(
            builder: (context) => const FinishSettingUpView());
      case verifyMagicLink:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => VerifyMagicLinkView(email: email),
        );

      // Main app routes
      case home:
        return MaterialPageRoute(builder: (context) => const HomeView());
      case profile:
        return MaterialPageRoute(builder: (context) => const ProfileView());
      case students:
        return MaterialPageRoute(builder: (context) => const StudentsView());
      case notifications:
        return MaterialPageRoute(
            builder: (context) => const NotificationsView());
      case personalDataNavigation:
        return MaterialPageRoute(
            builder: (context) => const PersonalDataNavigationView());
      case contactInformation:
        return MaterialPageRoute(
            builder: (context) => const ContactInformationView());
      case personalInformation:
        return MaterialPageRoute(
            builder: (context) =>
                const personal_info.PersonalInformationView());

      case passwordSecurity:
        return MaterialPageRoute(
            builder: (context) =>
                const password_security.PasswordSecurityView());
      case notificationSettings:
        return MaterialPageRoute(
            builder: (context) =>
                const notification_settings.NotificationSettingsView());
      case familyInformation:
        return MaterialPageRoute(
            builder: (context) => const FamilyInformationView());

      // Admin routes
      case adminDashboard:
        return MaterialPageRoute(
            builder: (context) => const AdminDashboardView());
      case adminProfile:
        return MaterialPageRoute(
            builder: (context) => const AdminProfileView());
      case adminAttendanceControl:
        return MaterialPageRoute(
            builder: (context) => const AttendanceControlView());
      case adminAnnouncements:
        return MaterialPageRoute(
            builder: (context) => const AnnouncementsView());
      case adminStudentsDirectory:
        return MaterialPageRoute(
            builder: (context) => const StudentsDirectoryView());
      case adminStudentProfile:
        final student = settings.arguments as Alumno?;
        if (student == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text('Error: Student data required'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
            builder: (context) => StudentProfileAdminView(student: student));
      case adminScheduleManagement:
        return MaterialPageRoute(
            builder: (context) => const ScheduleManagementView());
      case adminSchoolSettings:
        return MaterialPageRoute(
            builder: (context) => const SchoolSettingsView());

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Página no encontrada'),
            ),
          ),
        );
    }
  }
}
