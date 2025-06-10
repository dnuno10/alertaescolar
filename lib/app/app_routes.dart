import 'package:alertaescolar/views/students/students_view_new.dart';
import 'package:flutter/material.dart';
import '../views/home/home_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/personal_data_navigation_view.dart';
import '../views/profile/personal_info/contact_information_view.dart';
import '../views/profile/personal_info/personal_information_view_new.dart'
    as personal_info;
import '../views/profile/password_security_view_new.dart' as password_security;
import '../views/profile/notification_settings_view_new.dart'
    as notification_settings;
import '../views/profile/family_information_view.dart';

import '../views/notifications/notifications_view.dart';

class AppRoutes {
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

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeView(),
        profile: (context) => const ProfileView(),
        students: (context) => const StudentsView(),
        notifications: (context) => const NotificationsView(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
