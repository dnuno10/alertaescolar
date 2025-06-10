import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class StudentsSectionTitle extends StatelessWidget {
  final int studentCount;
  final Size screenSize;

  const StudentsSectionTitle({
    super.key,
    required this.studentCount,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.registeredStudents,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Text(
          studentCount > 0
              ? l10n.studentsLinked(studentCount)
              : l10n.noStudentsLinked,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }
}
