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

final supabase = Supabase.instance.client;

/// --- Función para calcular si un usuario es admin ---
Future<bool> _computeIsAdmin(SupabaseClient supabase, User user) async {
  // revisa campo tipo en usuarios
  final userData = await supabase
      .from('usuarios')
      .select('tipo')
      .eq('id', user.id)
      .maybeSingle();

  final isAdminByTipo =
      (userData?['tipo']?.toString() ?? '') == TipoUsuario.administrador.name;

  // revisa lista blanca
  final email = (user.email ?? '').trim().toLowerCase();
  bool isAdminByList = false;
  if (email.isNotEmpty) {
    final adminData = await supabase
        .from('admin_access_list')
        .select('email')
        .eq('email', email)
        .maybeSingle();
    isAdminByList = adminData != null;
  }

  return isAdminByTipo || isAdminByList;
}

/// --- Listener de cambios de auth para FCM ---
void _setupFCMAuthListener() {
  supabase.auth.onAuthStateChange.listen((event) async {
    if (event.event == AuthChangeEvent.signedIn) {
      debugPrint('FCM: User signed in, initializing FCM service');
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          final isAdmin = await _computeIsAdmin(supabase, user);
          if (!isAdmin) {
            await FCMService().initializeFCM();
          } else {
            debugPrint('FCM: User is admin, skipping FCM initialization');
          }
        } catch (e) {
          debugPrint('FCM: Error checking user type: $e');
          // fallback
          await FCMService().initializeFCM();
        }
      }
    } else if (event.event == AuthChangeEvent.signedOut) {
      debugPrint('FCM: User signed out, removing FCM token');
      await FCMService().removeFCMToken();
    }
  });
}

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

  @override
  void initState() {
    super.initState();
    _initializeProvidersAndAutoLogin();
  }

  Future<void> _initializeProvidersAndAutoLogin() async {
    if (!_providersInitialized && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));

      // Initialize providers básicos
      await _initializeProvidersWithoutAuth(context);

      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final session = supabase.auth.currentSession;
      if (session != null) {
        debugPrint("Found existing session: ${session.user.id}");
        try {
          await userProvider.loadCurrentUser(context);

          // lee datos del usuario
          final userData = await supabase
              .from('usuarios')
              .select('email, nombre, apellido, tipo')
              .eq('id', session.user.id)
              .maybeSingle();

          final hasCompleteProfile =
              (userData?['nombre']?.toString() ?? '').isNotEmpty &&
                  (userData?['apellido']?.toString() ?? '').isNotEmpty;

          final isAdmin = await _computeIsAdmin(supabase, session.user);

          if (!hasCompleteProfile) {
            _initialRoute = AppRoutes.finishSettingUp;
            debugPrint("Profile incomplete → ${AppRoutes.finishSettingUp}");
          } else if (isAdmin) {
            _initialRoute = AppRoutes.adminDashboard;
            debugPrint("Admin user → ${AppRoutes.adminDashboard}");
          } else {
            _initialRoute = AppRoutes.home;
            debugPrint("Regular user → ${AppRoutes.home}");
          }
        } catch (e) {
          debugPrint("Error loading user data: $e");
          _initialRoute = AppRoutes.intro;
        }
      } else {
        _initialRoute = AppRoutes.intro;
      }

      if (mounted) {
        setState(() {
          _providersInitialized = true;
          _isAutoLoginChecked = true;
        });
        debugPrint("Final initial route determined: $_initialRoute");
      }
    }
  }

  Future<void> _initializeProvidersWithoutAuth(BuildContext context) async {
    if (!mounted) return;
    try {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      try {
        await notificationProvider.loadNotifications();
        debugPrint("Notification provider initialized successfully");
      } catch (e) {
        debugPrint("Notification provider initialization error: $e");
      }
    } catch (e) {
      debugPrint('Error in basic provider initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_providersInitialized || !_isAutoLoginChecked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Center(
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    "images/alertaescolar_logo.png",
                    width: MediaQuery.of(context).size.height * 0.045,
                    height: MediaQuery.of(context).size.height * 0.045,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Center(
                  child: LoadingAnimationWidget.twoRotatingArc(
                    color: Theme.of(context).colorScheme.onSurface,
                    size: MediaQuery.of(context).size.height * 0.075,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
          initialRoute: _initialRoute,
          onGenerateInitialRoutes: (String initialRouteName) {
            debugPrint(
                'Forcing initial route: $_initialRoute (framework asked for: $initialRouteName)');
            final Route<dynamic>? first = AppRoutes.onGenerateRoute(
              RouteSettings(name: _initialRoute),
            );
            assert(first != null,
                'onGenerateRoute devolvió null para $_initialRoute');
            return [first!];
          },
          onGenerateRoute: AppRoutes.onGenerateRoute,
          navigatorObservers: [
            _NavigationObserver(),
          ],
        );
      },
    );
  }
}

/// --- Observer para debug de navegación ---
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
