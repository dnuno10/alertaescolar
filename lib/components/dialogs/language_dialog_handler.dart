import 'package:flutter/material.dart';
import '../../widgets/language_selection_dialog.dart';

class LanguageDialogHandler {
  static void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }
}
