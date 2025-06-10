import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

class ScheduleEmptyState extends StatelessWidget {
  final DiaSemana day;
  final Size screenSize;

  const ScheduleEmptyState({
    super.key,
    required this.day,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: screenSize.height * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenSize.width * 0.2,
              height: screenSize.width * 0.2,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Icon(
                Icons.event_available_outlined,
                size: screenSize.width * 0.1,
                color: AppTheme.accentPurple,
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              l10n.noScheduledClasses,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.noClassesScheduledForDay(day.name),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
