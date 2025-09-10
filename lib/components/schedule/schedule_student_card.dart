import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

class ScheduleStudentCard extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const ScheduleStudentCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor
    ];
    final color = colors[student.hashCode % colors.length];

    return Container(
      width: screenSize.width * 0.9,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.15,
            height: screenSize.width * 0.15,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                student.nombre.isNotEmpty
                    ? student.nombre[0].toUpperCase()
                    : 'A',
                style: AppTheme.getH2(screenSize).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onPrimaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nombre,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.002),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Text(
                        student.grupo,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: student.vinculado
                            // ignore: deprecated_member_use
                            ? AppTheme.successColor.withOpacity(0.1)
                            // ignore: deprecated_member_use
                            : AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Text(
                        student.vinculado ? 'Activo' : 'Inactivo',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: student.vinculado
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
