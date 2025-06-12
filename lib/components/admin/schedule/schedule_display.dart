import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'class_card.dart';
import 'empty_schedule.dart';

class ScheduleDisplay extends StatelessWidget {
  final String selectedGradeGroup;
  final DiaSemana? selectedDay;
  final List<ClaseHorario> schedules;
  final List<Materia> subjects;
  final Size screenSize;

  const ScheduleDisplay({
    super.key,
    required this.selectedGradeGroup,
    required this.selectedDay,
    required this.schedules,
    required this.subjects,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filteredSchedules = selectedDay == null
        ? schedules
        : schedules.where((schedule) => schedule.dia == selectedDay).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.scheduleOf(selectedGradeGroup),
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selectedDay != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Text(
                  _getDayName(context, selectedDay!),
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        if (filteredSchedules.isEmpty)
          EmptySchedule(
            selectedDay: selectedDay,
            screenSize: screenSize,
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredSchedules.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            itemBuilder: (context, index) {
              return ClassCard(
                clase: filteredSchedules[index],
                index: index,
                screenSize: screenSize,
                subject: _getSubjectById(filteredSchedules[index].materiaId),
              );
            },
          ),
      ],
    );
  }

  String _getDayName(BuildContext context, DiaSemana day) {
    final l10n = AppLocalizations.of(context);
    switch (day) {
      case DiaSemana.lunes:
        return l10n.monday;
      case DiaSemana.martes:
        return l10n.tuesday;
      case DiaSemana.miercoles:
        return l10n.wednesday;
      case DiaSemana.jueves:
        return l10n.thursday;
      case DiaSemana.viernes:
        return l10n.friday;
      case DiaSemana.sabado:
        return l10n.saturday;
      case DiaSemana.domingo:
        return l10n.sunday;
    }
  }

  Materia? _getSubjectById(String materiaId) {
    try {
      return subjects.firstWhere((subject) => subject.id == materiaId);
    } catch (e) {
      return null;
    }
  }
}
