import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'custom_alert_dialog.dart';
import '../buttons/dialog_action_button.dart';

class LogoutDialog extends StatelessWidget {
  final Size screenSize;

  const LogoutDialog({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomAlertDialog(
      title: l10n.signOut,
      content: Text(
        l10n.confirmSignOut,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
          height: 1.4,
        ),
      ),
      actions: [
        DialogActionButton(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
          textColor: AppTheme.getTextSecondaryColor(context),
          screenSize: screenSize,
        ),
        DialogActionButton(
          label: l10n.signOut,
          onPressed: () {
            Navigator.of(context).pop();
            // Implement logout logic
          },
          backgroundColor: AppTheme.errorColor,
          screenSize: screenSize,
        ),
      ],
      screenSize: screenSize,
    );
  }

  static void show(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => LogoutDialog(screenSize: screenSize),
    );
  }
}
