import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ToleranceDisplayCard extends StatelessWidget {
  final int tolerance;
  final Size screenSize;

  const ToleranceDisplayCard({
    super.key,
    required this.tolerance,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getLargePadding(screenSize),
        vertical: AppTheme.getMediumPadding(screenSize),
      ),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$tolerance',
            style: AppTheme.getH1(screenSize).copyWith(
              color: AppTheme.warningColor,
              fontWeight: FontWeight.w800,
              fontSize: screenSize.height * 0.05,
              letterSpacing: 2,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.minutes,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.ofTolerance,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
