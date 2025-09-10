import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class EmptySchedule extends StatelessWidget {
  final String? selectedDayKey; // ej. "lunes", "martes", null = sin filtro
  final Size screenSize;

  const EmptySchedule({
    super.key,
    required this.selectedDayKey,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final message = selectedDayKey == null
        ? l10n.noSchedulesAvailable
        : l10n.noClassesForDay(_getDayName(context, selectedDayKey!));

    final subtitle = selectedDayKey == null
        ? l10n.noSchedulesConfiguredForGroup
        : l10n.noClassesScheduledForThisDay;

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: screenSize.width * 0.15,
            // ignore: deprecated_member_use
            color: AppTheme.getTextSecondaryColor(context).withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            message,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            subtitle,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
        return l10n.unknown; // agrega en l10n si lo necesitas
    }
  }
}
