import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../managers/student_provider.dart';
import '../../../l10n/app_localizations.dart';

class StudentInfoCard extends StatelessWidget {
  final StudentDetails student;
  final Size screenSize;

  const StudentInfoCard({
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
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.15,
            height: screenSize.width * 0.15,
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            ),
            child: Center(
              child: Text(
                student.nombre.isNotEmpty
                    ? student.nombre[0].toUpperCase()
                    : l10n.defaultStudentInitial,
                style: AppTheme.getH1(screenSize).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nombre,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.studentGradeAndGroup(
                      student.nivelEducativo, student.grupo),
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
