import 'package:alertaescolar/components/students/empty_students_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import '../../managers/student_provider.dart';
import '../../models/alumno.dart';
import '../../views/user/students/student_detail_view.dart';

class StudentsOverviewSection extends StatelessWidget {
  final Size screenSize;
  final VoidCallback onTapViewAll;

  const StudentsOverviewSection({
    super.key,
    required this.screenSize,
    required this.onTapViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y botón "ver todos"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myStudents,
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onTapViewAll();
              },
              child: Text(
                l10n.viewAll,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Lista de estudiantes
        Consumer<StudentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(screenSize)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getShadowColor(context),
                      blurRadius: screenSize.height * 0.015,
                      offset: Offset(0, screenSize.height * 0.005),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: AppTheme.getMediumPadding(screenSize)),
                    child: CircularProgressIndicator(
                      color: AppTheme.accentPurple,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            }

            final students = provider.students;

            if (students.isEmpty) {
              return EmptyStudentsCard(screenSize: screenSize);
            }

            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: screenSize.height * 0.015,
                    offset: Offset(0, screenSize.height * 0.005),
                  ),
                ],
              ),
              child: Column(
                children: students.take(3).map((student) {
                  final index = students.indexOf(student);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      // Convertir StudentDetails a Alumno
                      final alumno = Alumno(
                        id: student.id,
                        nombre: student.nombre,
                        id_grupo: student.grupoId,
                        grupo: student.grupo,
                        id_escuela: student.escuelaId,
                        id_llave: student.llaveId ?? '',
                        vinculado: student.llaveActiva,
                        matricula: student.matricula,
                        fecha_registro: student.fechaRegistro,
                        turno: _mapStringToTurnoEnum(student.turno),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentDetailView(student: alumno),
                        ),
                      );
                    },
                    child: StudentListItem(
                      student: student,
                      index: index,
                      totalVisible: students.take(3).length,
                      screenSize: screenSize,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper para convertir string a TurnoEnum
  TurnoEnum _mapStringToTurnoEnum(String? turnoStr) {
    if (turnoStr == null) return TurnoEnum.matutino;
    return TurnoEnum.values.firstWhere(
      (e) => e.name.toLowerCase() == turnoStr.toLowerCase(),
      orElse: () => TurnoEnum.matutino,
    );
  }
}

class StudentListItem extends StatelessWidget {
  final StudentDetails student;
  final int index;
  final int totalVisible;
  final Size screenSize;

  const StudentListItem({
    super.key,
    required this.student,
    required this.index,
    required this.totalVisible,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
    ];
    final color = colors[index % colors.length];
    final isLast = index == totalVisible - 1;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: screenSize.height * 0.06,
            height: screenSize.height * 0.06,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(screenSize),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: screenSize.height * 0.008,
                  offset: Offset(0, screenSize.height * 0.003),
                ),
              ],
            ),
            child: Center(
              child: Text(
                student.nombre[0].toUpperCase(),
                style: AppTheme.getH2(screenSize).copyWith(
                  color: Colors.white,
                  letterSpacing: -0.2,
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
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenSize.height * 0.005),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.height * 0.008,
                        vertical: screenSize.height * 0.003,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          screenSize.height * 0.008,
                        ),
                      ),
                      child: Text(
                        student.grupo,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Container(
                      width: screenSize.height * 0.005,
                      height: screenSize.height * 0.005,
                      decoration: BoxDecoration(
                        color: student.llaveActiva
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: screenSize.height * 0.005),
                    Text(
                      student.llaveActiva ? l10n.active : l10n.inactive,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: student.llaveActiva
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.getTextSecondaryColor(context),
            size: screenSize.height * 0.023,
          ),
        ],
      ),
    );
  }
}
