import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'empty_schedule.dart';

/// Presentación minimalista, sin sombras.
/// - Día seleccionado: lista simple de clases (tipo transacciones).
/// - Semana completa: secciones por día con header sobrio.
/// - Todo a prueba de overflow y en 12h AM/PM.
class ScheduleDisplay extends StatelessWidget {
  final String selectedGradeGroup;
  final String? selectedDayKey; // "lunes" | "martes" | null (todos)
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

  // ====== Utils ======
  String _format12(String hhmm) {
    // Soporta "HH:mm" o "HH:mm:ss"
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h24 = int.tryParse(parts[0]) ?? 0;
    final m = parts[1].padLeft(2, '0');
    final period = (h24 >= 12) ? 'PM' : 'AM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final h = h12.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

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

  String _dayName(BuildContext context, String d) {
    final l = AppLocalizations.of(context);
    switch (d) {
      case 'lunes':
        return l.monday;
      case 'martes':
        return l.tuesday;
      case 'miercoles':
        return l.wednesday;
      case 'jueves':
        return l.thursday;
      case 'viernes':
        return l.friday;
      case 'sabado':
        return l.saturday;
      case 'domingo':
        return l.sunday;
      default:
        return l.unknown;
    }
  }

  Color _dayAccent(String d) {
    switch (d) {
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

  IconData _dayIcon(String d) {
    switch (d) {
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

  Materia? _getSubjectById(String id) {
    try {
      return subjects.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  String _subjectName(Materia? m) => (m == null)
      ? 'Materia'
      : (m.nombre.toString().trim().isNotEmpty == true ? m.nombre : 'Materia');

  String _getTeacherName(ClaseHorario clase) {
    // Get teacher name from the subject/materia
    final materia = _getSubjectById(clase.idMateria);
    return materia?.profesor ?? 'Sin profesor';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final padS = AppTheme.getSmallPadding(screenSize);
    final padM = AppTheme.getMediumPadding(screenSize);

    if (schedules.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderMinimal(
            title: l10n.scheduleOf(selectedGradeGroup),
            subtitle: 'Semana completa',
            screenSize: screenSize,
          ),
          SizedBox(height: padM),
          EmptySchedule(selectedDayKey: selectedDayKey, screenSize: screenSize),
        ],
      );
    }

    // ====== Vista: Día seleccionado ======
    if (selectedDayKey != null) {
      final dayKey = selectedDayKey!;
      final list = schedules.where((s) => _isOnDay(s, dayKey)).toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderMinimal(
            title: _dayName(context, dayKey),
            subtitle:
                'Grupo $selectedGradeGroup · ${list.length} ${list.length == 1 ? "clase" : "clases"}',
            color: _dayAccent(dayKey),
            icon: _dayIcon(dayKey),
            screenSize: screenSize,
          ),
          SizedBox(height: padS),
          if (list.isEmpty)
            EmptySchedule(
                selectedDayKey: selectedDayKey, screenSize: screenSize)
          else
            ...list.map((c) => Padding(
                  padding: EdgeInsets.only(bottom: padS),
                  child: _MinimalClassRow(
                    start: _format12(c.horaInicio),
                    end: _format12(c.horaFin),
                    title: _subjectName(_getSubjectById(c.idMateria)),
                    classroom: c.aula,
                    teacher: _getTeacherName(c),
                    screenSize: screenSize,
                  ),
                )),
        ],
      );
    }

    // ====== Vista: Semana completa ======
    const days = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo'
    ];
    final byDay = {for (final d in days) d: <ClaseHorario>[]};
    for (final s in schedules) {
      for (final d in days) {
        if (_isOnDay(s, d)) byDay[d]!.add(s);
      }
    }
    for (final d in days) {
      byDay[d]!.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderMinimal(
          title: 'Semana de $selectedGradeGroup',
          subtitle: 'Resumen por día',
          screenSize: screenSize,
        ),
        SizedBox(height: padM),
        ...days.map((d) {
          final color = _dayAccent(d);
          final list = byDay[d]!;
          return Container(
            margin: EdgeInsets.only(bottom: padM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayStrip(
                  color: color,
                  icon: _dayIcon(d),
                  label: _dayName(context, d),
                  trailing:
                      '${list.length} ${list.length == 1 ? "clase" : "clases"}',
                  screenSize: screenSize,
                ),
                SizedBox(height: padS),
                if (list.isEmpty)
                  _EmptyStrip(screenSize: screenSize)
                else
                  ...list.map((c) => Padding(
                        padding: EdgeInsets.only(bottom: padS * 0.75),
                        child: _MinimalClassRow(
                          start: _format12(c.horaInicio),
                          end: _format12(c.horaFin),
                          title: _subjectName(_getSubjectById(c.idMateria)),
                          classroom: c.aula,
                          teacher: _getTeacherName(c),
                          screenSize: screenSize,
                        ),
                      )),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Encabezado simple (sin sombras), estilo “finance card” plana
class _HeaderMinimal extends StatelessWidget {
  final String title;
  final String subtitle;
  final Size screenSize;
  final Color? color;
  final IconData? icon;

  const _HeaderMinimal({
    required this.title,
    required this.subtitle,
    required this.screenSize,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.getMediumPadding(screenSize);
    final rad = AppTheme.getLargeRadius(screenSize);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              child: Icon(icon,
                  color: color ?? AppTheme.accentBlue,
                  size: screenSize.width * 0.05),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.25),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
}

/// Tira de día: color sutil, sin sombras, con contador a la derecha
class _DayStrip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String trailing;
  final Size screenSize;

  const _DayStrip({
    required this.color,
    required this.icon,
    required this.label,
    required this.trailing,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final rad = AppTheme.getSmallRadius(screenSize);
    final padH = AppTheme.getMediumPadding(screenSize);
    final padV = AppTheme.getSmallPadding(screenSize);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(rad),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.30), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: screenSize.width * 0.045),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Text(
            trailing,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de clase: tiempo + título (tipo transacción), sin sombras
class _MinimalClassRow extends StatelessWidget {
  final String start;
  final String? end;
  final String title;
  final String? classroom;
  final String? teacher;
  final Size screenSize;

  const _MinimalClassRow({
    required this.start,
    required this.title,
    required this.screenSize,
    this.end,
    this.classroom,
    this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);
    final rad = AppTheme.getSmallRadius(screenSize);
    final border = AppTheme.getBorderColor(context);

    return Container(
      padding: EdgeInsets.all(padS),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila: Título y horario
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: padS),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: padS * 0.8, vertical: padS * 0.4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppTheme.accentBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(rad),
                  border: Border.all(
                      // ignore: deprecated_member_use
                      color: AppTheme.accentBlue.withOpacity(0.28),
                      width: 1),
                ),
                child: Text(
                  end == null ? start : '$start - $end',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: AppTheme.getCaption(screenSize).fontSize! * 0.9,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: padS * 0.75),

          // Segunda fila: Detalles (aula y profesor)
          Row(
            children: [
              if (classroom != null && classroom!.trim().isNotEmpty) ...[
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: padS * 0.5),
                      Expanded(
                        child: Text(
                          'Aula $classroom',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (classroom != null &&
                  classroom!.trim().isNotEmpty &&
                  teacher != null &&
                  teacher!.trim().isNotEmpty)
                SizedBox(width: padS),
              if (teacher != null && teacher!.trim().isNotEmpty) ...[
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: padS * 0.5),
                      Expanded(
                        child: Text(
                          teacher!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Estado vacío sobrio (coincide con el estilo)
class _EmptyStrip extends StatelessWidget {
  final Size screenSize;
  const _EmptyStrip({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppTheme.getTextSecondaryColor(context).withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppTheme.getTextSecondaryColor(context).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Text(
        'No hay clases programadas',
        textAlign: TextAlign.center,
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
