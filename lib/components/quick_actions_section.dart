import 'package:alertaescolar/components/buttons/action_button.dart';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class QuickActionsSection extends StatelessWidget {
  final Size screenSize;
  final void Function(int) onActionSelected;

  const QuickActionsSection({
    super.key,
    required this.screenSize,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: AppTheme.getH2(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                title: l10n.viewHistory,
                icon: Icons.history_rounded,
                color: AppTheme.accentBlue,
                onTap: () => onActionSelected(2),
                screenSize: screenSize,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
            Expanded(
              child: ActionButton(
                title: l10n.addStudent,
                icon: Icons.person_add_rounded,
                color: AppTheme.successColor,
                onTap: () => onActionSelected(1),
                screenSize: screenSize,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        SizedBox(
          width: double.infinity,
          child: ActionButton(
            title: l10n.myProfile,
            icon: Icons.account_circle_rounded,
            color: AppTheme.accentPurple,
            onTap: () => onActionSelected(3),
            screenSize: screenSize,
          ),
        ),
      ],
    );
  }
}
