import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class EmptyStudentsCard extends StatelessWidget {
  final Size screenSize;

  const EmptyStudentsCard({super.key, required this.screenSize});

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
      child: Center(
        child: Text(
          l10n.noStudents,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ),
    );
  }
}
