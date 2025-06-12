import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../models/models.dart';

class DayChip extends StatelessWidget {
  final String label;
  final DiaSemana? day;
  final DiaSemana? selectedDay;
  final Function(DiaSemana?) onSelected;
  final Size screenSize;

  const DayChip({
    super.key,
    required this.label,
    required this.day,
    required this.selectedDay,
    required this.onSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDay == day;

    return GestureDetector(
      onTap: () => onSelected(day),
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
