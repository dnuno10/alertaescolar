import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../managers/student_provider.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/students/student_profile_card.dart';
import '../../../components/students/student_academic_info_card.dart';
import '../../../components/students/student_key_info_card.dart';
import '../../../components/admin/students/student_family_info_card.dart';
import '../../../components/admin/students/student_attendance_history_card.dart';
import '../../../utils/student_color_selector.dart';

class StudentProfileAdminView extends StatefulWidget {
  final StudentDetails student;

  const StudentProfileAdminView({super.key, required this.student});

  @override
  State<StudentProfileAdminView> createState() =>
      _StudentProfileAdminViewState();
}

class _StudentProfileAdminViewState extends State<StudentProfileAdminView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar mostrar el dialog durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentData();
    });
  }

  Future<void> _loadStudentData() async {
    if (!mounted) return;

    try {
      final sp = context.read<StudentProvider>();
      sp.setSelectedStudent(widget.student);

      // Cargar los datos completos del estudiante
      await sp.loadStudentById(studentId: widget.student.id);

      // Esperar un momento adicional para asegurar que los datos se carguen
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Error loading student data: $e');
    } finally {
      // Ocultar loading dialog
      if (mounted) {
        LoadingDialog.hide(context);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, StudentProvider>(
      builder: (context, themeProvider, sp, child) {
        // Si está cargando, mostrar un scaffold básico
        if (_isLoading) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: CustomScrollView(
              slivers: [
                NavHeader(
                  title: (widget.student.nombre.trim().isNotEmpty)
                      ? widget.student.nombre.trim()
                      : l10n?.studentProfile ?? 'Perfil del Estudiante',
                ),
                const SliverToBoxAdapter(
                  child: SizedBox.shrink(), // Contenido vacío mientras carga
                ),
              ],
            ),
          );
        }

        // Usa el del provider si ya llegó; si no, el pasado por parámetro
        final effective = (sp.selectedStudent?.id == widget.student.id)
            ? sp.selectedStudent!
            : widget.student;
        final color = StudentColorSelector.getStudentColor(effective);

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(
                title: (effective.nombre.trim().isNotEmpty)
                    ? effective.nombre.trim()
                    : l10n?.studentProfile ?? 'Perfil del Estudiante',
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StudentProfileCard(
                        student: effective,
                        color: color,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      StudentAcademicInfoCard(
                        student: effective,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      StudentKeyInfoCard(
                        student: effective,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      StudentFamilyInfoCard(
                        student: effective,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      StudentAttendanceHistoryCard(
                        student: effective,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
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
}
