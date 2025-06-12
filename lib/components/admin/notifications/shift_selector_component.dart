import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ShiftSelectorComponent extends StatelessWidget {
  final String? selectedShift;
  final Size screenSize;
  final Function() onSelectShift;

  const ShiftSelectorComponent({
    super.key,
    required this.selectedShift,
    required this.screenSize,
    required this.onSelectShift,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.05),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.height * 0.02,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.selectShiftToSend,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        // Shift selector button
        GestureDetector(
          onTap: onSelectShift,
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: selectedShift != null
                  ? AppTheme.accentPurple.withValues(alpha: 0.1)
                  : AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: selectedShift != null
                    ? AppTheme.accentPurple
                    : AppTheme.getBorderColor(context),
                width: selectedShift != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: (selectedShift != null
                            ? AppTheme.accentPurple
                            : AppTheme.getBorderColor(context))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: selectedShift != null
                        ? AppTheme.accentPurple
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedShift ?? l10n.selectShift,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: selectedShift != null
                              ? AppTheme.getTextPrimaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          fontWeight: selectedShift != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        selectedShift != null
                            ? l10n.shiftSelected
                            : l10n.tapToChooseShift,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: selectedShift != null
                        ? AppTheme.accentPurple.withValues(alpha: 0.15)
                        : AppTheme.getBorderColor(context)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    selectedShift != null
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: selectedShift != null
                        ? AppTheme.accentPurple
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.022,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
