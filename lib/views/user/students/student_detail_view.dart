// lib/views/students/student_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/components/students/student_academic_info_card.dart';
import 'package:alertaescolar/components/students/student_key_info_card.dart';
import 'package:alertaescolar/components/students/student_action_buttons.dart';

import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/school_provider.dart';

import '../schedule/schedule_view.dart';
import '../school/school_info_view.dart';

class StudentDetailView extends StatefulWidget {
  final Alumno student;

  const StudentDetailView({
    super.key,
    required this.student,
  });

  @override
  State<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  bool _isLoading = true;
  StudentDetails? _studentDetails;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    if (!mounted) return;

    // Mostrar el loading fuera del ciclo de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LoadingDialog.show(context,
            message: 'Cargando detalles del estudiante...');
      }
    });

    try {
      final studentProvider = context.read<StudentProvider>();
      final schoolProvider = context.read<SchoolProvider>();

      // Cargar/refresh desde el provider de estudiantes
      await studentProvider.loadStudentById(studentId: widget.student.id);

      if (!mounted) return;

      // Fallback a partir del Alumno recibido si no hay selectedStudent
      final details = studentProvider.selectedStudent ??
          _convertToStudentDetails(widget.student);

      // Si hay escuela, cargarla en el provider correspondiente (sin dialog)
      if (details.escuelaId.isNotEmpty) {
        await schoolProvider.loadSchool(details.escuelaId, forceRefresh: false);
      }

      if (!mounted) return;
      setState(() {
        _studentDetails = details;
        _isLoading = false;
      });

      // Mostrar error de escuela si ocurrió
      final spErr = schoolProvider.error;
      if (spErr != null && spErr.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(spErr)),
        );
        schoolProvider.clearError();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _studentDetails = _convertToStudentDetails(widget.student);
      });
    } finally {
      if (mounted) LoadingDialog.hide(context);
    }
  }

  // Fallback: convierte Alumno (modelo camelCase) -> StudentDetails (del StudentProvider)
  StudentDetails _convertToStudentDetails(Alumno alumno) {
    return StudentDetails(
      id: alumno.id,
      nombre: alumno.nombre,
      matricula: alumno.matricula,
      escuelaId: alumno.idEscuela,
      grupoId: alumno.idGrupo,
      grupo: alumno.grupo,
      nivelEducativo: '', // Derívalo si lo necesitas con info del Grupo
      turnoId: alumno.idTurno,
      turno: alumno.turno.name, // 'matutino' | 'vespertino' | 'desconocido'
      llaveId: alumno.idLlave,
      llaveCodigo: null,
      llaveActiva: alumno.vinculado,
      fechaRegistro: alumno.fechaRegistro,
      fechaRegistroLlave: null,
      limiteVinculacion: null,
      tutores: const [],
      familyContacts: const [],
    );
  }

  void _navigateToSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleView(student: widget.student),
      ),
    );
  }

  void _navigateToSchoolInfo() {
    final school = context.read<SchoolProvider>().currentSchool;
    if (school == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchoolInfoView(school: school),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final escuela = context.watch<SchoolProvider>().currentSchool;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          NavHeader(title: widget.student.nombre),
          SliverToBoxAdapter(
            child: _isLoading
                ? const SizedBox
                    .shrink() // mientras se muestra el LoadingDialog
                : _buildContent(context, l10n, screenSize, escuela),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    Size screenSize,
    Escuela? school,
  ) {
    if (_studentDetails == null) {
      return _buildErrorState(l10n, screenSize);
    }

    final canOpenSchool = school != null;

    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          // Botones de navegación
          Column(
            children: [
              SolidButton(
                width: double.infinity,
                label: l10n.weeklySchedule,
                onPressed: _navigateToSchedule,
                backgroundColor: AppTheme.accentPurple,
                icon: Icons.calendar_today_rounded,
                screenSize: screenSize,
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              SolidButton(
                width: double.infinity,
                label: l10n.schoolInfo,
                onPressed: canOpenSchool ? _navigateToSchoolInfo : null,
                backgroundColor: AppTheme.accentBlue,
                icon: Icons.school_rounded,
                screenSize: screenSize,
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),

              // Acciones (si hay tutores)
              if (_studentDetails!.tutores.isNotEmpty)
                StudentActionButtons(
                  student: _studentDetails!,
                  screenSize: screenSize,
                  schoolName: school?.nombre ?? '-',
                ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Info académica
          StudentAcademicInfoCard(
            student: _studentDetails!,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Info de llave
          StudentKeyInfoCard(
            student: _studentDetails!,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Error al cargar los detalles del estudiante',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Por favor, intenta de nuevo más tarde.',
            style: AppTheme.getBodyLarge(screenSize),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          SolidButton(
            label: 'Reintentar',
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStudentDetails();
            },
            icon: Icons.refresh,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }
}
