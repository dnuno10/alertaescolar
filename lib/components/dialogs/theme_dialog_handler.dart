import 'package:flutter/material.dart';
import '../../widgets/theme_selection_dialog.dart';

class ThemeDialogHandler {
  static bool _isOpen = false;

  /// Muestra el diálogo de selección de tema con animación y evita aperturas múltiples.
  static Future<void> showThemeDialog(BuildContext context) async {
    if (_isOpen) return;
    _isOpen = true;

    try {
      await showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) => const ThemeSelectionDialog(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
      );
    } finally {
      _isOpen = false;
    }
  }
}
