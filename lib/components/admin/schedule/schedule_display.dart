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

    if (schedules.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scheduleOf(selectedGradeGroup),
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          EmptySchedule(
            selectedDay: selectedDay,
            screenSize: screenSize,
          ),
        ],
      );
    }

    // If a specific day is selected, show only that day's schedule
    if (selectedDay != null) {
      final daySchedules = schedules
          .where((schedule) => schedule.dia == selectedDay)
          .toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (daySchedules.isEmpty)
            EmptySchedule(
              selectedDay: selectedDay,
              screenSize: screenSize,
            )
          else
            ...daySchedules.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: AppTheme.getSmallPadding(screenSize),
                ),
                child: ClassCard(
                  clase: entry.value,
                  index: entry.key,
                  screenSize: screenSize,
                  subject: _getSubjectById(entry.value.materiaId),
                  showDay: false, // Don't show day in individual cards
                ),
              );
            }).toList(),
        ],
      );
    }

    // Show complete weekly schedule
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeeklyScheduleHeader(context, selectedGradeGroup),
        SizedBox(height: AppTheme.getLargePadding(screenSize)),
        _buildCompleteWeeklySchedule(context),
      ],
    );
  }

  Widget _buildDayHeader(BuildContext context, DiaSemana day, String group) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.1),
            AppTheme.accentPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue,
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: screenSize.width * 0.05,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDayName(context, day),
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Horario de $group',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleHeader(BuildContext context, String group) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.1),
            AppTheme.accentPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple,
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.view_week_rounded,
              color: Colors.white,
              size: screenSize.width * 0.05,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horario Semanal',
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Grupo $group - Todas las materias',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteWeeklySchedule(BuildContext context) {
    // Group schedules by day
    final schedulesByDay = <DiaSemana, List<ClaseHorario>>{};

    for (final schedule in schedules) {
      if (!schedulesByDay.containsKey(schedule.dia)) {
        schedulesByDay[schedule.dia] = [];
      }
      schedulesByDay[schedule.dia]!.add(schedule);
    }

    // Sort schedules within each day by time
    schedulesByDay.forEach((day, daySchedules) {
      daySchedules.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    });

    final daysOfWeek = [
      DiaSemana.lunes,
      DiaSemana.martes,
      DiaSemana.miercoles,
      DiaSemana.jueves,
      DiaSemana.viernes,
      DiaSemana.sabado,
      DiaSemana.domingo,
    ];

    return Column(
      children: daysOfWeek.map((day) {
        final daySchedules = schedulesByDay[day] ?? [];

        return Container(
          margin:
              EdgeInsets.only(bottom: AppTheme.getMediumPadding(screenSize)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
                decoration: BoxDecoration(
                  color: _getDayColor(day).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  border: Border.all(
                    color: _getDayColor(day).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDayIcon(day),
                      color: _getDayColor(day),
                      size: screenSize.width * 0.045,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      _getDayName(context, day),
                      style: AppTheme.getSubtitle1(screenSize).copyWith(
                        color: _getDayColor(day),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${daySchedules.length} ${daySchedules.length == 1 ? 'clase' : 'clases'}',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: _getDayColor(day),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.getSmallPadding(screenSize)),

              // Day's classes
              if (daySchedules.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.getTextSecondaryColor(context)
                        .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.getTextSecondaryColor(context)
                          .withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    'No hay clases programadas',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...daySchedules.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: AppTheme.getSmallPadding(screenSize) * 0.5,
                    ),
                    child: ClassCard(
                      clase: entry.value,
                      index: entry.key,
                      screenSize: screenSize,
                      subject: _getSubjectById(entry.value.materiaId),
                      showDay:
                          false, // Don't show day in cards since it's already shown in header
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getDayColor(DiaSemana day) {
    switch (day) {
      case DiaSemana.lunes:
        return AppTheme.accentBlue;
      case DiaSemana.martes:
        return AppTheme.accentPurple;
      case DiaSemana.miercoles:
        return Colors.green;
      case DiaSemana.jueves:
        return Colors.orange;
      case DiaSemana.viernes:
        return Colors.red;
      case DiaSemana.sabado:
        return Colors.indigo;
      case DiaSemana.domingo:
        return Colors.pink;
    }
  }

  IconData _getDayIcon(DiaSemana day) {
    switch (day) {
      case DiaSemana.lunes:
        return Icons.looks_one_rounded;
      case DiaSemana.martes:
        return Icons.looks_two_rounded;
      case DiaSemana.miercoles:
        return Icons.looks_3_rounded;
      case DiaSemana.jueves:
        return Icons.looks_4_rounded;
      case DiaSemana.viernes:
        return Icons.looks_5_rounded;
      case DiaSemana.sabado:
        return Icons.looks_6_rounded;
      case DiaSemana.domingo:
        return Icons.weekend_rounded;
    }
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
