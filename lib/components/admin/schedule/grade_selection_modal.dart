import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class GradeSelectionModal {
  static Future<void> show(
    BuildContext context,
    String currentGrade,
    void Function(String) onGradeSelected, {
    List<String>? availableGrades,
  }) async {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    // If no available grades are provided, use default ones
    final grades =
        availableGrades ?? ['1°A', '1°B', '2°A', '2°B', '3°A', '3°B'];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            top: AppTheme.getMediumPadding(screenSize),
            bottom: MediaQuery.of(context).viewInsets.bottom +
                AppTheme.getMediumPadding(screenSize),
          ),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
              topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: screenSize.width * 0.15,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.getBorderColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getLargePadding(screenSize),
                ),
                child: Text(
                  l10n.selectGradeAndGroup,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Grade/Group list
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: AppTheme.getMediumPadding(screenSize),
                    mainAxisSpacing: AppTheme.getMediumPadding(screenSize),
                  ),
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    final grade = grades[index];
                    final isSelected = grade == currentGrade;

                    return InkWell(
                      onTap: () {
                        onGradeSelected(grade);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accentBlue
                              : AppTheme.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize),
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accentBlue
                                : AppTheme.getBorderColor(context),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
