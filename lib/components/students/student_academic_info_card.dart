import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';
import 'student_detail_row.dart';

class StudentAcademicInfoCard extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const StudentAcademicInfoCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Added non-null assertion

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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.academicInformation,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.school_rounded,
            label: l10n.gradeLevel,
            value: student.grado,
            iconColor: AppTheme.accentBlue,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.access_time_rounded,
            label: l10n.shift, // Replaced hardcoded 'Turno'
            value: student.turno.name == 'matutino'
                ? l10n.morning
                : l10n.afternoon, // Replaced hardcoded values
            iconColor: AppTheme.accentYellow,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.person_rounded,
            label: l10n.studentId,
            value: student.id.isNotEmpty
                ? student.id.substring(0, 8.clamp(0, student.id.length))
                : l10n.noId,
            iconColor: AppTheme.accentPurple,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }
}
