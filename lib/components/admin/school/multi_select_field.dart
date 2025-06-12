import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class MultiSelectField<T> extends StatelessWidget {
  final String label;
  final List<T> selectedItems;
  final List<T> allItems;
  final ValueChanged<List<T>> onChanged;
  final String Function(T) getLabel;

  const MultiSelectField({
    super.key,
    required this.label,
    required this.selectedItems,
    required this.allItems,
    required this.onChanged,
    required this.getLabel,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectEducationLevels,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              Wrap(
                spacing: AppTheme.getSmallPadding(screenSize),
                runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
                children: allItems.map((item) {
                  final isSelected = selectedItems.contains(item);
                  return InkWell(
                    onTap: () {
                      final newList = List<T>.from(selectedItems);
                      if (isSelected) {
                        if (newList.length > 1) {
                          // Keep at least one selected
                          newList.remove(item);
                        }
                      } else {
                        newList.add(item);
                      }
                      onChanged(newList);
                    },
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentPurple
                            : AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.getBorderColor(context),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: screenSize.width * 0.04,
                            height: screenSize.width * 0.04,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: AppTheme.getBorderColor(context),
                                      width: 1,
                                    ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    color: AppTheme.accentPurple,
                                    size: screenSize.width * 0.03,
                                  )
                                : null,
                          ),
                          SizedBox(
                              width:
                                  AppTheme.getSmallPadding(screenSize) * 0.7),
                          Text(
                            getLabel(item),
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.getTextPrimaryColor(context),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (selectedItems.isEmpty) ...[
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.warningColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: AppTheme.warningColor,
                        size: screenSize.width * 0.04,
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Expanded(
                        child: Text(
                          l10n.selectAtLeastOneLevel,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
