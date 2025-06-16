import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';
import 'student_detail_row.dart';

class StudentAcademicInfoCard extends StatelessWidget {
  final StudentDetails student;
  final Size screenSize;

  const StudentAcademicInfoCard({
    super.key,
    required this.student,
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
            icon: Icons.class_rounded,
            label: l10n.educationalLevel,
            value: student.nivelEducativo.isNotEmpty
                ? student.nivelEducativo
                : l10n.notAssigned,
            iconColor: AppTheme.accentBlue,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.group_rounded,
            label: l10n.group,
            value: student.grupo.isNotEmpty ? student.grupo : l10n.notAssigned,
            iconColor: AppTheme.successColor,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.schedule_rounded,
            label: l10n.shift,
            value: student.turno?.isNotEmpty == true
                ? student.turno!
                : l10n.notAssigned,
            iconColor: AppTheme.warningColor,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.badge_rounded,
            label: l10n.studentId,
            value: student.matricula.isNotEmpty ? student.matricula : l10n.noId,
            iconColor: AppTheme.accentPurple,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }
}
