import 'package:alertaescolar/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'managers/provider_manager.dart';
import 'providers/theme_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class _AppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, child) {
        // Initialize providers when the app starts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ProviderManager.initializeProviders(context);
        });

        return MaterialApp(
          title: 'Alerta Escolar',
          debugShowCheckedModeBanner: false,

          // Localization
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // Routes
          initialRoute: AppRoutes.home,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
