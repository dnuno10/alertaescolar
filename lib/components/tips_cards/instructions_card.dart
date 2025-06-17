import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class InstructionsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final Size screenSize;

  const InstructionsCard({
    super.key,
    required this.l10n,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.accentBlue,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.instructions,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.linkStudentInstructions,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
