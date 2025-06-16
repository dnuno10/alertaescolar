import 'package:alertaescolar/managers/family_provider.dart';
import 'package:alertaescolar/providers/language_provider.dart';
import 'package:alertaescolar/managers/schedule_provider.dart'; // Add ScheduleProvider import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'notification_provider.dart';
import 'student_provider.dart';
import 'user_provider.dart';
import 'school_provider.dart'; // Add SchoolProvider import

class ProviderManager {
  // Create provider instances that we'll use for lazy initialization
  static final ThemeProvider _themeProvider = ThemeProvider();
  static final UserProvider _userProvider = UserProvider();
  static final StudentProvider _studentProvider = StudentProvider();
  static final NotificationProvider _notificationProvider =
      NotificationProvider();
  static final FamilyProvider _familyProvider = FamilyProvider();
  static final LocaleProvider _localeProvider = LocaleProvider();
  static final AuthService _authService = AuthService();
  static final SchoolProvider _schoolProvider =
      SchoolProvider(); // Add SchoolProvider instance
  static final ScheduleProvider _scheduleProvider =
      ScheduleProvider(); // Add ScheduleProvider instance

  // Add initialization status flags
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  static Widget wrapWithProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
        ChangeNotifierProvider<UserProvider>.value(value: _userProvider),
        ChangeNotifierProvider<StudentProvider>.value(value: _studentProvider),
        ChangeNotifierProvider<NotificationProvider>.value(
            value: _notificationProvider),
        ChangeNotifierProvider<FamilyProvider>.value(value: _familyProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: _localeProvider),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<SchoolProvider>.value(value: _schoolProvider),
        ChangeNotifierProvider<ScheduleProvider>.value(
            value: _scheduleProvider),
      ],
      child: child,
    );
  }

  // Basic initialization that doesn't require MaterialLocalizations
  static Future<void> initializeProviders(BuildContext context) async {
    // Prevent multiple initialization attempts
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;

    try {
      // Ensure Flutter binding is initialized
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await _userProvider.loadCurrentUser(context);
        debugPrint("User provider initialized successfully");
      } catch (e) {
        debugPrint("User provider initialization error: $e");
      }

      try {
        await _familyProvider.loadFamilyContacts();
        debugPrint("Family provider initialized successfully");
      } catch (e) {
        debugPrint("Family provider initialization error: $e");
      }
      // Initialize providers that don't need MaterialLocalizations
      try {
        await _authService.initialize(context);
        debugPrint("Auth service initialized successfully");
      } catch (e) {
        debugPrint("Auth service initialization error: $e");
      }

      try {
        await _studentProvider.loadStudents();
        debugPrint("Student provider initialized successfully");
      } catch (e) {
        debugPrint("Student provider initialization error: $e");
      }

      try {
        await _notificationProvider.loadNotifications();
        debugPrint("Notification provider initialized successfully");
      } catch (e) {
        debugPrint("Notification provider initialization error: $e");
      }

      // Mark as initialized
      _isInitialized = true;
      debugPrint("Basic providers initialized successfully");
    } catch (e) {
      debugPrint('Error in basic provider initialization: $e');
      // Mark as initialized to avoid getting stuck
      _isInitialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  static void resetInitialization() {
    _isInitialized = false;
    _isInitializing = false;
  }
}
