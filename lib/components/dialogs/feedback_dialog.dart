import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'custom_alert_dialog.dart';
import '../buttons/dialog_action_button.dart';

class FeedbackDialog extends StatelessWidget {
  final Size screenSize;

  const FeedbackDialog({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomAlertDialog(
      title: l10n.sendFeedback,
      content: Text(
        l10n.feedbackSystemComingSoon,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
          height: 1.4,
        ),
      ),
      actions: [
        DialogActionButton(
          label: l10n.understood,
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: AppTheme.primaryColor,
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
      builder: (context) => FeedbackDialog(screenSize: screenSize),
    );
  }
}
