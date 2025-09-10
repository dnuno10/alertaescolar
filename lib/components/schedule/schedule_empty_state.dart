import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class ScheduleEmptyState extends StatelessWidget {
  final String dayKey; // ej. "lunes", "martes"
  final Size screenSize;

  const ScheduleEmptyState({
    super.key,
    required this.dayKey,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: screenSize.height * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenSize.width * 0.2,
              height: screenSize.width * 0.2,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.accentPurple.withOpacity(0.1),
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
              l10n.noClassesScheduledForDay(_getDayName(context, dayKey)),
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

  String _getDayName(BuildContext context, String dayKey) {
    final l10n = AppLocalizations.of(context);
    switch (dayKey.toLowerCase()) {
      case 'lunes':
        return l10n.monday;
      case 'martes':
        return l10n.tuesday;
      case 'miercoles':
        return l10n.wednesday;
      case 'jueves':
        return l10n.thursday;
      case 'viernes':
        return l10n.friday;
      case 'sabado':
        return l10n.saturday;
      case 'domingo':
        return l10n.sunday;
      default:
        return l10n.unknown; // asegúrate de definirlo en l10n
    }
  }
}
