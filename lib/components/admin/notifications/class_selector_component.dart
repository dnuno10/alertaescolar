import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ClassSelectorComponent extends StatelessWidget {
  final String? selectedClass;
  final Size screenSize;
  final Function() onSelectClass;

  const ClassSelectorComponent({
    super.key,
    required this.selectedClass,
    required this.screenSize,
    required this.onSelectClass,
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
            color: AppTheme.accentBlue.withValues(alpha: 0.05),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.height * 0.02,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.chooseClassForNotification,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        // Class selector button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onSelectClass();
          },
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: selectedClass != null
                  ? AppTheme.accentBlue.withValues(alpha: 0.1)
                  : AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: selectedClass != null
                    ? AppTheme.accentBlue
                    : AppTheme.getBorderColor(context),
                width: selectedClass != null ? 2 : 1,
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
                    color: (selectedClass != null
                            ? AppTheme.accentBlue
                            : AppTheme.getBorderColor(context))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.class_rounded,
                    color: selectedClass != null
                        ? AppTheme.accentBlue
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
                        selectedClass ?? l10n.selectClass,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: selectedClass != null
                              ? AppTheme.getTextPrimaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          fontWeight: selectedClass != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        selectedClass != null
                            ? l10n.classSelected
                            : l10n.tapToChooseClass,
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
                    color: selectedClass != null
                        ? AppTheme.accentBlue.withValues(alpha: 0.15)
                        : AppTheme.getBorderColor(context)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    selectedClass != null
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: selectedClass != null
                        ? AppTheme.accentBlue
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
