import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../views/auth/no_internet_view.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final Widget? customNoInternetView;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.customNoInternetView,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        // Si nunca ha habido conexión, mostrar loading
        if (!connectivityProvider.hasBeenConnected &&
            connectivityProvider.isConnected) {
          return child;
        }

        // Si no hay conexión y ya ha estado conectado antes, mostrar vista de no internet
        if (!connectivityProvider.isConnected &&
            connectivityProvider.hasBeenConnected) {
          return customNoInternetView ??
              NoInternetView(
                onRetry: () {
                  // Forzar verificación de conectividad
                  connectivityProvider.checkConnectivity();
                },
              );
        }

        // Si hay conexión o es la primera vez, mostrar la app normal
        return child;
      },
    );
  }
}

class GlobalConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const GlobalConnectivityWrapper({super.key, required this.child});

  @override
  State<GlobalConnectivityWrapper> createState() =>
      _GlobalConnectivityWrapperState();
}

class _GlobalConnectivityWrapperState extends State<GlobalConnectivityWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        // Si no hay conexión, mostrar overlay global
        if (!connectivityProvider.isConnected) {
          return Stack(
            children: [
              // Mantener la vista actual pero deshabilitada
              IgnorePointer(
                child: Opacity(
                  opacity: 0.3,
                  child: widget.child,
                ),
              ),
              // Overlay de no internet
              Positioned.fill(
                child: NoInternetView(
                  onRetry: () async {
                    if (mounted) {
                      final hasConnection =
                          await connectivityProvider.checkConnectivity();
                      if (hasConnection && mounted) {
                        // La conectividad se restaurará automáticamente
                        debugPrint('Connection restored from retry button');
                      }
                    }
                  },
                ),
              ),
            ],
          );
        }

        return widget.child;
      },
    );
  }
}
