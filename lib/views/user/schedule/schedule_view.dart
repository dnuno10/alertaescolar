// lib/views/schedule/schedule_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/schedule/schedule_student_card.dart';
import 'package:alertaescolar/components/schedule/day_selector.dart';
import 'package:alertaescolar/components/schedule/schedule_loading_state.dart';
import 'package:alertaescolar/components/schedule/schedule_empty_state.dart';
import 'package:alertaescolar/components/admin/students/class_card_schedule.dart';

import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/managers/schedule_provider.dart';

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

  /// Mapa de horarios por día: 'lunes'..'domingo'
  Map<String, List<ClaseHorario>> _scheduleByDay = {
    for (final d in _orderedDays) d: <ClaseHorario>[],
  };

  bool _isLoading = true;

  /// Índice seleccionado en UI:
  /// 0 = Todos, 1..7 = L..D (map a _orderedDays[ index - 1 ])
  int _selectedDayIndex = 0;

  String? _errorMessage;

  // Orden fijo de días (para datos)
  static const List<String> _orderedDays = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  static const int _allIndex = 0; // “Todos”

  @override
  void initState() {
    super.initState();

    // Por solicitud: arrancar en "Todos"
    _selectedDayIndex = _allIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 240),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });

    _animationController.forward();
  }

  int _clampDayIndex(int i) => i.clamp(0, _orderedDays.length); // 0..7

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

      await scheduleProvider.loadMaterias(
        escuelaId: widget.student.idEscuela,
        context: null,
      );

      await scheduleProvider.loadGrupos(
        escuelaId: widget.student.idEscuela,
        loadAll: true,
        context: null,
      );

      await scheduleProvider.loadHorarios(
        escuelaId: widget.student.idEscuela,
        grupoId: widget.student.idGrupo,
        context: null,
      );

      if (!mounted) return;

      final horarios =
          scheduleProvider.getHorariosForGroupId(widget.student.idGrupo);

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

  /// Devuelve mapa { 'lunes': [...], ... } ordenado por horaInicio (HH:MM)
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

    for (final d in _orderedDays) {
      byDay[d]!.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }

    return byDay;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
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
                          _selectedDayIndex = _clampDayIndex(index);
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
      ),
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
    // Si es "Todos", fusionamos todos los días en orden L..D
    final isAll = _selectedDayIndex == _allIndex;

    final List<ClaseHorario> daySchedule;
    if (isAll) {
      final merged = <ClaseHorario>[];
      for (final d in _orderedDays) {
        merged.addAll(_scheduleByDay[d] ?? const <ClaseHorario>[]);
      }
      daySchedule = merged;
    } else {
      final selectedDayKey = _orderedDays[_selectedDayIndex - 1]; // 1->lunes
      daySchedule = _scheduleByDay[selectedDayKey] ?? const <ClaseHorario>[];
    }

    final isEmpty = daySchedule.isEmpty;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppTheme.getMediumPadding(screenSize),
        right: AppTheme.getMediumPadding(screenSize),
        bottom: AppTheme.getMediumPadding(screenSize),
      ),
      sliver: isEmpty
          ? SliverToBoxAdapter(
              child: ScheduleEmptyState(
                dayKey: isAll ? 'todos' : _orderedDays[_selectedDayIndex - 1],
                screenSize: screenSize,
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final clase = daySchedule[index];
                  return Consumer<ScheduleProvider>(
                    builder: (context, scheduleProvider, child) {
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
