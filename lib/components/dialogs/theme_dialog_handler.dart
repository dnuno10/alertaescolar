import 'package:flutter/material.dart';
import '../../widgets/theme_selection_dialog.dart';

class ThemeDialogHandler {
  static void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectionDialog(),
    );
  }
}
