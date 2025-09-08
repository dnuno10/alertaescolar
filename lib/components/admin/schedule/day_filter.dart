// lib/components/admin/schedule/day_filter.dart
import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'day_chip.dart';

class DayFilter extends StatelessWidget {
  /// Clave del día seleccionado: "lunes", "martes"... o null para "Todos"
  final String? selectedDayKey;
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

    // Normalizamos a 'all' para que el chip de "Todos" se marque cuando selectedDayKey == null
    final normalizedSelectedKey = selectedDayKey ?? 'all';

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
                // ⬇️ Pasamos la clave normalizada para que 'all' quede seleccionado cuando selectedDayKey == null
                selectedDayKey: normalizedSelectedKey,
                // Seguimos reportando null hacia arriba para mantener el contrato de "Todos"
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
                    // ⬇️ Usamos también la clave normalizada para que el estado visual sea consistente
                    selectedDayKey: normalizedSelectedKey,
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
