import 'package:alertaescolar/components/students/empty_students_card.dart';
import 'package:alertaescolar/views/user/students/add_student_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import '../../managers/student_provider.dart';
import '../../models/models.dart';
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

        Consumer<StudentProvider>(
          builder: (context, provider, child) {
            // 1) Loading
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
                    child: const CircularProgressIndicator(
                      color: AppTheme.accentPurple,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            }

            // 2) Error
            if ((provider.error ?? '').isNotEmpty) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.errorColor),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          provider.clearError();
                          // Si procede, vuelve a cargar según tu flujo (tutor/admin)
                          // Por ej. si usas UserProvider en Home, se recargará solo.
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          'Reintentar',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.accentPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 3) Lista
            final students = provider.students;
            if (students.isEmpty) {
              // dentro del builder donde students.isEmpty
              return EmptyStudentsCard(
                screenSize: screenSize,
                onPrimaryAction: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddStudentView()));
                },
                primaryLabel:
                    l10n.linkStudent, // agrega esta key a tu l10n si no existe
              );
            }

            final visible = students.take(3).toList();

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
                children: visible.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();

                      final alumno = Alumno(
                        id: student.id,
                        nombre: student.nombre,
                        idGrupo: student.grupoId,
                        grupo: student.grupo,
                        idEscuela: student.escuelaId,
                        matricula: student.matricula,
                        fechaRegistro: student.fechaRegistro,
                        idTurno: (student.turnoId ?? '').toString(),
                        turno: _mapStringToTurnoEnum(student.turno),
                        idLlave: student.llaveId,
                        vinculado: student.llaveActiva,
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
                      totalVisible: visible.length,
                      screenSize: screenSize,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        )
      ],
    );
  }

  // Helper: string -> TurnoEnum (default: desconocido)
  TurnoEnum _mapStringToTurnoEnum(String? turnoStr) {
    final s = (turnoStr ?? '').toLowerCase().trim();
    if (s.contains('vespertino')) return TurnoEnum.vespertino;
    if (s.contains('matutino')) return TurnoEnum.matutino;
    return TurnoEnum.desconocido;
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
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.2),
                  blurRadius: screenSize.height * 0.008,
                  offset: Offset(0, screenSize.height * 0.003),
                ),
              ],
            ),
            child: Center(
              child: Text(
                student.nombre.isNotEmpty
                    ? student.nombre[0].toUpperCase()
                    : '?',
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
                        // ignore: deprecated_member_use
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          screenSize.height * 0.008,
                        ),
                      ),
                      child: Text(
                        student.nivelEducativo.isNotEmpty
                            ? '${student.nivelEducativo} - ${student.grupo}'
                            : student.grupo,
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
