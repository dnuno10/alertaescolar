import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'day_chip.dart';

class DayFilter extends StatelessWidget {
  final String? selectedDayKey; // ej. "lunes", "martes" o null para todos
  final Function(String?) onDaySelected;
  final Size screenSize;

  const DayFilter({
    super.key,
    required this.selectedDayKey,
    required this.onDaySelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final days = <String, String>{
      'lunes': l10n.monday,
      'martes': l10n.tuesday,
      'miercoles': l10n.wednesday,
      'jueves': l10n.thursday,
      'viernes': l10n.friday,
      'sabado': l10n.saturday,
      'domingo': l10n.sunday,
    };

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
              // Opción "Todos"
              DayChip(
                label: l10n.all,
                dayKey: 'all',
                selectedDayKey: selectedDayKey,
                onSelected: (d) => onDaySelected(null),
                screenSize: screenSize,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              // Días de la semana
              ...days.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: AppTheme.getSmallPadding(screenSize) * 0.5,
                  ),
                  child: DayChip(
                    label: entry.value,
                    dayKey: entry.key,
                    selectedDayKey: selectedDayKey,
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
}
