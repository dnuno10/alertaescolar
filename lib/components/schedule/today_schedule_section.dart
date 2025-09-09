import 'package:alertaescolar/views/user/schedule/schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/schedule_provider.dart';
import '../../managers/student_provider.dart';
import '../../models/models.dart';
import '../../utils/modern_dropdown.dart';
import '../../utils/time_format.dart';

class TodayScheduleSection extends StatefulWidget {
  final Size screenSize;

  const TodayScheduleSection({
    super.key,
    required this.screenSize,
  });

  @override
  State<TodayScheduleSection> createState() => _TodayScheduleSectionState();
}

class _TodayScheduleSectionState extends State<TodayScheduleSection> {
  bool _isLoading = false;
  List<ClaseHorario> _todayClasses = [];
  String? _error;
  String? _selectedStudentId;

  VoidCallback? _studentListener;
  VoidCallback? _scheduleListener;

  // Referencias seguras a providers
  StudentProvider? _sp;
  ScheduleProvider? _sch;

  bool _listenersAttached = false;

  DateTime _lastLoad = DateTime.fromMillisecondsSinceEpoch(0);
  static const _minReloadGap = Duration(milliseconds: 300);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final sp = Provider.of<StudentProvider>(context, listen: false);
    final sch = Provider.of<ScheduleProvider>(context, listen: false);

    final spChanged = _sp != sp;
    final schChanged = _sch != sch;

    if (spChanged || schChanged) {
      _detachProviderListeners();
      _sp = sp;
      _sch = sch;
      _attachProviderListeners();
      _initializeStudentSelection();
    }
  }

  void _attachProviderListeners() {
    if (_sp == null || _sch == null) return;

    _studentListener = () {
      if (_selectedStudentId == null && _sp!.students.isNotEmpty) {
        setState(() => _selectedStudentId = _sp!.students.first.id);
      }
      _loadTodaySchedule();
    };
    _sp!.addListener(_studentListener!);

    _scheduleListener = () {
      _loadTodaySchedule();
    };
    _sch!.addListener(_scheduleListener!);

    _listenersAttached = true;
  }

  void _detachProviderListeners() {
    if (_sp != null && _studentListener != null) {
      try {
        _sp!.removeListener(_studentListener!);
      } catch (_) {}
      _studentListener = null;
    }
    if (_sch != null && _scheduleListener != null) {
      try {
        _sch!.removeListener(_scheduleListener!);
      } catch (_) {}
      _scheduleListener = null;
    }
    _listenersAttached = false;
  }

  @override
  void dispose() {
    _detachProviderListeners();
    _sp = null;
    _sch = null;
    super.dispose();
  }

  void _initializeStudentSelection() {
    final sp = _sp;
    if (sp == null) return;

    if (sp.students.isNotEmpty && _selectedStudentId == null) {
      setState(() => _selectedStudentId = sp.students.first.id);
      _loadTodaySchedule();
    } else if (sp.students.isEmpty) {
      _loadStudents();
    }
  }

  Future<void> _loadStudents() async {
    try {
      final sp = _sp;
      if (sp == null) return;

      if (sp.students.isEmpty) {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        if (sp.students.isNotEmpty) {
          setState(() {
            _selectedStudentId = sp.students.first.id;
            _isLoading = false;
          });
          _loadTodaySchedule();
        } else {
          setState(() {
            _isLoading = false;
            _error = 'No hay estudiantes disponibles';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar estudiantes: $e';
      });
    }
  }

  void _onStudentSelected(String? studentId) {
    if (studentId != _selectedStudentId) {
      setState(() => _selectedStudentId = studentId);
      _loadTodaySchedule();
    }
  }

  bool _isClassOnWeekday(ClaseHorario c, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return c.lunes;
      case DateTime.tuesday:
        return c.martes;
      case DateTime.wednesday:
        return c.miercoles;
      case DateTime.thursday:
        return c.jueves;
      case DateTime.friday:
        return c.viernes;
      case DateTime.saturday:
        return c.sabado;
      case DateTime.sunday:
        return c.domingo;
      default:
        return false;
    }
  }

  ClaseStatus _getClassStatus(ClaseHorario clase) {
    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay.fromDateTime(now);

      final startParts = clase.horaInicio.split(':');
      final endParts = clase.horaFin.split(':');

      final startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      final endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );

      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;

      if (currentMinutes < startMinutes) return ClaseStatus.upcoming;
      if (currentMinutes <= endMinutes) return ClaseStatus.inProgress;
      return ClaseStatus.completed;
    } catch (_) {
      return ClaseStatus.upcoming;
    }
  }

  StudentDetails? _findStudentById(
      List<StudentDetails> list, String? studentId) {
    if (studentId == null) return null;
    for (final s in list) {
      if (s.id == studentId) return s;
    }
    return null;
  }

  Future<void> _loadTodaySchedule() async {
    final now = DateTime.now();
    if (now.difference(_lastLoad) < _minReloadGap) return;
    _lastLoad = now;

    if (_selectedStudentId == null) {
      setState(() {
        _todayClasses = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final studentProvider = _sp;
      final scheduleProvider = _sch;
      if (studentProvider == null || scheduleProvider == null) {
        setState(() {
          _isLoading = false;
          _error = 'No hay servicios disponibles';
        });
        return;
      }

      final student =
          _findStudentById(studentProvider.students, _selectedStudentId);

      if (student == null) {
        setState(() {
          _todayClasses = [];
          _isLoading = false;
          _error = 'Estudiante no encontrado';
        });
        return;
      }

      await scheduleProvider.loadMaterias(
        escuelaId: student.escuelaId,
        context: null,
      );
      await scheduleProvider.loadHorarios(
        escuelaId: student.escuelaId,
        grupoId: student.grupoId,
        context: null,
      );

      final allClasses =
          scheduleProvider.getHorariosForGroupId(student.grupoId);
      final weekday = DateTime.now().weekday;

      final todayClasses = allClasses
          .where((c) => _isClassOnWeekday(c, weekday))
          .toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      // Elimina duplicados por materia+inicio+fin
      final map = <String, ClaseHorario>{};
      for (final c in todayClasses) {
        map['${c.idMateria}_${c.horaInicio}_${c.horaFin}'] = c;
      }

      if (!mounted) return;
      setState(() {
        _todayClasses = map.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar el horario: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, l10n),
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
        _buildStudentSelector(),
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
        _buildScheduleContent(context, l10n),
      ],
    );
  }

  // =======================
  // Encabezado minimalista
  // =======================
  Widget _buildSectionHeader(BuildContext context, AppLocalizations l10n) {
    final today = DateTime.now();
    const dayNames = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return _HeaderMinimal(
      title: l10n.todaysSchedule,
      subtitle:
          '${dayNames[today.weekday - 1]}, ${today.day} de ${monthNames[today.month - 1]}',
      screenSize: widget.screenSize,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedStudentId != null)
            TextButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _navigateToFullSchedule(context);
              },
              icon: const Icon(Icons.calendar_view_week_rounded, size: 18),
              label: Text(
                'Ver completo',
                style: AppTheme.getCaption(widget.screenSize),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(widget.screenSize),
                  vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.6,
                ),
                foregroundColor: AppTheme.accentBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(widget.screenSize)),
                  side: BorderSide(
                    color: AppTheme.accentBlue.withOpacity(0.45),
                    width: 1,
                  ),
                ),
              ),
            ),
          SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
          Icon(
            Icons.schedule_rounded,
            color: AppTheme.primaryColor,
            size: 22,
          ),
        ],
      ),
    );
  }

  void _navigateToFullSchedule(BuildContext context) {
    final sp = _sp;
    final student =
        _findStudentById(sp?.students ?? const [], _selectedStudentId);

    if (student != null) {
      final alumno = Alumno(
        id: student.id,
        nombre: student.nombre,
        idGrupo: student.grupoId,
        grupo: student.grupo,
        idEscuela: student.escuelaId,
        matricula: student.matricula,
        fechaRegistro: student.fechaRegistro,
        idTurno: student.turnoId ?? '',
        turno: _mapStringToTurnoEnum(student.turno),
        idLlave: student.llaveId,
        vinculado: student.llaveActiva,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScheduleView(student: alumno)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error: No se pudo encontrar la información del estudiante',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppTheme.getMediumRadius(widget.screenSize)),
          ),
        ),
      );
    }
  }

  TurnoEnum _mapStringToTurnoEnum(String? turno) {
    if (turno == null) return TurnoEnum.desconocido;
    final t = turno.toLowerCase();
    if (t.contains('vespertino') || t.contains('tarde')) {
      return TurnoEnum.vespertino;
    }
    if (t.contains('matutino') ||
        t.contains('mañana') ||
        t.contains('manana')) {
      return TurnoEnum.matutino;
    }
    return TurnoEnum.desconocido;
  }

  // =======================
  // Selectores y contenido
  // =======================
  Widget _buildStudentSelector() {
    return Consumer<StudentProvider>(
      builder: (context, sp, child) {
        if (sp.students.isEmpty) {
          return _InfoStrip(
            icon: Icons.info_outline,
            message: 'No hay estudiantes disponibles',
            screenSize: widget.screenSize,
          );
        }

        final currentValue = _selectedStudentId ??
            (sp.students.isNotEmpty ? sp.students.first.id : '');

        return ModernDropdown<String>(
          value: currentValue,
          items: sp.students.map((s) => s.id).toList(),
          onChanged: (value) {
            if (value != null) _onStudentSelected(value);
          },
          getLabel: (id) {
            final s = _findStudentById(sp.students, id);
            return s?.nombre ?? '';
          },
          screenSize: widget.screenSize,
          backgroundColor:
              AppTheme.getSecondaryBackgroundColor(context).withOpacity(0.9),
        );
      },
    );
  }

  Widget _buildScheduleContent(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return _LoadingPlaceholder(screenSize: widget.screenSize);
    }
    if (_error != null) {
      return _ErrorBlock(
        message: _error!,
        onRetry: () {
          HapticFeedback.mediumImpact();
          setState(() => _error = null);
          _loadTodaySchedule();
        },
        screenSize: widget.screenSize,
      );
    }
    if (_selectedStudentId == null) {
      return _InfoStrip(
        icon: Icons.person_search_rounded,
        message: 'Selecciona un estudiante para ver su horario de hoy',
        screenSize: widget.screenSize,
      );
    }
    if (_todayClasses.isEmpty) {
      final weekday = DateTime.now().weekday;
      const dayNames = {
        DateTime.monday: 'Lunes',
        DateTime.tuesday: 'Martes',
        DateTime.wednesday: 'Miércoles',
        DateTime.thursday: 'Jueves',
        DateTime.friday: 'Viernes',
        DateTime.saturday: 'Sábado',
        DateTime.sunday: 'Domingo',
      };
      return _EmptyStrip(
        screenSize: widget.screenSize,
        text: 'No hay clases programadas para hoy (${dayNames[weekday]})',
        subtext: '¡Disfruta tu día libre!',
      );
    }

    // Lista de clases de hoy con el mismo estilo minimalista
    return Column(
      children: _todayClasses.asMap().entries.map((entry) {
        final index = entry.key;
        final clase = entry.value;
        final status = _getClassStatus(clase);

        return Consumer<ScheduleProvider>(
          key: ValueKey('today_row_$index'),
          builder: (context, scheduleProvider, child) {
            final materia = scheduleProvider.getMateriaById(clase.idMateria);

            return Padding(
              padding: EdgeInsets.only(
                bottom: AppTheme.getSmallPadding(widget.screenSize),
              ),
              child: _ClassRowToday(
                title: (materia?.nombre ?? 'Materia').trim().isEmpty
                    ? 'Materia'
                    : (materia!.nombre),
                teacher: (materia?.profesor ?? '').trim(),
                classroom: clase.aula.trim(),
                start: TimeFormat.format24to12(clase.horaInicio),
                end: TimeFormat.format24to12(clase.horaFin),
                status: status,
                screenSize: widget.screenSize,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// =========================
// Tipos y widgets internos
// =========================

enum ClaseStatus { upcoming, inProgress, completed }

class _HeaderMinimal extends StatelessWidget {
  final String title;
  final String subtitle;
  final Size screenSize;
  final Widget? trailing;

  const _HeaderMinimal({
    required this.title,
    required this.subtitle,
    required this.screenSize,
    this.trailing,
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
          if (trailing != null) ...[
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Fila minimalista para “hoy”, consistente con ScheduleManagement:
/// - Sin sombras, borde sutil
/// - Chip horario (AM/PM) a la derecha
/// - Etiqueta de estado pequeña (Próxima/En progreso/Completada)
class _ClassRowToday extends StatelessWidget {
  final String title;
  final String teacher;
  final String classroom;
  final String start;
  final String end;
  final ClaseStatus status;
  final Size screenSize;

  const _ClassRowToday({
    required this.title,
    required this.teacher,
    required this.classroom,
    required this.start,
    required this.end,
    required this.status,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);
    final rad = AppTheme.getSmallRadius(screenSize);
    final border = AppTheme.getBorderColor(context);

    final statusData = _statusStyle(context, status);

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
          // Primera línea: título + chips (estado y horario)
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'Materia' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: padS * 0.5),
              // Estado
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: padS * 0.7, vertical: 4),
                decoration: BoxDecoration(
                  color: statusData.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(rad),
                  border: Border.all(
                    color: statusData.color.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusData.icon, size: 12, color: statusData.color),
                    SizedBox(width: 4),
                    Text(
                      statusData.text,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: statusData.color,
                        fontWeight: FontWeight.w700,
                        fontSize:
                            AppTheme.getCaption(screenSize).fontSize! * 0.9,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: padS * 0.5),
              // Horario
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: padS * 0.8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(rad),
                  border: Border.all(
                    color: AppTheme.accentBlue.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$start - $end',
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

          // Segunda línea: aula / profesor (opcionales)
          Row(
            children: [
              if (classroom.isNotEmpty) ...[
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
              if (classroom.isNotEmpty && teacher.isNotEmpty)
                SizedBox(width: padS),
              if (teacher.isNotEmpty) ...[
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
                          teacher,
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

  _StatusView _statusStyle(BuildContext context, ClaseStatus s) {
    switch (s) {
      case ClaseStatus.inProgress:
        return _StatusView(
          text: 'En progreso',
          icon: Icons.play_circle_fill_rounded,
          color: AppTheme.successColor,
        );
      case ClaseStatus.completed:
        return _StatusView(
          text: 'Completada',
          icon: Icons.check_circle_rounded,
          color: AppTheme.getTextSecondaryColor(context),
        );
      case ClaseStatus.upcoming:
      default:
        return _StatusView(
          text: 'Próxima',
          icon: Icons.schedule_rounded,
          color: AppTheme.accentBlue,
        );
    }
  }
}

class _StatusView {
  final String text;
  final IconData icon;
  final Color color;
  _StatusView({required this.text, required this.icon, required this.color});
}

/// Estado vacío sobrio y consistente
class _EmptyStrip extends StatelessWidget {
  final Size screenSize;
  final String text;
  final String? subtext;

  const _EmptyStrip({
    super.key,
    required this.screenSize,
    required this.text,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getTextSecondaryColor(context).withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getTextSecondaryColor(context).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtext != null) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
            Text(
              subtext!,
              textAlign: TextAlign.center,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info strip reutilizable (sin sombras)
class _InfoStrip extends StatelessWidget {
  final IconData icon;
  final String message;
  final Size screenSize;

  const _InfoStrip({
    super.key,
    required this.icon,
    required this.message,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.getMediumPadding(screenSize);
    final rad = AppTheme.getMediumRadius(screenSize);
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.getTextSecondaryColor(context)),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              message,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder de carga sobrio (sin sombras ni diálogos)
class _LoadingPlaceholder extends StatelessWidget {
  final Size screenSize;
  const _LoadingPlaceholder({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenSize.height * 0.22,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
    );
  }
}

/// Bloque de error con botón de reintento (coherente con estilo)
class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Size screenSize;

  const _ErrorBlock({
    super.key,
    required this.message,
    required this.onRetry,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: screenSize.width * 0.12, color: AppTheme.errorColor),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'No se pudo cargar el horario',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize) * 0.8,
              ),
              foregroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
                side: BorderSide(
                    color: AppTheme.accentBlue.withOpacity(0.5), width: 1),
              ),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
