import 'package:alertaescolar/views/user/profile/help/contact_support_view.dart';
import 'package:alertaescolar/views/user/profile/help/help_center.view.dart';
import 'package:alertaescolar/views/user/profile/help/legal_center_view.dart';
import 'package:flutter/material.dart';

import 'package:alertaescolar/models/alumno.dart';
import 'package:alertaescolar/managers/student_provider.dart';

// User
import 'package:alertaescolar/views/user/home/home_view.dart';
import 'package:alertaescolar/views/user/profile/profile_view.dart';
import 'package:alertaescolar/views/user/students/students_view.dart';
import 'package:alertaescolar/views/user/students/student_detail_view.dart';
import 'package:alertaescolar/views/user/notifications/notifications_view.dart';
import 'package:alertaescolar/views/user/students/student_confirmation_view.dart';

// Profile - subrutas
import 'package:alertaescolar/views/user/profile/personal_data_navigation_view.dart';
import 'package:alertaescolar/views/user/profile/personal_info/contact_information_view.dart';
import 'package:alertaescolar/views/user/profile/personal_info/personal_information_view_new.dart'
    as personal_info;

import 'package:alertaescolar/views/user/profile/family_information_view.dart';

// Admin
import 'package:alertaescolar/views/admin/home/admin_dashboard_view.dart';
import 'package:alertaescolar/views/admin/profile/admin_profile_view.dart';
import 'package:alertaescolar/views/admin/qr_and_notifications/attendance_control_view.dart';
import 'package:alertaescolar/views/admin/students/students_directory_view.dart';
import 'package:alertaescolar/views/admin/students/student_profile_admin_view.dart';
import 'package:alertaescolar/views/admin/schedule/schedule_management_view.dart';
import 'package:alertaescolar/views/admin/school/school_settings_view.dart';

// Legal
import 'package:alertaescolar/views/legal/privacy_view.dart';
import 'package:alertaescolar/views/legal/terms_view.dart';

// Auth
import 'package:alertaescolar/views/auth/intro_view.dart';
import 'package:alertaescolar/views/auth/login_view.dart';
import 'package:alertaescolar/views/auth/signup_view.dart';
import 'package:alertaescolar/views/auth/verify_magic_link_view.dart';
import 'package:alertaescolar/views/auth/finish_setting_up_view.dart';

// UI
import 'package:alertaescolar/widgets/custom_snack_bar.dart';

class AppRoutes {
  // Auth routes
  static const String intro = '/intro';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyMagicLink = '/verify_magic_link';
  static const String finishSettingUp = '/finish_setting_up';

  // Legal routes
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  // User routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String students = '/students';
  static const String studentDetail = '/student-detail';
  static const String notifications = '/notifications';
  static const String attendance = '/attendance';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String studentConfirmation = '/student-confirmation';

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
  static const String helpCenterNavigation = '/help-center';
  static const String contactSupport = '/help/contact-support';
  static const String legalCenter = '/legal-center';

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

    if (settings.name == adminDashboard) {
      debugPrint(
          "AppRoutes: Admin dashboard route requested - final admin destination");
    }

    switch (settings.name) {
      // Legal
      case terms:
        return MaterialPageRoute(
          builder: (context) => const TermsView(),
          settings: const RouteSettings(name: terms),
        );
      case privacy:
        return MaterialPageRoute(
          builder: (context) => const PrivacyView(),
          settings: const RouteSettings(name: privacy),
        );
      case helpCenterNavigation:
        return MaterialPageRoute(
          builder: (context) => const HelpCenterView(),
          settings: const RouteSettings(name: helpCenterNavigation),
        );
      case contactSupport:
        return MaterialPageRoute(
          builder: (context) => const ContactSupportView(),
          settings: const RouteSettings(name: contactSupport),
        );
      case legalCenter:
        return MaterialPageRoute(
          builder: (context) => const LegalCenterView(),
          settings: const RouteSettings(name: legalCenter),
        );

      // Auth
      case intro:
        return MaterialPageRoute(
          builder: (context) => const IntroView(),
          settings: const RouteSettings(name: intro),
        );
      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginView(),
          settings: const RouteSettings(name: login),
        );
      case signup:
        return MaterialPageRoute(
          builder: (context) => const SignUpView(),
          settings: const RouteSettings(name: signup),
        );
      case verifyMagicLink:
        final email = settings.arguments as String?;
        if (email == null) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: verifyMagicLink),
            builder: (context) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        "Se requiere un correo electrónico para verificar"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        CustomSnackBar.show(
                          context: context,
                          message:
                              'Por favor ingresa un correo electrónico para verificar',
                          isError: true,
                        );
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                      child: const Text("Volver al inicio de sesión"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => VerifyMagicLinkView(email: email),
          settings: const RouteSettings(name: verifyMagicLink),
        );
      case finishSettingUp:
        return MaterialPageRoute(
          builder: (context) => const FinishSettingUpView(),
          settings: const RouteSettings(name: finishSettingUp),
        );

      // User
      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeView(),
          settings: const RouteSettings(name: home),
        );
      case profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileView(),
          settings: const RouteSettings(name: profile),
        );
      case students:
        return MaterialPageRoute(
          builder: (context) => const StudentsView(),
          settings: const RouteSettings(name: students),
        );
      case notifications:
        return MaterialPageRoute(
          builder: (context) => const NotificationsView(),
          settings: const RouteSettings(name: notifications),
        );

      // Profile subroutes
      case personalDataNavigation:
        return MaterialPageRoute(
          builder: (context) => const PersonalDataNavigationView(),
          settings: const RouteSettings(name: personalDataNavigation),
        );
      case contactInformation:
        return MaterialPageRoute(
          builder: (context) => const ContactInformationView(),
          settings: const RouteSettings(name: contactInformation),
        );
      case personalInformation:
        return MaterialPageRoute(
          builder: (context) => const personal_info.PersonalInformationView(),
          settings: const RouteSettings(name: personalInformation),
        );

      case familyInformation:
        return MaterialPageRoute(
          builder: (context) => const FamilyInformationView(),
          settings: const RouteSettings(name: familyInformation),
        );

      // Admin
      case adminDashboard:
        return MaterialPageRoute(
          builder: (context) => const AdminDashboardView(),
          settings: const RouteSettings(name: adminDashboard),
        );
      case adminProfile:
        return MaterialPageRoute(
          builder: (context) => const AdminProfileView(),
          settings: const RouteSettings(name: adminProfile),
        );
      case adminAttendanceControl:
        return MaterialPageRoute(
          builder: (context) => const AttendanceControlView(),
          settings: const RouteSettings(name: adminAttendanceControl),
        );

      case adminStudentsDirectory:
        return MaterialPageRoute(
          builder: (context) => const StudentsDirectoryView(),
          settings: const RouteSettings(name: adminStudentsDirectory),
        );
      case adminStudentProfile:
        final student = settings.arguments as Alumno?;
        if (student == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text("Se requiere un estudiante para abrir el perfil"),
              ),
            ),
            settings: const RouteSettings(name: adminStudentProfile),
          );
        }
        final studentDetails = _convertAlumnoToStudentDetails(student);
        return MaterialPageRoute(
          builder: (context) =>
              StudentProfileAdminView(student: studentDetails),
          settings: const RouteSettings(name: adminStudentProfile),
        );
      case adminScheduleManagement:
        return MaterialPageRoute(
          builder: (context) => const ScheduleManagementView(),
          settings: const RouteSettings(name: adminScheduleManagement),
        );
      case adminSchoolSettings:
        return MaterialPageRoute(
          builder: (context) => const SchoolSettingsView(),
          settings: const RouteSettings(name: adminSchoolSettings),
        );

      // User: Student detail & confirmation
      case studentDetail:
        final student = settings.arguments as Alumno?;
        if (student == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text("Se requiere un estudiante para ver el detalle"),
              ),
            ),
            settings: const RouteSettings(name: studentDetail),
          );
        }
        return MaterialPageRoute(
          builder: (context) => StudentDetailView(student: student),
          settings: const RouteSettings(name: studentDetail),
        );

      case studentConfirmation:
        final validationResult = settings.arguments as Map<String, dynamic>?;
        if (validationResult == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text("Se requiere información de validación"),
              ),
            ),
            settings: const RouteSettings(name: studentConfirmation),
          );
        }
        return MaterialPageRoute(
          builder: (context) =>
              StudentConfirmationView(validationResult: validationResult),
          settings: const RouteSettings(name: studentConfirmation),
        );

      // Not found
      default:
        debugPrint("AppRoutes: Route not found: ${settings.name}");
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("Página no encontrada")),
          ),
          settings: const RouteSettings(name: 'not_found'),
        );
    }
  }

  /// Helper: convierte `Alumno` (modelo ligero) a `StudentDetails` (detallado)
  /// Ajustado para el nuevo modelo de Alumno:
  /// - idGrupo, idEscuela, idTurno, idLlave
  /// - turno: enum TurnoEnum (se usa `.name` como string)
  static StudentDetails _convertAlumnoToStudentDetails(Alumno alumno) {
    return StudentDetails(
      id: alumno.id,
      nombre: alumno.nombre,
      matricula: alumno.matricula,
      escuelaId: alumno.idEscuela,
      grupoId: alumno.idGrupo,
      grupo: alumno.grupo,
      nivelEducativo: '', // se puede completar desde joins si hace falta
      turnoId: alumno.idTurno.isEmpty ? null : alumno.idTurno,
      turno: alumno.turno.name, // matutino/vespertino/desconocido
      horaInicioTurno: null,
      horaFinTurno: null,
      llaveId: alumno.idLlave,
      llaveCodigo: null,
      llaveActiva: alumno.vinculado,
      fechaRegistro: alumno.fechaRegistro,
      fechaRegistroLlave: null,
      fechaDesactivacionLlave: null,
      limiteVinculacion: null,
      tutores: const [],
      familyContacts: const [],
    );
  }
}
