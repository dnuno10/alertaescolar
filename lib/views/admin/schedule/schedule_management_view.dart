import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../components/headers/nav_header.dart';
import '../../../models/models.dart';
import '../../../components/admin/schedule/grade_selector.dart';
import '../../../components/admin/schedule/day_filter.dart';
import '../../../components/admin/schedule/grade_selection_modal.dart';
import '../../../components/admin/schedule/schedule_display.dart';
import '../../../components/admin/schedule/contact_info_card.dart';

class ScheduleManagementView extends StatefulWidget {
  const ScheduleManagementView({super.key});

  @override
  State<ScheduleManagementView> createState() => _ScheduleManagementViewState();
}

class _ScheduleManagementViewState extends State<ScheduleManagementView> {
  String _selectedGradeGroup = '1°A';
  DiaSemana? _selectedDay;

  // Mock data
  List<Materia> _subjects = [];
  Map<String, List<ClaseHorario>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _subjects = [
      const Materia(
        id: 'mat_001',
        nombre: 'Matemáticas',
        profesor: 'Prof. María González',
        aula: 'Aula 101',
        color: '#3A86FF',
      ),
      const Materia(
        id: 'mat_002',
        nombre: 'Español',
        profesor: 'Prof. Luis Rodríguez',
        aula: 'Aula 102',
        color: '#00C896',
      ),
      const Materia(
        id: 'mat_003',
        nombre: 'Ciencias Naturales',
        profesor: 'Prof. Ana Martínez',
        aula: 'Laboratorio',
        color: '#9B5DE5',
      ),
      const Materia(
        id: 'mat_004',
        nombre: 'Historia',
        profesor: 'Prof. Carlos López',
        aula: 'Aula 103',
        color: '#FF6B35',
      ),
      const Materia(
        id: 'mat_005',
        nombre: 'Educación Física',
        profesor: 'Prof. Roberto Silva',
        aula: 'Gimnasio',
        color: '#FDCB5A',
      ),
    ];

    _generateMockSchedules();
  }

  void _generateMockSchedules() {
    // Generate schedules for different grades
    final grades = ['1°A', '1°B', '2°A', '2°B', '3°A', '3°B'];

    for (String grade in grades) {
      _schedules[grade] = [
        ClaseHorario(
          id: 'clase_${grade}_001',
          materiaId: 'mat_001',
          alumnoId: '',
          dia: DiaSemana.lunes,
          horaInicio: '07:30',
          horaFin: '08:20',
          aula: 'Aula 101',
        ),
        ClaseHorario(
          id: 'clase_${grade}_002',
          materiaId: 'mat_002',
          alumnoId: '',
          dia: DiaSemana.lunes,
          horaInicio: '08:20',
          horaFin: '09:10',
          aula: 'Aula 102',
        ),
        ClaseHorario(
          id: 'clase_${grade}_003',
          materiaId: 'mat_003',
          alumnoId: '',
          dia: DiaSemana.martes,
          horaInicio: '07:30',
          horaFin: '08:20',
          aula: 'Laboratorio',
        ),
        ClaseHorario(
          id: 'clase_${grade}_004',
          materiaId: 'mat_004',
          alumnoId: '',
          dia: DiaSemana.miercoles,
          horaInicio: '09:10',
          horaFin: '10:00',
          aula: 'Aula 103',
        ),
        ClaseHorario(
          id: 'clase_${grade}_005',
          materiaId: 'mat_005',
          alumnoId: '',
          dia: DiaSemana.jueves,
          horaInicio: '10:20',
          horaFin: '11:10',
          aula: 'Gimnasio',
        ),
        ClaseHorario(
          id: 'clase_${grade}_006',
          materiaId: 'mat_001',
          alumnoId: '',
          dia: DiaSemana.viernes,
          horaInicio: '07:30',
          horaFin: '08:20',
          aula: 'Aula 101',
        ),
      ];
    }
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
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: l10n.scheduleManagement),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header and Grade Selector
                      GradeSelector(
                        selectedGradeGroup: _selectedGradeGroup,
                        onSelectGrade: _showGradeSelector,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Day Filter
                      DayFilter(
                        selectedDay: _selectedDay,
                        onDaySelected: (day) =>
                            setState(() => _selectedDay = day),
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Schedule Display
                      ScheduleDisplay(
                        selectedGradeGroup: _selectedGradeGroup,
                        selectedDay: _selectedDay,
                        schedules: _schedules[_selectedGradeGroup] ?? [],
                        subjects: _subjects,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Contact Information Card
                      ContactInfoCard(screenSize: screenSize),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGradeSelector() {
    GradeSelectionModal.show(
      context,
      _selectedGradeGroup,
      (grade) => setState(() => _selectedGradeGroup = grade),
    );
  }
}
