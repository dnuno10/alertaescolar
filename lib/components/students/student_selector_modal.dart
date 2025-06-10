import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/alumno.dart';

class StudentSelectorModal extends StatelessWidget {
  final List<Alumno> students;
  final String? selectedStudentId;
  final ValueChanged<String> onStudentSelected;
  final Size screenSize;

  const StudentSelectorModal({
    super.key,
    required this.students,
    required this.selectedStudentId,
    required this.onStudentSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Row(
                children: [
                  Text(
                    l10n.selectStudent,
                    style: AppTheme.getH2(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(screenSize.height * 0.008),
                      decoration: BoxDecoration(
                        color: AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: screenSize.height * 0.025,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de alumnos
            Container(
              constraints: BoxConstraints(
                maxHeight: screenSize.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final isSelected = student.id == selectedStudentId;
                  final colors = [
                    AppTheme.accentBlue,
                    AppTheme.successColor,
                    AppTheme.accentPurple,
                    AppTheme.warningColor,
                  ];
                  final color = colors[index % colors.length];

                  return GestureDetector(
                    onTap: () {
                      onStudentSelected(student.id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                      ),
                      padding:
                          EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.1)
                            : AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : AppTheme.getBorderColor(context),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: screenSize.height * 0.05,
                            height: screenSize.height * 0.05,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getSmallRadius(screenSize)),
                            ),
                            child: Center(
                              child: Text(
                                student.nombre[0].toUpperCase(),
                                style:
                                    AppTheme.getSubtitle1(screenSize).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: AppTheme.getMediumPadding(screenSize)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.nombre,
                                  style: AppTheme.getBodyMedium(screenSize)
                                      .copyWith(
                                    color:
                                        AppTheme.getTextPrimaryColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.003),
                                Text(
                                  student.grado,
                                  style:
                                      AppTheme.getCaption(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: color,
                              size: screenSize.height * 0.025,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ],
        ),
      ),
    );
  }
}
