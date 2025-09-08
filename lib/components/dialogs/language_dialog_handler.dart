import 'package:flutter/material.dart';
import '../../widgets/language_selection_dialog.dart';

class LanguageDialogHandler {
  static bool _isOpen = false;

  /// Muestra el diálogo de selección de idioma con animación y evita aperturas múltiples.
  static Future<void> showLanguageDialog(BuildContext context) async {
    if (_isOpen) return;
    _isOpen = true;

    try {
      await showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) => const LanguageSelectionDialog(),
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
