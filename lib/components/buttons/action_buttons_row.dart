import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'custom_outline_button.dart';
import 'solid_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onClearPressed;
  final VoidCallback onAddPressed;
  final bool isLoading;
  final Size screenSize;
  final String? clearButtonText;
  final String? addButtonText;

  const ActionButtonsRow({
    super.key,
    required this.onClearPressed,
    required this.onAddPressed,
    required this.isLoading,
    required this.screenSize,
    this.clearButtonText,
    this.addButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: CustomOutlineButton(
            onPressed: isLoading ? () {} : onClearPressed,
            label: clearButtonText ?? l10n.clear,
            color: AppTheme.accentPurple,
            screenSize: screenSize,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: SolidButton(
            backgroundColor: AppTheme.accentPurple,
            onPressed: isLoading ? () {} : onAddPressed,
            label: addButtonText ?? l10n.addContact,
            screenSize: screenSize,
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}
