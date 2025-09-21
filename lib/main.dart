import 'package:alertaescolar/providers/language_provider.dart';
import 'package:alertaescolar/widgets/connectivity_wrapper.dart';
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
    url: "https://nxzyodpetbfhgishwbrx.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54enlvZHBldGJmaGdpc2h3YnJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3NzExNDMsImV4cCI6MjA2NTM0NzE0M30.mjLMUonFEfd8Q7FPfmLnzdE5c61HcZP3mLm-om8vMpc",
  );

  // Set up FCM auth state listener
  _setupFCMAuthListener();

  runApp(const AlertaEscolarApp());
}

final supabase = Supabase.instance.client;

// ?!? - Podemos mover esta funcionalidad a alguna utilidad de admin para no tenerlo en el main.dart?
Future<bool> _computeIsAdmin(SupabaseClient supabase, User user) async {
  final userData = await supabase
      .from('usuarios')
      .select('tipo')
      .eq('id', user.id)
      .maybeSingle();

  final isAdminByTipo =
      (userData?['tipo']?.toString() ?? '') == TipoUsuario.administrador.name;

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

  //Validamos que el admin se encuentre con el tipo "administrador" en la tabla usuarios y el email del usuario se encuentre en la tabla admin_access_list
  return isAdminByTipo || isAdminByList;
}

void _setupFCMAuthListener() {
  //Escuchamos cuando exista una autenticación
  supabase.auth.onAuthStateChange.listen((event) async {
    if (event.event == AuthChangeEvent.signedIn) {
      debugPrint('FCM: User signed in, initializing FCM service');
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          final isAdmin = await _computeIsAdmin(supabase, user);
          //Si no es admin inicializamos FCM (Solo asignamos token a usuarios no admin)
          if (!isAdmin) {
            await FCMService().initializeFCM();
          } else {
            debugPrint('FCM: User is admin, skipping FCM initialization');
          }
        } catch (e) {
          debugPrint('FCM: Error checking user type: $e');
          await FCMService().initializeFCM();
        }
      }
    }
    //?!? - Por alguna razón no se eliminan los tokens cuando el usuario cierra sesión
    else if (event.event == AuthChangeEvent.signedOut) {
      //Si el usuario cierra sesión eliminamos el token FCM
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

  // ?!? - Podemos mover esto a un provider de autenticación?
  Future<void> _initializeProvidersAndAutoLogin() async {
    if (!_providersInitialized && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      //  ?!? - Inicializamos providers sin un auth hay necesidad?
      await _initializeProvidersWithoutAuth(context);

      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final session = supabase.auth.currentSession;
      //Si se detecta una sesión activa
      if (session != null) {
        try {
          await userProvider.loadCurrentUser(context, showDialog: false);

          final userData = await supabase
              .from('usuarios')
              .select('email, nombre, apellido, tipo')
              .eq('id', session.user.id)
              .maybeSingle();

          final hasCompleteProfile =
              (userData?['nombre']?.toString() ?? '').isNotEmpty &&
                  (userData?['apellido']?.toString() ?? '').isNotEmpty;

          //Validamos si es admin
          final isAdmin = await _computeIsAdmin(supabase, session.user);

          //Si no tiene nombre o apellido enviar a finishSettingUp
          if (!hasCompleteProfile) {
            _initialRoute = AppRoutes.finishSettingUp;
            // Si la cuenta se encuentra con el tipo "administrador" en la tabla usuarios y el email del usuario se encuentre en la tabla admin_access_list
          } else if (isAdmin) {
            _initialRoute = AppRoutes.adminDashboard;
            //Si no, es un usuario normal y accede como padre de familia
          } else {
            _initialRoute = AppRoutes.home;
          }
          //Cualquier error se dirije al intro
        } catch (e) {
          debugPrint("Error loading user data: $e");
          _initialRoute = AppRoutes.intro;
        }
      }
      //En caso de que no haya ninguna sección activa se dirije al intro
      else {
        _initialRoute = AppRoutes.intro;
      }

      if (mounted) {
        setState(() {
          _providersInitialized = true;
          _isAutoLoginChecked = true;
        });
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
            final Route<dynamic>? first = AppRoutes.onGenerateRoute(
              RouteSettings(name: _initialRoute),
            );
            return [first!];
          },
          onGenerateRoute: AppRoutes.onGenerateRoute,
          navigatorObservers: [
            // ?!? - Podemos desactivar esto en producción?
            _NavigationObserver(),
          ],
          builder: (context, child) {
            return GlobalConnectivityWrapper(child: child ?? Container());
          },
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
