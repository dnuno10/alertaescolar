import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../app/app_theme.dart';
import '../components/buttons/solid_button.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animación/Ícono de no internet
                Container(
                  width: screenSize.width * 0.3,
                  height: screenSize.width * 0.3,
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getShadowColor(context),
                        blurRadius: 20,
                        spreadRadius: -5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: screenSize.width * 0.15,
                    color: AppTheme.errorColor,
                  ),
                ),

                SizedBox(height: AppTheme.getLargePadding(screenSize)),

                // Título
                Text(
                  'Sin conexión a internet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Descripción
                Text(
                  'Verifica tu conexión a internet e intenta nuevamente',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                    height:
                        32), // usando valor fijo en lugar de getExtraLargePadding

                // Botón reintentar
                SizedBox(
                  width: double.infinity,
                  child: Consumer<ConnectivityProvider>(
                    builder: (context, connectivityProvider, child) {
                      return SolidButton(
                        label: 'Reintentar',
                        screenSize: screenSize,
                        onPressed: () {
                          connectivityProvider.checkConnectivity();
                        },
                        icon: Icons.refresh_rounded,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
