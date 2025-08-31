import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'class_card.dart';
import 'empty_schedule.dart';

class ScheduleDisplay extends StatelessWidget {
  final String selectedGradeGroup;
  final String? selectedDayKey; // ej. "lunes" | "martes" | null (todos)
  final List<ClaseHorario> schedules;
  final List<Materia> subjects;
  final Size screenSize;

  const ScheduleDisplay({
    super.key,
    required this.selectedGradeGroup,
    required this.selectedDayKey,
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
            selectedDayKey: selectedDayKey,
            screenSize: screenSize,
          ),
        ],
      );
    }

    // Filtro por día específico
    if (selectedDayKey != null) {
      final daySchedules = schedules
          .where((s) => _isOnDay(s, selectedDayKey!))
          .toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (daySchedules.isEmpty)
            EmptySchedule(
              selectedDayKey: selectedDayKey,
              screenSize: screenSize,
            )
          else
            ...daySchedules.asMap().entries.map((entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: AppTheme.getSmallPadding(screenSize),
                  ),
                  child: ClassCard(
                    clase: entry.value,
                    index: entry.key,
                    screenSize: screenSize,
                    subject: _getSubjectById(entry.value.idMateria),
                    showDay: false, // ya está filtrado por día
                  ),
                )),
        ],
      );
    }

    // Vista semanal completa
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeeklyScheduleHeader(context, selectedGradeGroup),
        SizedBox(height: AppTheme.getLargePadding(screenSize)),
        _buildCompleteWeeklySchedule(context),
      ],
    );
  }

  // ---------- Weekly sections ----------
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
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
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
            child: Icon(Icons.view_week_rounded,
                color: Colors.white, size: screenSize.width * 0.05),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Horario Semanal',
                    style: AppTheme.getH2(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    )),
                Text('Grupo $group - Todas las materias',
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteWeeklySchedule(BuildContext context) {
    // Definir orden de días
    final orderedDays = const [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo',
    ];

    // Agrupar por día usando flags del modelo
    final Map<String, List<ClaseHorario>> byDay = {
      for (final d in orderedDays) d: <ClaseHorario>[],
    };
    for (final s in schedules) {
      for (final d in orderedDays) {
        if (_isOnDay(s, d)) byDay[d]!.add(s);
      }
    }
    // Ordenar cada día por hora de inicio (HH:MM string)
    for (final d in orderedDays) {
      byDay[d]!.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }

    return Column(
      children: orderedDays.map((dayKey) {
        final daySchedules = byDay[dayKey]!;
        final color = _getDayColor(dayKey);

        return Container(
          margin:
              EdgeInsets.only(bottom: AppTheme.getMediumPadding(screenSize)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del día
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(_getDayIcon(dayKey),
                        color: color, size: screenSize.width * 0.045),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      _getDayName(context, dayKey),
                      style: AppTheme.getSubtitle1(screenSize).copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${daySchedules.length} ${daySchedules.length == 1 ? 'clase' : 'clases'}',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              // Clases del día
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
                ...daySchedules.asMap().entries.map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(
                            bottom: AppTheme.getSmallPadding(screenSize) * 0.5),
                        child: ClassCard(
                          clase: entry.value,
                          index: entry.key,
                          screenSize: screenSize,
                          subject: _getSubjectById(entry.value.idMateria),
                          showDay: false,
                        ),
                      ),
                    ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------- Helpers ----------
  bool _isOnDay(ClaseHorario s, String dayKey) {
    switch (dayKey.toLowerCase()) {
      case 'lunes':
        return s.lunes;
      case 'martes':
        return s.martes;
      case 'miercoles':
        return s.miercoles;
      case 'jueves':
        return s.jueves;
      case 'viernes':
        return s.viernes;
      case 'sabado':
        return s.sabado;
      case 'domingo':
        return s.domingo;
      default:
        return false;
    }
  }

  Color _getDayColor(String dayKey) {
    switch (dayKey) {
      case 'lunes':
        return AppTheme.accentBlue;
      case 'martes':
        return AppTheme.accentPurple;
      case 'miercoles':
        return Colors.green;
      case 'jueves':
        return Colors.orange;
      case 'viernes':
        return Colors.red;
      case 'sabado':
        return Colors.indigo;
      case 'domingo':
        return Colors.pink;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getDayIcon(String dayKey) {
    switch (dayKey) {
      case 'lunes':
        return Icons.looks_one_rounded;
      case 'martes':
        return Icons.looks_two_rounded;
      case 'miercoles':
        return Icons.looks_3_rounded;
      case 'jueves':
        return Icons.looks_4_rounded;
      case 'viernes':
        return Icons.looks_5_rounded;
      case 'sabado':
        return Icons.looks_6_rounded;
      case 'domingo':
        return Icons.weekend_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  String _getDayName(BuildContext context, String dayKey) {
    final l10n = AppLocalizations.of(context);
    switch (dayKey) {
      case 'lunes':
        return l10n.monday;
      case 'martes':
        return l10n.tuesday;
      case 'miercoles':
        return l10n.wednesday;
      case 'jueves':
        return l10n.thursday;
      case 'viernes':
        return l10n.friday;
      case 'sabado':
        return l10n.saturday;
      case 'domingo':
        return l10n.sunday;
      default:
        return l10n.unknown; // opcional en tu l10n
    }
  }

  Materia? _getSubjectById(String materiaId) {
    try {
      return subjects.firstWhere((s) => s.id == materiaId);
    } catch (_) {
      return null;
    }
  }
}
