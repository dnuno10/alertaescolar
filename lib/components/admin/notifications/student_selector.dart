import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class StudentSelector extends StatelessWidget {
  final Map<String, dynamic>? selectedStudent;
  final Size screenSize;
  final VoidCallback onSelectStudent;

  const StudentSelector({
    super.key,
    required this.selectedStudent,
    required this.screenSize,
    required this.onSelectStudent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Header with instructions
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withValues(alpha: 0.05),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentOrange.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentOrange,
                size: screenSize.height * 0.02,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.selectStudentFromDirectory,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        // Student selector button
        GestureDetector(
          onTap: onSelectStudent,
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: selectedStudent != null
                  ? AppTheme.accentOrange.withValues(alpha: 0.1)
                  : AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: selectedStudent != null
                    ? AppTheme.accentOrange
                    : AppTheme.getBorderColor(context),
                width: selectedStudent != null ? 2 : 1,
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
                    color: (selectedStudent != null
                            ? AppTheme.accentOrange
                            : AppTheme.getBorderColor(context))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    selectedStudent != null
                        ? Icons.person_rounded
                        : Icons.search_rounded,
                    color: selectedStudent != null
                        ? AppTheme.accentOrange
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
                        selectedStudent != null
                            ? selectedStudent!['name']
                            : l10n.searchInDirectory,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: selectedStudent != null
                              ? AppTheme.getTextPrimaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          fontWeight: selectedStudent != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        selectedStudent != null
                            ? '${l10n.grade}: ${selectedStudent!['grade']} - ${selectedStudent!['section']}'
                            : l10n.navigateToStudentDirectory,
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
                    color: selectedStudent != null
                        ? AppTheme.accentOrange.withValues(alpha: 0.15)
                        : AppTheme.getBorderColor(context)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    selectedStudent != null
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: selectedStudent != null
                        ? AppTheme.accentOrange
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
