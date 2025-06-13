import 'package:alertaescolar/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'managers/provider_manager.dart';
import 'providers/theme_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const AlertaEscolarApp());
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

  @override
  void initState() {
    super.initState();
    _initializeProvidersOnce();
  }

  Future<void> _initializeProvidersOnce() async {
    if (!_providersInitialized && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        await ProviderManager.initializeProviders(context);
        if (mounted) {
          setState(() {
            _providersInitialized = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, child) {
        return MaterialApp(
          title: 'Alerta Escolar',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.intro,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
