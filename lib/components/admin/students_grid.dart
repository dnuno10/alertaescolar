import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../app/app_routes.dart';

class StudentsGrid extends StatelessWidget {
  final Size screenSize;
  final List<Alumno> students;

  const StudentsGrid({
    super.key,
    required this.screenSize,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (students.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_rounded,
              color: AppTheme.accentBlue,
              size: screenSize.width * 0.06,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Text(
              '${l10n.studentsFound}: ${students.length}',
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenSize.width > 600 ? 2 : 1,
            crossAxisSpacing: AppTheme.getMediumPadding(screenSize),
            mainAxisSpacing: AppTheme.getMediumPadding(screenSize),
            childAspectRatio: screenSize.width > 600 ? 2.5 : 3.5,
          ),
          itemCount: students.length,
          itemBuilder: (context, index) {
            return _buildStudentCard(context, students[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: screenSize.width * 0.15,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noStudentsFound,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            l10n.tryDifferentFilters,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Alumno student, int index) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.adminStudentProfile,
        arguments: student,
      ),
      child: Container(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: screenSize.height * 0.01,
              offset: Offset(0, screenSize.height * 0.005),
            ),
          ],
          border: Border.all(
            color: AppTheme.getBorderColor(context),
          ),
        ),
        child: Row(
          children: [
            // Student Avatar
            Container(
              width: screenSize.width * 0.15,
              height: screenSize.width * 0.15,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Center(
                child: Text(
                  student.nombre[0].toUpperCase(),
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            SizedBox(width: AppTheme.getMediumPadding(screenSize)),

            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    student.nombre,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              AppTheme.getSmallPadding(screenSize) * 0.75,
                          vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize) * 0.5),
                        ),
                        child: Text(
                          student.grado,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Container(
                        width: screenSize.height * 0.005,
                        height: screenSize.height * 0.005,
                        decoration: BoxDecoration(
                          color: student.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: screenSize.height * 0.005),
                      Text(
                        student.activo ? l10n.active : l10n.inactive,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: student.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    '${l10n.registeredOn} ${student.fechaRegistro.day}/${student.fechaRegistro.month}/${student.fechaRegistro.year}',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.width * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}
