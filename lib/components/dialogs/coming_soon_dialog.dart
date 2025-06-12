import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class ComingSoonDialog extends StatelessWidget {
  final String message;
  final Size screenSize;

  const ComingSoonDialog({
    super.key,
    required this.message,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: AppTheme.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      title: Text(
        l10n.functionInDevelopment,
        style: AppTheme.getSubtitle1(screenSize).copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      content: Text(
        message,
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.understood,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.accentPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context, String message) {
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => ComingSoonDialog(
        message: message,
        screenSize: screenSize,
      ),
    );
  }
}
