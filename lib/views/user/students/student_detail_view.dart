import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/components/tips_cards/student_edit_info_card.dart';
import 'package:alertaescolar/components/students/student_profile_card.dart';
import 'package:alertaescolar/components/students/student_academic_info_card.dart';
import 'package:alertaescolar/components/students/student_key_info_card.dart';
import 'package:alertaescolar/components/students/student_action_buttons.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/school_provider.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../app/app_theme.dart';
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
  Escuela? _schoolData;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    if (!mounted) return;

    // Defer the LoadingDialog.show call to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LoadingDialog.show(context,
            message: 'Cargando detalles del estudiante...');
      }
    });

    try {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final schoolProvider =
          Provider.of<SchoolProvider>(context, listen: false);

      await studentProvider.loadStudentById(studentId: widget.student.id ?? '');

      if (mounted) {
        final studentDetails = studentProvider.selectedStudent ??
            _convertToStudentDetails(widget.student);

        // Cargar datos de la escuela usando el escuelaId del estudiante
        if (studentDetails.escuelaId.isNotEmpty) {
          final schoolData = await schoolProvider.getSchoolById(
              studentDetails.escuelaId, context);

          if (mounted) {
            setState(() {
              _studentDetails = studentDetails;
              _schoolData = schoolData;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _studentDetails = studentDetails;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _studentDetails = _convertToStudentDetails(widget.student);
        });
      }
    } finally {
      if (mounted) {
        LoadingDialog.hide(context);
      }
    }
  }

  // Convert Alumno to StudentDetails as fallback
  StudentDetails _convertToStudentDetails(Alumno alumno) {
    return StudentDetails(
      id: alumno.id ?? '',
      nombre: alumno.nombre,
      matricula: alumno.matricula ?? '',
      escuelaId: alumno.id_escuela ?? '',
      grupoId: alumno.id_grupo ?? '',
      grupo: alumno.grupo ?? '',
      nivelEducativo: '',
      turnoId: null,
      turno: alumno.turno.toString().split('.').last,
      llaveId: alumno.id_llave,
      llaveCodigo: null,
      llaveActiva: alumno.vinculado,
      fechaRegistro: alumno.fecha_registro ?? DateTime.now(),
      fechaRegistroLlave: null,
      limiteVinculacion: null,
      tutores: [],
      familyContacts: [],
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchoolInfoView(school: _schoolData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          NavHeader(title: widget.student.nombre),
          SliverToBoxAdapter(
            child: _isLoading
                ? Container() // Empty container while loading dialog is shown
                : _buildContent(context, l10n, screenSize),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    if (_studentDetails == null) {
      return _buildErrorState(l10n, screenSize);
    }

    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          // Student Profile Card
          StudentProfileCard(
            color: AppTheme.accentBlue,
            student: _studentDetails!,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Navigation Buttons
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
                onPressed: _navigateToSchoolInfo,
                backgroundColor: AppTheme.accentBlue,
                icon: Icons.school_rounded,
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Academic Information
          StudentAcademicInfoCard(
            student: _studentDetails!,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Key Information
          StudentKeyInfoCard(
            student: _studentDetails!,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Action Buttons (if needed for admin functions)
          if (_studentDetails!.tutores.isNotEmpty)
            StudentActionButtons(
              student: _studentDetails!,
              screenSize: screenSize,
            ),
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
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
            style: AppTheme.getBodyLarge(screenSize).copyWith(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          SolidButton(
            label: 'Reintentar',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadStudentDetails();
            },
            fontColor: AppTheme.getOnPrimaryColor(context),
            icon: Icons.refresh,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }
}
