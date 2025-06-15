import 'package:alertaescolar/components/pulsating_logo.dart';
import 'package:alertaescolar/providers/language_provider.dart';
import 'package:alertaescolar/providers/schedule_provider.dart';
import 'package:alertaescolar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'managers/provider_manager.dart';
import 'managers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'managers/family_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const AlertaEscolarApp());
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

  @override
  void initState() {
    super.initState();
    _initializeProvidersAndAutoLogin();
  }

  Future<void> _initializeProvidersAndAutoLogin() async {
    if (!_providersInitialized && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        await ProviderManager.initializeProviders(context);

        if (mounted) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final authService = Provider.of<AuthService>(context, listen: false);

          // Check for existing session and load user data directly
          final session = supabase.auth.currentSession;
          if (session != null && session.user != null) {
            debugPrint("Found existing session: ${session.user.id}");

            try {
              // Try to load user data directly into UserProvider
              await userProvider.loadCurrentUser(context);

              // If user is loaded but needs profile completion
              if (!userProvider.hasCompleteProfile()) {
                _initialRoute = '/finish_setting_up';
              } else if (userProvider.isAdmin()) {
                _initialRoute = '/admin';
              } else {
                _initialRoute = '/';
              }
            } catch (e) {
              debugPrint("Error loading user data: $e");
              // Fallback to AuthService
              await authService.checkAndAutoLogin();
              _initialRoute = authService.initialRoute;
            }
          } else {
            _initialRoute = '/intro';
          }

          if (mounted) {
            setState(() {
              _providersInitialized = true;
              _isAutoLoginChecked = true;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until we've checked login state
    if (!_providersInitialized || !_isAutoLoginChecked) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      "images/alertaescolar_logo.png",
                      width: MediaQuery.of(context).size.height * 0.045,
                      height: MediaQuery.of(context).size.height * 0.045,
                    ),
                  ),
                  Center(
                    child: LoadingAnimationWidget.twoRotatingArc(
                      color: AppTheme.getTextPrimaryColor(context),
                      //rightDotColor: AppTheme.accentPurple,
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
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
