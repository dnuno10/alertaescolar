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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStudentSelection();
    });
  }

  // Selecciona automáticamente el primer estudiante disponible
  void _initializeStudentSelection() {
    final sp = Provider.of<StudentProvider>(context, listen: false);
    if (sp.students.isNotEmpty && _selectedStudentId == null) {
      setState(() => _selectedStudentId = sp.students.first.id);
      _loadTodaySchedule();
    } else if (sp.students.isEmpty) {
      _loadStudents();
    }
  }

  // Recarga estudiantes si no hay (espera a que el padre los cargue)
  Future<void> _loadStudents() async {
    try {
      final sp = Provider.of<StudentProvider>(context, listen: false);
      if (sp.students.isEmpty) {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(milliseconds: 500));
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
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar estudiantes: $e';
      });
    }
  }

  // Cambio de alumno seleccionado
  void _onStudentSelected(String? studentId) {
    if (studentId != _selectedStudentId) {
      setState(() => _selectedStudentId = studentId);
      _loadTodaySchedule();
    }
  }

  // Devuelve true si la clase aplica para el weekday (1=lun ... 7=dom)
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

      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);

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

      // Aseguramos catálogos mínimos
      await scheduleProvider.loadMaterias(
        escuelaId: student.escuelaId,
        context: null,
      );
      // Carga horarios del grupo específico
      await scheduleProvider.loadHorarios(
        escuelaId: student.escuelaId,
        grupoId: student.grupoId,
        context: null,
      );

      // Tomamos horarios directamente por id de grupo
      final allClasses =
          scheduleProvider.getHorariosForGroupId(student.grupoId);

      final weekday = DateTime.now().weekday;

      // Filtramos por día actual y ordenamos por hora de inicio
      final todayClasses = allClasses
          .where((c) => _isClassOnWeekday(c, weekday))
          .toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      // Deduplicado simple por (idMateria, horaInicio, horaFin)
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

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todaysSchedule,
                style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              Text(
                '${dayNames[today.weekday - 1]}, ${today.day} de ${monthNames[today.month - 1]}',
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
        if (_selectedStudentId != null)
          Container(
            margin: EdgeInsets.only(
                left: AppTheme.getSmallPadding(widget.screenSize)),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _navigateToFullSchedule(context);
              },
              icon: const Icon(Icons.calendar_view_week_rounded,
                  color: Colors.white, size: 18),
              label: Text(
                'Ver completo',
                style: AppTheme.getButton(widget.screenSize)
                    .copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(widget.screenSize)),
                ),
                elevation: 0,
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(
              left: AppTheme.getSmallPadding(widget.screenSize)),
          child: Icon(
            Icons.schedule_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  void _navigateToFullSchedule(BuildContext context) {
    final sp = Provider.of<StudentProvider>(context, listen: false);
    final student = _findStudentById(sp.students, _selectedStudentId);

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
        MaterialPageRoute(
          builder: (context) => ScheduleView(student: alumno),
        ),
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
    if (t.contains('vespertino') || t.contains('tarde'))
      return TurnoEnum.vespertino;
    if (t.contains('matutino') ||
        t.contains('mañana') ||
        t.contains('manana')) {
      return TurnoEnum.matutino;
    }
    return TurnoEnum.desconocido;
  }

  Widget _buildStudentSelector() {
    return Consumer<StudentProvider>(
      builder: (context, sp, child) {
        if (sp.students.isEmpty) {
          return Container(
            padding:
                EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: 20,
                ),
                SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
                Text(
                  'No hay estudiantes disponibles',
                  style: AppTheme.getCaption(widget.screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          );
        }

        // Si aún no hay valor, selecciona el primero
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
          backgroundColor: AppTheme.getSecondaryBackgroundColor(context)
              .withValues(alpha: 0.9),
        );
      },
    );
  }

  Widget _buildScheduleContent(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) return _buildLoadingState();
    if (_error != null) return _buildErrorState();
    if (_selectedStudentId == null) return _buildSelectStudentState();
    if (_todayClasses.isEmpty) return _buildEmptyState();
    return _buildClassesList();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(
          AppTheme.getLargeRadius(widget.screenSize),
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Text(
            _error ?? 'Error desconocido',
            style: AppTheme.getSubtitle2(widget.screenSize)
                .copyWith(color: AppTheme.errorColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _error = null);
              _loadTodaySchedule();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectStudentState() {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_search_rounded,
              size: 48, color: AppTheme.getTextSecondaryColor(context)),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Text(
            'Selecciona un estudiante para ver su horario de hoy',
            style: AppTheme.getSubtitle2(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded,
              size: 48, color: AppTheme.getTextSecondaryColor(context)),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Text(
            'No hay clases programadas para hoy (${dayNames[weekday]})',
            style: AppTheme.getSubtitle2(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          Text(
            '¡Disfruta tu día libre!',
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    return Column(
      children: _todayClasses.asMap().entries.map((entry) {
        final index = entry.key;
        final clase = entry.value;
        return _TodayClassCard(
          clase: clase,
          screenSize: widget.screenSize,
          status: _getClassStatus(clase),
          isLast: index == _todayClasses.length - 1,
        );
      }).toList(),
    );
  }
}

enum ClaseStatus { upcoming, inProgress, completed }

class _TodayClassCard extends StatelessWidget {
  final ClaseHorario clase;
  final Size screenSize;
  final ClaseStatus status;
  final bool isLast;

  const _TodayClassCard({
    required this.clase,
    required this.screenSize,
    required this.status,
    required this.isLast,
  });

  String _getStatusText() {
    switch (status) {
      case ClaseStatus.upcoming:
        return 'Próxima';
      case ClaseStatus.inProgress:
        return 'En progreso';
      case ClaseStatus.completed:
        return 'Completada';
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ClaseStatus.upcoming:
        return Icons.schedule_rounded;
      case ClaseStatus.inProgress:
        return Icons.play_circle_filled_rounded;
      case ClaseStatus.completed:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        final materia = scheduleProvider.getMateriaById(clase.idMateria);
        final cardColor = materia != null
            ? AppTheme.hexToColor(materia.color)
            : AppTheme.accentPurple;

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 350),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.getSecondaryBackgroundColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: cardColor.withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Row(
                      children: [
                        // Indicador de horas
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(12),
                            border: status == ClaseStatus.inProgress
                                ? Border.all(color: cardColor, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                TimeFormat.format24to12(clase.horaInicio),
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: cardColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Container(
                                width: 15,
                                height: 1,
                                color: cardColor.withValues(alpha: 0.5),
                                margin: const EdgeInsets.symmetric(vertical: 1),
                              ),
                              Text(
                                TimeFormat.format24to12(clase.horaFin),
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: cardColor.withValues(alpha: 0.8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.getMediumPadding(screenSize),
                          width: AppTheme.getMediumPadding(screenSize),
                        ),
                        // Detalles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      materia?.nombre ?? 'Materia',
                                      style: AppTheme.getSubtitle2(screenSize)
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                      ),
                                    ),
                                  ),
                                  // Badge de estado
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardColor.withValues(alpha: 0.13),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(),
                                          size: 12,
                                          color: cardColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getStatusText(),
                                          style: AppTheme.getCaption(screenSize)
                                              .copyWith(
                                            color: cardColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (materia?.profesor.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 14,
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      materia!.profesor,
                                      style: AppTheme.getCaption(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (clase.aula.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.room_outlined,
                                      size: 14,
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Aula ${clase.aula}',
                                      style: AppTheme.getCaption(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
