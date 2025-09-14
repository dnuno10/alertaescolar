import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackBar {
  // Control global de SnackBar activo
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      _currentController;
  static bool _isSnackBarActive = false;

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    bool replace = true, // true = reemplaza el actual; false = encola
    String? actionLabel,
    VoidCallback? onAction,
    bool forceShow = false, // true = fuerza mostrar incluso si hay uno activo
  }) {
    if (!context.mounted) return null;

    // Si hay un snackbar activo y no se fuerza mostrar, descartar nuevo snackbar
    if (_isSnackBarActive && !forceShow && !replace) {
      debugPrint(
          'SnackBar descartado: hay uno activo y no se permite reemplazar');
      return null;
    }

    try {
      // Colores hardcodeados (no usan tema)
      // Puedes ajustar a tonos específicos si prefieres:
      // final Color successColor = const Color(0xFF22C55E); // verde 600
      // final Color errorColor   = const Color(0xFFEF4444); // rojo 500
      final Color successColor = Colors.green;
      final Color errorColor = Colors.red;

      final Color bgColor = isError ? errorColor : successColor;
      final IconData icon =
          isError ? Icons.error_rounded : Icons.check_circle_rounded;

      final messenger = ScaffoldMessenger.of(context);

      // Si hay un snackbar activo, ocultarlo primero
      if (_isSnackBarActive && _currentController != null) {
        _currentController!.close();
        _isSnackBarActive = false;
        _currentController = null;
      }

      if (replace) {
        messenger.hideCurrentSnackBar();
      }

      final snack = SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
                textColor: Colors.white,
              )
            : null,
      );

      // Marcar como activo antes de mostrar
      _isSnackBarActive = true;
      final controller = messenger.showSnackBar(snack);
      _currentController = controller;

      // Configurar callback para cuando se cierre el snackbar
      controller.closed.then((_) {
        _isSnackBarActive = false;
        _currentController = null;
      });

      return controller;
    } catch (e) {
      debugPrint('Failed to show snackbar: $e');
      _isSnackBarActive = false;
      _currentController = null;
      return null;
    }
  }

  /// Oculta el snackbar actual si hay uno activo
  static void hide() {
    if (_isSnackBarActive && _currentController != null) {
      _currentController!.close();
      _isSnackBarActive = false;
      _currentController = null;
    }
  }

  /// Verifica si hay un snackbar activo
  static bool get isActive => _isSnackBarActive;

  /// Limpia el estado (útil para debugging o casos edge)
  static void clearState() {
    _isSnackBarActive = false;
    _currentController = null;
  }
}
