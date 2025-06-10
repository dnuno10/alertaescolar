import 'package:alertaescolar/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'user_provider.dart';
import 'student_provider.dart';
import 'notification_provider.dart';

class ProviderManager {
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  static Widget wrapWithProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: child,
    );
  }

  static Future<void> initializeProviders(BuildContext context) async {
    // Prevent multiple initialization attempts
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;

    try {
      // Ensure Flutter binding is initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Add a longer delay to ensure platform channels are ready
      await Future.delayed(const Duration(milliseconds: 500));

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      // Small delay between initialization phases
      await Future.delayed(const Duration(milliseconds: 100));

      // Initialize data providers
      await Future.wait([
        _safeInitialize(() => userProvider.loadCurrentUser()),
        _safeInitialize(() => studentProvider.loadStudents()),
        _safeInitialize(() => notificationProvider.loadNotifications()),
      ]);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error in provider initialization: $e');
    } finally {
      _isInitializing = false;
    }
  }

  static Future<void> _safeInitialize(
      Future<void> Function() initFunction) async {
    try {
      await initFunction();
    } catch (e) {
      debugPrint('Provider initialization error: $e');
    }
  }

  static void resetInitialization() {
    _isInitialized = false;
    _isInitializing = false;
  }
}
