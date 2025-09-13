import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../app/app_theme.dart';
import '../../widgets/custom_snack_bar.dart';

class NoInternetView extends StatefulWidget {
  final VoidCallback? onRetry;

  const NoInternetView({super.key, this.onRetry});

  @override
  State<NoInternetView> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetView> {
  bool _isRetrying = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      // Verificar conectividad
      final connectivityResults = await Connectivity().checkConnectivity();

      // Esperar un momento para dar feedback visual
      await Future.delayed(const Duration(seconds: 1));

      // Verificar si el widget sigue montado antes de continuar
      if (_isDisposed || !mounted) return;

      setState(() {
        _isRetrying = false;
      });

      final hasConnection = connectivityResults.isNotEmpty &&
          !connectivityResults.contains(ConnectivityResult.none);

      if (hasConnection) {
        // Si hay conexión, ejecutar callback
        if (widget.onRetry != null && mounted) {
          widget.onRetry!();
        }
      } else {
        // Mostrar mensaje si aún no hay conexión
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Aún no hay conexión a Internet',
            isError: true,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      // Manejar errores y verificar si sigue montado
      if (mounted && !_isDisposed) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: MediaQuery.of(context).size.height * 0.1,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 32),
                Text(
                  'Sin conexión a Internet',
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verifica tu conexión e inténtalo de nuevo.',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRetrying ? null : _handleRetry,
                    icon: _isRetrying
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isRetrying ? 'Verificando...' : 'Reintentar',
                      style: AppTheme.getButton(screenSize).copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'La aplicación se reconectará automáticamente\ncuando la conexión esté disponible.',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context)
                        .withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
