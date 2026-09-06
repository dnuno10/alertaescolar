import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ScheduleHeader extends StatelessWidget {
  final Size screenSize;

  const ScheduleHeader({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
          child: Icon(
            Icons.schedule_rounded,
            color: AppTheme.accentBlue,
            size: screenSize.height * 0.025,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.configureShiftSchedules,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.setEntryExitHoursForShifts,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
