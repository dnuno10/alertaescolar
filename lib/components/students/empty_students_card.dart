import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

// empty_students_card.dart
class EmptyStudentsCard extends StatelessWidget {
  final Size screenSize;
  final VoidCallback? onPrimaryAction; // NUEVO (opcional)
  final String? primaryLabel; // NUEVO (opcional)

  const EmptyStudentsCard({
    super.key,
    required this.screenSize,
    this.onPrimaryAction,
    this.primaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_rounded,
              color: AppTheme.getTextSecondaryColor(context), size: 28),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.noStudents,
            textAlign: TextAlign.center,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          if (onPrimaryAction != null)
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          if (onPrimaryAction != null)
            ElevatedButton(
              onPressed: onPrimaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
              ),
              child: Text(primaryLabel ?? l10n.add),
            ),
        ],
      ),
    );
  }
}
