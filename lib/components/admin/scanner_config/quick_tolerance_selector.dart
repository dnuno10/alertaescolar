import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class QuickToleranceSelector extends StatelessWidget {
  final int tolerance;
  final Function(int) onToleranceChanged;
  final Size screenSize;

  const QuickToleranceSelector({
    super.key,
    required this.tolerance,
    required this.onToleranceChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.height * 0.02,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                l10n.quickSelection,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [5, 10, 15, 20, 30].map((minutes) {
              final isSelected = tolerance == minutes;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onToleranceChanged(minutes),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(screenSize),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.warningColor
                          : AppTheme.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.warningColor
                            : AppTheme.getBorderColor(context),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.warningColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$minutes',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.min,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
