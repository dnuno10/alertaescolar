import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';

class EmptySchedule extends StatelessWidget {
  final DiaSemana? selectedDay;
  final Size screenSize;

  const EmptySchedule({
    super.key,
    required this.selectedDay,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final message = selectedDay == null
        ? l10n.noSchedulesAvailable
        : l10n.noClassesForDay(_getDayName(context, selectedDay!));

    final subtitle = selectedDay == null
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
            color: AppTheme.getTextSecondaryColor(context).withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            message,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
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

  String _getDayName(BuildContext context, DiaSemana day) {
    final l10n = AppLocalizations.of(context);
    switch (day) {
      case DiaSemana.lunes:
        return l10n.monday;
      case DiaSemana.martes:
        return l10n.tuesday;
      case DiaSemana.miercoles:
        return l10n.wednesday;
      case DiaSemana.jueves:
        return l10n.thursday;
      case DiaSemana.viernes:
        return l10n.friday;
      case DiaSemana.sabado:
        return l10n.saturday;
      case DiaSemana.domingo:
        return l10n.sunday;
    }
  }
}
