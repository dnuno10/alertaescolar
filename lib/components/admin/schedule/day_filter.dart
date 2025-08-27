import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'day_chip.dart';

class DayFilter extends StatelessWidget {
  final DiaSemana? selectedDay;
  final Function(DiaSemana?) onDaySelected;
  final Size screenSize;

  const DayFilter({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.filterByDay,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              DayChip(
                label: l10n.all,
                day: null,
                selectedDay: selectedDay,
                onSelected: onDaySelected,
                screenSize: screenSize,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              ...DiaSemana.values.take(5).map((day) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: AppTheme.getSmallPadding(screenSize) * 0.5),
                  child: DayChip(
                    label: _getDayName(context, day),
                    day: day,
                    selectedDay: selectedDay,
                    onSelected: onDaySelected,
                    screenSize: screenSize,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
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
