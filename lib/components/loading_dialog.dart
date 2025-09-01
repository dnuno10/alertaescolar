import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingDialog extends StatelessWidget {
  static const String _routeName = '__loading_dialog__';

  final String message;
  final Color? color;

  const LoadingDialog({
    super.key,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spinnerColor = color ?? theme.colorScheme.primary;

    return Material(
      color: AppTheme.getBackgroundColor(context),
      child: Center(
        child: Semantics(
          label: message.isEmpty ? 'Cargando' : message,
          liveRegion: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: spinnerColor),
              if (message.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // -------- Manejo idempotente --------
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    Color? color,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: _routeName,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, __, ___) =>
          LoadingDialog(message: message, color: color),
      useRootNavigator: true,
      routeSettings: const RouteSettings(name: _routeName),
    ).whenComplete(() {
      _isShowing = false;
    });
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return; // nada que cerrar
    try {
      final navigator = Navigator.of(context, rootNavigator: true);
      // Quita únicamente el diálogo si está arriba de la pila
      navigator.popUntil((route) {
        // Detente cuando el route de arriba YA NO sea el loading
        return route.settings.name != _routeName;
      });
    } catch (e) {
      debugPrint('Error hiding loading dialog: $e');
    } finally {
      _isShowing = false;
    }
  }
}
