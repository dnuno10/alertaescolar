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
  Map<DiaSemana, List<ClaseHorario>> _schedule = {};
  bool _isLoading = true;
  int _selectedDayIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Set the current day of the week as the default selected day
    _selectedDayIndex = _getCurrentDayIndex();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Use post frame callback to avoid build issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });

    _animationController.forward();
  }

  /// Gets the current day of the week index (0 = Monday, 6 = Sunday)
  /// Maps DateTime.weekday (1 = Monday, 7 = Sunday) to DiaSemana enum index
  int _getCurrentDayIndex() {
    final now = DateTime.now();
    // DateTime.weekday: Monday = 1, Sunday = 7
    // DiaSemana enum: lunes = 0, domingo = 6
    return now.weekday - 1; // Convert to 0-based index
  }

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

      // Load materias without showing loading dialog
      await scheduleProvider.loadMaterias(
        escuelaId: widget.student.id_escuela,
        context: null, // Don't show loading dialog
      );

      // Load schedules without showing loading dialog
      await scheduleProvider.loadHorarios(
        escuelaId: widget.student.id_escuela,
        grupoId: widget.student.id_grupo,
        context: null, // Don't show loading dialog
      );

      // Get the group name to access the schedule
      final grupo =
          await scheduleProvider.getGrupoById(widget.student.id_grupo);
      final grupoName = grupo?['grupo'] ?? '';

      if (mounted) {
        if (grupoName.isNotEmpty) {
          final horarios = scheduleProvider.getHorariosForGroup(grupoName);

          // Organize schedule by day
          final organizedSchedule = _organizeScheduleByDay(horarios);

          setState(() {
            _schedule = organizedSchedule;
            _isLoading = false;
          });
        } else {
          setState(() {
            _schedule = {};
            _isLoading = false;
            _errorMessage =
                'No se encontró información del grupo del estudiante';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar el horario: $e';
        });
      }
    }
  }

  Map<DiaSemana, List<ClaseHorario>> _organizeScheduleByDay(
      List<ClaseHorario> horarios) {
    final Map<DiaSemana, List<ClaseHorario>> organizedSchedule = {};

    // Initialize all days with empty lists
    for (final dia in DiaSemana.values) {
      organizedSchedule[dia] = [];
    }

    // Group schedules by day
    for (final horario in horarios) {
      organizedSchedule[horario.dia]?.add(horario);
    }

    // Sort each day's schedule by start time
    for (final dia in DiaSemana.values) {
      organizedSchedule[dia]?.sort((a, b) {
        return a.horaInicio.compareTo(b.horaInicio);
      });
    }

    return organizedSchedule;
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
                    if (!_isLoading) ...[
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
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    final selectedDay = DiaSemana.values[_selectedDayIndex];
    final daySchedule = _schedule[selectedDay] ?? [];

    return SliverPadding(
      padding: EdgeInsets.only(
          left: AppTheme.getMediumPadding(screenSize),
          right: AppTheme.getMediumPadding(screenSize),
          bottom: AppTheme.getMediumPadding(screenSize)),
      sliver: daySchedule.isEmpty
          ? SliverToBoxAdapter(
              child: ScheduleEmptyState(
                day: selectedDay,
                screenSize: screenSize,
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final clase = daySchedule[index];
                  return Consumer<ScheduleProvider>(
                    builder: (context, scheduleProvider, child) {
                      // Get materia information
                      final materia =
                          scheduleProvider.getMateriaById(clase.materiaId);

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
