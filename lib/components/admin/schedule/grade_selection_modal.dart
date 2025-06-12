import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class GradeSelectionModal extends StatelessWidget {
  final String selectedGradeGroup;
  final Function(String) onGradeSelected;
  final Size screenSize;

  const GradeSelectionModal({
    super.key,
    required this.selectedGradeGroup,
    required this.onGradeSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: screenSize.height * 0.6,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: AppTheme.getSmallPadding(screenSize)),
            width: screenSize.width * 0.12,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.getTextSecondaryColor(context)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: AppTheme.accentPurple,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    l10n.selectGroup,
                    style: AppTheme.getH2(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),

          // Grade Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
                  mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final grades = [
                    '1°A',
                    '1°B',
                    '1°C',
                    '2°A',
                    '2°B',
                    '2°C',
                    '3°A',
                    '3°B',
                    '3°C',
                    '4°A',
                    '4°B',
                    '4°C',
                  ];
                  final grade = grades[index];
                  final isSelected = grade == selectedGradeGroup;

                  return GestureDetector(
                      onTap: () {
                        onGradeSelected(grade);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accentPurple
                                : AppTheme.getBorderColor(context),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            grade,
                            style: AppTheme.getSubtitle1(screenSize).copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, String selectedGradeGroup,
      Function(String) onGradeSelected) {
    final screenSize = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GradeSelectionModal(
        selectedGradeGroup: selectedGradeGroup,
        onGradeSelected: onGradeSelected,
        screenSize: screenSize,
      ),
    );
  }
}
