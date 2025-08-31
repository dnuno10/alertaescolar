import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

/// Chip de selección de día de la semana.
/// Usamos un [dayKey] en formato string (ej: "lunes", "martes") en lugar de enum.
class DayChip extends StatelessWidget {
  final String label;
  final String dayKey; // p. ej. "lunes", "martes", etc.
  final String? selectedDayKey;
  final Function(String?) onSelected;
  final Size screenSize;

  const DayChip({
    super.key,
    required this.label,
    required this.dayKey,
    required this.selectedDayKey,
    required this.onSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDayKey == dayKey;

    return GestureDetector(
      onTap: () => onSelected(dayKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.accentBlue : AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentBlue
                : AppTheme.getBorderColor(context),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: isSelected
                ? Colors.white
                : AppTheme.getTextPrimaryColor(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
