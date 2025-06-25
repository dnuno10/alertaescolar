import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';
import 'status_chip.dart';

class SelectableStudentItem extends StatelessWidget {
  final StudentDetails student;
  final bool isLast;
  final Function(StudentDetails) onSelected;
  final Size screenSize;

  const SelectableStudentItem({
    super.key,
    required this.student,
    required this.isLast,
    required this.onSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor =
        student.llaveActiva ? AppTheme.successColor : AppTheme.errorColor;
    final gradeGroup = student.grupo;

    return Container(
      margin: EdgeInsets.only(
          bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onSelected(student);
          },
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Row(
              children: [
                // Student Avatar
                Container(
                  width: screenSize.width * 0.12,
                  height: screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Center(
                    child: Text(
                      student.nombre.isNotEmpty
                          ? student.nombre[0].toUpperCase()
                          : 'E',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
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
                    children: [
                      Text(
                        student.nombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Wrap(
                        spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
                        runSpacing: AppTheme.getSmallPadding(screenSize) * 0.25,
                        children: [
                          StatusChip(
                            text: gradeGroup,
                            color: AppTheme.accentBlue,
                            screenSize: screenSize,
                          ),
                          StatusChip(
                            text: student.llaveActiva
                                ? l10n.active
                                : l10n.inactive,
                            color: statusColor,
                            screenSize: screenSize,
                          ),
                          student.matricula.isNotEmpty
                              ? StatusChip(
                                  text: student.matricula,
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                  screenSize: screenSize,
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.touch_app_rounded,
                    color: AppTheme.accentOrange,
                    size: screenSize.height * 0.025,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
