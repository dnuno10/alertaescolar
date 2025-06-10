import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class DaySelector extends StatelessWidget {
  final int selectedDayIndex;
  final Function(int) onDaySelected;
  final Size screenSize;

  const DaySelector({
    super.key,
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dayNames = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    return Container(
      padding: EdgeInsets.only(
          left: AppTheme.getMediumPadding(screenSize),
          right: AppTheme.getMediumPadding(screenSize),
          bottom: AppTheme.getMediumPadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Días de la semana', // TODO: Add to l10n
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SizedBox(
            height: screenSize.height * 0.06,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dayNames.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedDayIndex;
                return Padding(
                  padding: EdgeInsets.only(
                      right: AppTheme.getSmallPadding(screenSize)),
                  child: GestureDetector(
                    onTap: () => onDaySelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentPurple
                            : AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.getBorderColor(context),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentPurple
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          dayNames[index],
                          style: AppTheme.getCaption(screenSize).copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.onPrimaryColor
                                : AppTheme.getTextPrimaryColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
