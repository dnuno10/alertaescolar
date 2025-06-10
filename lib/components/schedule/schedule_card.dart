import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ScheduleCard extends StatelessWidget {
  final String time;
  final String title;
  final String subject;
  final Color color;
  final bool isActive;
  final Size screenSize;

  const ScheduleCard({
    super.key,
    required this.time,
    required this.title,
    required this.subject,
    required this.color,
    required this.screenSize,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: isActive ? color : AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: isActive
            ? null
            : Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: screenSize.height * 0.015,
                  offset: Offset(0, screenSize.height * 0.005),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: AppTheme.getSubtitle2(screenSize).copyWith(
                  color: isActive
                      ? Colors.white.withOpacity(0.9)
                      : AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.height * 0.01,
                    vertical: screenSize.height * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor,
                    borderRadius:
                        BorderRadius.circular(screenSize.height * 0.01),
                  ),
                  child: Text(
                    l10n.inProgress,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            title,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: isActive
                  ? Colors.white
                  : AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            subject,
            style: AppTheme.getSubtitle2(screenSize).copyWith(
              color: isActive
                  ? Colors.white.withOpacity(0.9)
                  : AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
