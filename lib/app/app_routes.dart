import 'package:alertaescolar/models/alumno.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/views/admin/home/admin_dashboard_view.dart';
import 'package:alertaescolar/views/admin/profile/admin_profile_view.dart';
import 'package:alertaescolar/views/admin/qr_and_notifications/announcements_view.dart';
import 'package:alertaescolar/views/admin/qr_and_notifications/attendance_control_view.dart';
import 'package:alertaescolar/views/admin/schedule/schedule_management_view.dart';
import 'package:alertaescolar/views/admin/school/school_settings_view.dart';
import 'package:alertaescolar/views/admin/students/student_profile_admin_view.dart';
import 'package:alertaescolar/views/admin/students/students_directory_view.dart';
import 'package:alertaescolar/views/user/students/students_view_new.dart';
import 'package:alertaescolar/views/user/students/student_detail_view.dart';
import 'package:flutter/material.dart';
import '../views/user/home/home_view.dart';
import '../views/user/profile/profile_view.dart';
import '../views/user/profile/personal_data_navigation_view.dart';
import '../views/user/profile/personal_info/contact_information_view.dart';
import '../views/user/profile/personal_info/personal_information_view_new.dart'
    as personal_info;

import '../views/user/profile/notification_settings_view_new.dart'
    as notification_settings;
import '../views/user/profile/family_information_view.dart';
import '../views/user/notifications/notifications_view.dart';
import '../widgets/custom_snack_bar.dart';

// Auth view imports
import '../views/auth/intro_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';
import '../views/auth/verify_magic_link_view.dart';
import '../views/auth/finish_setting_up_view.dart';

class AppRoutes {
  // Auth routes
  static const String intro = '/intro';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyMagicLink = '/verify_magic_link';
  static const String finishSettingUp = '/finish_setting_up';

  static const String home = '/';
  static const String profile = '/profile';
  static const String students = '/students';
  static const String studentDetail = '/student-detail';
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

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    debugPrint(
        "AppRoutes: onGenerateRoute called with route: ${settings.name}");

    // Add extra debugging for admin routes
    if (settings.name == adminDashboard) {
      debugPrint(
          "AppRoutes: Admin dashboard route requested - this should be the final destination");
    }

    switch (settings.name) {
      // Auth routes
      case intro:
        debugPrint("AppRoutes: Building IntroView");
        return MaterialPageRoute(
          builder: (context) => const IntroView(),
          settings: RouteSettings(name: intro),
        );
      case login:
        debugPrint("AppRoutes: Building LoginView");
        return MaterialPageRoute(
          builder: (context) => const LoginView(),
          settings: RouteSettings(name: login),
        );
      case signup:
        debugPrint("AppRoutes: Building SignUpView");
        return MaterialPageRoute(
          builder: (context) => const SignUpView(),
          settings: RouteSettings(name: signup),
        );
      case verifyMagicLink:
        final email = settings.arguments as String?;
        if (email == null) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error: Email required for verification'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        CustomSnackBar.show(
                          context: context,
                          message: 'Please provide email for verification',
                          isError: true,
                        );
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                      child: const Text('Return to Login'),
                    ),
                  ],
                ),
              ),
            ),
            settings: RouteSettings(name: verifyMagicLink),
          );
        }
        return MaterialPageRoute(
          builder: (context) => VerifyMagicLinkView(email: email),
          settings: RouteSettings(name: verifyMagicLink),
        );

      case finishSettingUp:
        debugPrint("AppRoutes: Building FinishSettingUpView");
        return MaterialPageRoute(
          builder: (context) => const FinishSettingUpView(),
          settings: RouteSettings(name: finishSettingUp),
        );

      case home:
        debugPrint("AppRoutes: Building HomeView");
        return MaterialPageRoute(
          builder: (context) => const HomeView(),
          settings: RouteSettings(name: home),
        );
      case profile:
        debugPrint("AppRoutes: Building ProfileView");
        return MaterialPageRoute(
          builder: (context) => const ProfileView(),
          settings: RouteSettings(name: profile),
        );
      case students:
        debugPrint("AppRoutes: Building StudentsView");
        return MaterialPageRoute(
          builder: (context) => const StudentsView(),
          settings: RouteSettings(name: students),
        );
      case notifications:
        debugPrint("AppRoutes: Building NotificationsView");
        return MaterialPageRoute(
          builder: (context) => const NotificationsView(),
          settings: RouteSettings(name: notifications),
        );
      case personalDataNavigation:
        return MaterialPageRoute(
          builder: (context) => const PersonalDataNavigationView(),
          settings: RouteSettings(name: personalDataNavigation),
        );
      case contactInformation:
        return MaterialPageRoute(
          builder: (context) => const ContactInformationView(),
          settings: RouteSettings(name: contactInformation),
        );
      case personalInformation:
        return MaterialPageRoute(
          builder: (context) => const personal_info.PersonalInformationView(),
          settings: RouteSettings(name: personalInformation),
        );

      case notificationSettings:
        return MaterialPageRoute(
          builder: (context) =>
              const notification_settings.NotificationSettingsView(),
          settings: RouteSettings(name: notificationSettings),
        );
      case familyInformation:
        return MaterialPageRoute(
          builder: (context) => const FamilyInformationView(),
          settings: RouteSettings(name: familyInformation),
        );

      // Admin routes
      case adminDashboard:
        debugPrint(
            "AppRoutes: Building AdminDashboardView - FINAL ADMIN DESTINATION");
        return MaterialPageRoute(
          builder: (context) => const AdminDashboardView(),
          settings: RouteSettings(name: adminDashboard),
        );
      case adminProfile:
        debugPrint("AppRoutes: Building AdminProfileView");
        return MaterialPageRoute(
          builder: (context) => const AdminProfileView(),
          settings: RouteSettings(name: adminProfile),
        );
      case adminAttendanceControl:
        debugPrint("AppRoutes: Building AttendanceControlView");
        return MaterialPageRoute(
          builder: (context) => const AttendanceControlView(),
          settings: RouteSettings(name: adminAttendanceControl),
        );
      case adminAnnouncements:
        debugPrint("AppRoutes: Building AnnouncementsView");
        return MaterialPageRoute(
          builder: (context) => const AnnouncementsView(),
          settings: RouteSettings(name: adminAnnouncements),
        );
      case adminStudentsDirectory:
        debugPrint("AppRoutes: Building StudentsDirectoryView");
        return MaterialPageRoute(
          builder: (context) => const StudentsDirectoryView(),
          settings: RouteSettings(name: adminStudentsDirectory),
        );
      case adminStudentProfile:
        final student = settings.arguments as Alumno?;
        if (student == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text('Error: Student data required'),
              ),
            ),
            settings: RouteSettings(name: adminStudentProfile),
          );
        }
        final studentDetails = _convertAlumnoToStudentDetails(student);
        debugPrint("AppRoutes: Building StudentProfileAdminView");
        return MaterialPageRoute(
          builder: (context) =>
              StudentProfileAdminView(student: studentDetails),
          settings: RouteSettings(name: adminStudentProfile),
        );
      case adminScheduleManagement:
        debugPrint("AppRoutes: Building ScheduleManagementView");
        return MaterialPageRoute(
          builder: (context) => const ScheduleManagementView(),
          settings: RouteSettings(name: adminScheduleManagement),
        );
      case adminSchoolSettings:
        debugPrint("AppRoutes: Building SchoolSettingsView");
        return MaterialPageRoute(
          builder: (context) => const SchoolSettingsView(),
          settings: RouteSettings(name: adminSchoolSettings),
        );
      case studentDetail:
        final student = settings.arguments as Alumno?;
        if (student == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text('Error: Student data required'),
              ),
            ),
            settings: RouteSettings(name: studentDetail),
          );
        }
        debugPrint("AppRoutes: Building StudentDetailView");
        return MaterialPageRoute(
          builder: (context) => StudentDetailView(student: student),
          settings: RouteSettings(name: studentDetail),
        );

      default:
        debugPrint("AppRoutes: Route not found: ${settings.name}");
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Página no encontrada'),
            ),
          ),
          settings: RouteSettings(name: 'not_found'),
        );
    }
  }

  // Helper method to convert Alumno to StudentDetails
  static StudentDetails _convertAlumnoToStudentDetails(Alumno alumno) {
    return StudentDetails(
      id: alumno.id,
      nombre: alumno.nombre,
      matricula: alumno.matricula,
      escuelaId: alumno.id_escuela,
      grupoId: alumno.id_grupo,
      grupo: alumno.grupo,
      nivelEducativo: '', // Will be populated from database joins
      turnoId: null,
      turno: alumno.turno.toString().split('.').last,
      llaveId: alumno.id_llave,
      llaveCodigo: null,
      llaveActiva: alumno.vinculado,
      fechaRegistro: alumno.fecha_registro,
      fechaRegistroLlave: null,
      limiteVinculacion: null,
      tutores: [],
      familyContacts: [], // Add this field
    );
  }
}
