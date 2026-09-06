// lib/views/students/student_detail_view.dart
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'package:alertaescolar/app/app_theme.dart';
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
      body: LiquidPullToRefresh(
        color: AppTheme.accentPurple,
        backgroundColor: AppTheme.getBackgroundColor(context),
        height: 120,
        animSpeedFactor: 9.0,
        showChildOpacityTransition: false,
        onRefresh: _onPullToRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildStudentHeader(context, screenSize),
            SliverToBoxAdapter(
              child: _isLoading
                  ? const SizedBox.shrink()
                  : _buildContent(context, l10n, screenSize, escuela),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentHeader(BuildContext context, Size screenSize) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getSmallPadding(screenSize),
                horizontal: AppTheme.getMediumPadding(screenSize),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: screenSize.height * 0.022,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Flexible(
                    child: Text(
                      'Desliza hacia abajo para actualizar',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppTheme.getMediumPadding(screenSize),
              AppTheme.getSmallPadding(screenSize),
              AppTheme.getMediumPadding(screenSize),
              AppTheme.getMediumPadding(screenSize),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Regresar',
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.accentPurple,
                    size: screenSize.width * 0.055,
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.maybePop(context);
                  },
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    widget.student.nombre,
                    maxLines: 2,
                    softWrap: true,
                    style: AppTheme.getH2(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
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

  Future<void> _onPullToRefresh() async {
    setState(() => _isLoading = true);
    await _loadStudentDetails();
  }
}
