import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class GradeSelector extends StatelessWidget {
  final String selectedGradeGroup;
  final VoidCallback onSelectGrade;
  final Size screenSize;

  const GradeSelector({
    super.key,
    required this.selectedGradeGroup,
    required this.onSelectGrade,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.schedulesByGroup,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              formattedDate,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Modern Grade selector
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border:
                Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.school_rounded,
                size: screenSize.height * 0.02,
                color: AppTheme.accentPurple,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                l10n.group,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.2),
              Expanded(
                child: GestureDetector(
                  onTap: onSelectGrade,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple,
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedGradeGroup,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: screenSize.height * 0.018,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
