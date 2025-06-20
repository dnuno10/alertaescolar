import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'status_card.dart';

class ShiftSummary extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int tolerance;
  final Size screenSize;

  const ShiftSummary({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.tolerance,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Properly calculate tolerance end time handling minutes overflow
    final totalStartMinutes =
        startTime.hour * 60 + startTime.minute + tolerance;
    final toleranceEndHour =
        (totalStartMinutes ~/ 60) % 24; // Handle day overflow
    final toleranceEndMinute = totalStartMinutes % 60;

    final toleranceEnd = TimeOfDay(
      hour: toleranceEndHour,
      minute: toleranceEndMinute,
    );

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child:
                    Icon(icon, color: color, size: screenSize.height * 0.025),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                title,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: StatusCard(
                  title: l10n.present,
                  time:
                      '${startTime.format(context)} - ${toleranceEnd.format(context)}',
                  color: AppTheme.successColor,
                  icon: Icons.check_circle_rounded,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: StatusCard(
                  title: l10n.late,
                  time: '${l10n.after} ${toleranceEnd.format(context)}',
                  color: AppTheme.warningColor,
                  icon: Icons.schedule_rounded,
                  screenSize: screenSize,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.018,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                Expanded(
                  child: Text(
                    '${l10n.schedule}: ${startTime.format(context)} - ${endTime.format(context)}',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
