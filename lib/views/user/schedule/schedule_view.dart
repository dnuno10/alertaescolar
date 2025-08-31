import 'package:alertaescolar/components/admin/students/class_card_schedule.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/schedule/schedule_student_card.dart';
import 'package:alertaescolar/components/schedule/day_selector.dart';
import 'package:alertaescolar/components/schedule/schedule_loading_state.dart';
import 'package:alertaescolar/components/schedule/schedule_empty_state.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../app/app_theme.dart';

class ScheduleView extends StatefulWidget {
  final Alumno student;

  const ScheduleView({
    super.key,
    required this.student,
  });

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  /// Mapa de horarios por clave de día: 'lunes'..'domingo'
  Map<String, List<ClaseHorario>> _scheduleByDay = {
    for (final d in _orderedDays) d: <ClaseHorario>[],
  };

  bool _isLoading = true;
  int _selectedDayIndex = 0;
  String? _errorMessage;

  // Orden fijo de días
  static const List<String> _orderedDays = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  @override
  void initState() {
    super.initState();

    // Día actual por defecto (0=lunes .. 6=domingo)
    _selectedDayIndex = _getCurrentDayIndex();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });

    _animationController.forward();
  }

  /// 0=lunes .. 6=domingo
  int _getCurrentDayIndex() => DateTime.now().weekday - 1;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);

      // Cargar materias (sin dialog)
      await scheduleProvider.loadMaterias(
        escuelaId: widget.student.idEscuela,
        context: null,
      );

      // Cargar horarios del grupo del alumno (sin dialog)
      await scheduleProvider.loadHorarios(
        escuelaId: widget.student.idEscuela,
        grupoId: widget.student.idGrupo,
        context: null,
      );

      // Obtener datos del grupo (objeto Grupo)
      final grupo = scheduleProvider.getGrupoById(widget.student.idGrupo);
      final grupoName = grupo?.grupo ?? '';

      if (!mounted) return;

      if (grupoName.isEmpty) {
        setState(() {
          _scheduleByDay = {
            for (final d in _orderedDays) d: <ClaseHorario>[],
          };
          _isLoading = false;
          _errorMessage = 'No se encontró información del grupo del estudiante';
        });
        return;
      }

      // Horarios del grupo por NOMBRE (helper del provider)
      final horarios = scheduleProvider.getHorariosForGroupName(grupoName);

      // Organizar por día
      final organized = _organizeScheduleByDay(horarios);

      setState(() {
        _scheduleByDay = organized;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el horario: $e';
      });
    }
  }

  /// Devuelve mapa { 'lunes': [...], ... } ordenado por horaInicio
  Map<String, List<ClaseHorario>> _organizeScheduleByDay(
      List<ClaseHorario> horarios) {
    final byDay = {
      for (final d in _orderedDays) d: <ClaseHorario>[],
    };

    bool _isOnDay(ClaseHorario s, String dayKey) {
      switch (dayKey) {
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

    for (final s in horarios) {
      for (final d in _orderedDays) {
        if (_isOnDay(s, d)) byDay[d]!.add(s);
      }
    }

    // Ordenar por hora de inicio (HH:MM)
    for (final d in _orderedDays) {
      byDay[d]!.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }

    return byDay;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.weeklySchedule),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    ScheduleStudentCard(
                      student: widget.student,
                      screenSize: screenSize,
                    ),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    if (!_isLoading)
                      DaySelector(
                        selectedDayIndex: _selectedDayIndex,
                        onDaySelected: (index) {
                          setState(() {
                            _selectedDayIndex = index;
                          });
                        },
                        screenSize: screenSize,
                      ),
                  ],
                ),
              ),
              if (_isLoading)
                SliverToBoxAdapter(
                  child: ScheduleLoadingState(screenSize: screenSize),
                )
              else if (_errorMessage != null)
                SliverToBoxAdapter(
                  child: _buildErrorState(context, screenSize),
                )
              else
                _buildScheduleContent(context, l10n, screenSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            _errorMessage ?? 'Error desconocido',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ElevatedButton(
            onPressed: _loadSchedule,
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

  SliverPadding _buildScheduleContent(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    final selectedDayKey = _orderedDays[_selectedDayIndex];
    final daySchedule =
        _scheduleByDay[selectedDayKey] ?? const <ClaseHorario>[];

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppTheme.getMediumPadding(screenSize),
        right: AppTheme.getMediumPadding(screenSize),
        bottom: AppTheme.getMediumPadding(screenSize),
      ),
      sliver: daySchedule.isEmpty
          ? SliverToBoxAdapter(
              child: ScheduleEmptyState(
                // Si tu widget acepta otra cosa, ajusta aquí.
                dayKey: selectedDayKey,
                screenSize: screenSize,
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final clase = daySchedule[index];
                  return Consumer<ScheduleProvider>(
                    builder: (context, scheduleProvider, child) {
                      // OJO: el modelo usa idMateria
                      final materia =
                          scheduleProvider.getMateriaById(clase.idMateria);

                      return ClassCardSchedule(
                        clase: clase,
                        materia: materia,
                        index: index,
                        screenSize: screenSize,
                      );
                    },
                  );
                },
                childCount: daySchedule.length,
              ),
            ),
    );
  }
}
