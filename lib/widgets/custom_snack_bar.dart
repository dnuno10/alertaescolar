import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackBar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    bool replace = true, // true = reemplaza el actual; false = encola
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return null;

    try {
      final theme = Theme.of(context);
      final snackTheme = theme.snackBarTheme;

      // Colores por tema con override mínimo para error/éxito
      final bgColor = isError
          ? (snackTheme.backgroundColor ?? theme.colorScheme.error)
          : (snackTheme.backgroundColor ?? theme.colorScheme.primary);

      final icon = isError ? Icons.error : Icons.check_circle;

      // Haptics opcional
      // (no lanzará excepción en web)
      try {
        if (isError) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      } catch (_) {}

      final messenger = ScaffoldMessenger.of(context);

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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        elevation: snackTheme.elevation ?? 6,
        shape: snackTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
                textColor: Colors.white,
              )
            : null,
      );

      return messenger.showSnackBar(snack);
    } catch (e) {
      debugPrint('Failed to show snackbar: $e');
      return null;
    }
  }
}
