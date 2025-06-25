import 'package:alertaescolar/providers/language_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'managers/provider_manager.dart';
import 'managers/user_provider.dart';
import 'managers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up FCM background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Set up FCM auth state listener
  _setupFCMAuthListener();

  runApp(const AlertaEscolarApp());
}

/// Set up FCM authentication state listener
void _setupFCMAuthListener() {
  supabase.auth.onAuthStateChange.listen((event) async {
    if (event.event == AuthChangeEvent.signedIn) {
      debugPrint('FCM: User signed in, initializing FCM service');

      // Check if user is admin before initializing FCM
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          final userData = await supabase
              .from('usuarios')
              .select('tipo')
              .eq('id', user.id)
              .maybeSingle();

          if (userData != null) {
            final tipoString = userData['tipo']?.toString() ?? '';
            final isAdmin = tipoString == TipoUsuario.administrador.name;

            if (!isAdmin) {
              // Only initialize FCM for non-admin users
              await FCMService().initializeFCM();
            } else {
              debugPrint('FCM: User is admin, skipping FCM initialization');
            }
          } else {
            // If no user data found, check admin access list
            final adminData = await supabase
                .from('admin_access_list')
                .select('*')
                .eq('email', user.email ?? '')
                .maybeSingle();

            if (adminData == null) {
              // Not in admin list, initialize FCM
              await FCMService().initializeFCM();
            } else {
              debugPrint(
                  'FCM: User is in admin access list, skipping FCM initialization');
            }
          }
        } catch (e) {
          debugPrint('FCM: Error checking user type: $e');
          // On error, initialize FCM as a fallback for safety
          await FCMService().initializeFCM();
        }
      }
    } else if (event.event == AuthChangeEvent.signedOut) {
      debugPrint('FCM: User signed out, removing FCM token');
      await FCMService().removeFCMToken();
    }
  });
}

final supabase = Supabase.instance.client;

class AlertaEscolarApp extends StatelessWidget {
  const AlertaEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderManager.wrapWithProviders(
      child: _AppContent(),
    );
  }
}

class _AppContent extends StatefulWidget {
  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  bool _providersInitialized = false;
  bool _isAutoLoginChecked = false;
  String _initialRoute = AppRoutes.intro;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _initialNavigationCompleted = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _initializeProvidersAndAutoLogin();
  }

  Future<void> _initializeProvidersAndAutoLogin() async {
    if (!_providersInitialized && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        // Initialize providers but skip AuthService to avoid conflicts
        await _initializeProvidersWithoutAuth(context);

        if (mounted) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);

          // Check for existing session and load user data directly
          final session = supabase.auth.currentSession;
          if (session != null) {
            debugPrint("Found existing session: ${session.user.id}");

            try {
              // Try to load user data directly into UserProvider
              await userProvider.loadCurrentUser(context);

              // Get user data from database to check admin status
              final userData = await supabase
                  .from('usuarios')
                  .select('*')
                  .eq('id', session.user.id)
                  .maybeSingle();

              if (userData != null) {
                final tipoString = userData['tipo']?.toString() ?? '';
                final isAdmin = tipoString == TipoUsuario.administrador.name;

                debugPrint(
                    "User data found: email=${userData['email']}, tipo=$tipoString, isAdmin=$isAdmin");

                // Check if profile is complete
                final hasCompleteProfile =
                    (userData['nombre']?.toString() ?? '').isNotEmpty &&
                        (userData['apellido']?.toString() ?? '').isNotEmpty;

                if (!hasCompleteProfile) {
                  _initialRoute = AppRoutes.finishSettingUp; // Use constant
                  debugPrint(
                      "Profile incomplete, routing to ${AppRoutes.finishSettingUp}");
                } else if (isAdmin) {
                  _initialRoute = AppRoutes.adminDashboard; // Use constant
                  debugPrint(
                      "Admin user detected, routing to ${AppRoutes.adminDashboard}");
                } else {
                  _initialRoute = AppRoutes.home; // Use constant
                  debugPrint(
                      "Regular user detected, routing to ${AppRoutes.home}");
                }
              } else {
                // Check if user is in admin access list
                final adminData = await supabase
                    .from('admin_access_list')
                    .select('*')
                    .eq('email', session.user.email ?? '')
                    .maybeSingle();

                if (adminData != null) {
                  _initialRoute = AppRoutes.adminDashboard; // Use constant
                  debugPrint(
                      "Admin user found in access list, routing to ${AppRoutes.adminDashboard}");
                } else {
                  _initialRoute = AppRoutes.finishSettingUp; // Use constant
                }
              }
            } catch (e) {
              debugPrint("Error loading user data: $e");
              _initialRoute = AppRoutes.intro; // Use constant
            }
          } else {
            _initialRoute = AppRoutes.intro; // Use constant
          }

          if (mounted) {
            setState(() {
              _providersInitialized = true;
              _isAutoLoginChecked = true;
            });
            debugPrint("Final initial route determined: $_initialRoute");

            // Mark initial navigation as completed after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _initialNavigationCompleted = true;
                debugPrint("Initial navigation marked as completed");
              }
            });
          }
        }
      }
    }
  }

  // Initialize providers without AuthService to avoid conflicts
  Future<void> _initializeProvidersWithoutAuth(BuildContext context) async {
    if (!mounted) return;

    try {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      // Initialize essential providers only - skip student provider here
      // as it will be initialized in the actual views when needed
      try {
        await notificationProvider.loadNotifications();
        debugPrint("Notification provider initialized successfully");
      } catch (e) {
        debugPrint("Notification provider initialization error: $e");
      }

      debugPrint("Basic providers initialized successfully");
    } catch (e) {
      debugPrint('Error in basic provider initialization: $e');
    }
  }

// ...existing code...

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until we've checked login state
    if (!_providersInitialized || !_isAutoLoginChecked) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      "images/alertaescolar_logo.png",
                      width: MediaQuery.of(context).size.height * 0.045,
                      height: MediaQuery.of(context).size.height * 0.045,
                      color: Colors.black,
                    ),
                  ),
                  Center(
                    child: LoadingAnimationWidget.twoRotatingArc(
                      color: Colors.black,
                      size: MediaQuery.of(context).size.height * 0.075,
                    ),
                  ),
                ],
              ),
            ),
          ));
    }

    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, child) {
        debugPrint("Building MaterialApp with initial route: $_initialRoute");
        return MaterialApp(
          title: 'Alerta Escolar',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          // Use initialRoute instead of home
          initialRoute: _initialRoute,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          // Add navigation observer to debug navigation
          navigatorObservers: [
            _NavigationObserver(),
          ],
        );
      },
    );
  }
}

// Add a navigation observer to debug navigation issues
class _NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint(
        "Navigation: Pushed ${route.settings.name} from ${previousRoute?.settings.name}");
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint(
        "Navigation: Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}");
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    debugPrint(
        "Navigation: Removed ${route.settings.name}, back to ${previousRoute?.settings.name}");
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint(
        "Navigation: Popped ${route.settings.name}, back to ${previousRoute?.settings.name}");
  }
}
