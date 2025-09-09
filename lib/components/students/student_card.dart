import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/views/user/students/student_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

class StudentCard extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const StudentCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor
    ];
    final color = colors[student.hashCode % colors.length];

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _navigateToStudentDetail(context);
          },
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.nombre,
                        style: AppTheme.getSubtitle1(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        student.grupo,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.02,
                          vertical: screenSize.height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: student.vinculado
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize) * 0.7),
                        ),
                        child: Text(
                          student.vinculado ? l10n.active : l10n.inactive,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            fontWeight: FontWeight.w500,
                            color: student.vinculado
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: screenSize.width * 0.06,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStudentDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailView(student: student),
      ),
    );
  }
}
