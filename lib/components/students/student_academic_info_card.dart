// lib/components/students/student_academic_info_card.dart
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

    // Normalización para evitar condicionales en cada fila
    final String nivel = (student.nivelEducativo.trim().isNotEmpty)
        ? student.nivelEducativo
        : l10n.notAssigned;

    final String grupo =
        (student.grupo.trim().isNotEmpty) ? student.grupo : l10n.notAssigned;

    final String turno = ((student.turno ?? '').trim().isNotEmpty)
        ? student.turno!
        : l10n.notAssigned;

    final String matricula =
        (student.matricula.trim().isNotEmpty) ? student.matricula : l10n.noId;

    return Container(
      constraints: const BoxConstraints(maxWidth: 720),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: const [],
      ),
      child: Semantics(
        container: true,
        label: l10n.academicInformation,
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

            // Nivel educativo
            StudentDetailRow(
              icon: Icons.class_rounded,
              label: l10n.educationalLevel,
              value: nivel,
              iconColor: AppTheme.accentBlue,
              screenSize: screenSize,
              semanticsValue: '${l10n.educationalLevel}: $nivel',
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Grupo
            StudentDetailRow(
              icon: Icons.group_rounded,
              label: l10n.group,
              value: grupo,
              iconColor: AppTheme.successColor,
              screenSize: screenSize,
              semanticsValue: '${l10n.group}: $grupo',
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Turno
            StudentDetailRow(
              icon: Icons.schedule_rounded,
              label: l10n.shift,
              value: turno,
              iconColor: AppTheme.warningColor,
              screenSize: screenSize,
              semanticsValue: '${l10n.shift}: $turno',
              // onTap: () => ... // opcional: atajo al horario
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Matrícula (seleccionable para copiar)
            StudentDetailRow(
              icon: Icons.badge_rounded,
              label: l10n.studentId,
              value: matricula,
              iconColor: AppTheme.accentPurple,
              screenSize: screenSize,
              selectableValue: true,
              semanticsValue: '${l10n.studentId}: $matricula',
            ),
          ],
        ),
      ),
    );
  }
}
