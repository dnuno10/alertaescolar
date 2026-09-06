import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../managers/student_provider.dart';
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
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Evita mostrar el dialog durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentData(showDialog: true);
    });
  }

  Future<void> _loadStudentData({bool showDialog = false}) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      if (showDialog) {
        LoadingDialog.show(
          context,
          message: l10n.loading,
        );
      }

      final sp = context.read<StudentProvider>();
      sp.setSelectedStudent(widget.student);

      // Cargar datos completos del estudiante
      await sp.loadStudentById(studentId: widget.student.id);

      // Pequeño colchón para transiciones suaves
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      // Aviso sutil (sin sombras)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            // ignore: deprecated_member_use
            backgroundColor: AppTheme.errorColor.withOpacity(0.95),
            content: Text(
              (l10n.unexpectedError) + ('\n$_errorMessage'),
              style: AppTheme.getCaptionSmall(MediaQuery.of(context).size)
                  .copyWith(color: Colors.white),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      if (showDialog) LoadingDialog.hide(context);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadStudentData(showDialog: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final padM = AppTheme.getMediumPadding(screenSize);

    return Consumer2<ThemeProvider, StudentProvider>(
      builder: (context, themeProvider, sp, child) {
        // Usa el del provider si ya llegó; si no, el pasado por parámetro
        final effective = (sp.selectedStudent?.id == widget.student.id)
            ? sp.selectedStudent!
            : widget.student;

        final titleText = (effective.nombre.trim().isNotEmpty)
            ? effective.nombre.trim()
            : l10n.studentProfile;

        // ESTADO: Cargando (esqueleto + encabezado)
        if (_isLoading && !_hasError) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: LiquidPullToRefresh(
              onRefresh: _onRefresh,
              color: AppTheme.accentPurple,
              backgroundColor: AppTheme.getBackgroundColor(context),
              height: 120,
              animSpeedFactor: 9.0,
              showChildOpacityTransition: false,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _StudentPlainHeader(title: titleText, screenSize: screenSize),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(padM),
                      child: _LoadingSkeleton(screenSize: screenSize),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ESTADO: Error (mensaje + reintentar)
        if (_hasError) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _StudentPlainHeader(title: titleText, screenSize: screenSize),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(padM),
                      child: _ErrorBlock(
                        message: l10n.unexpectedError,
                        onRetry: () => _loadStudentData(showDialog: true),
                        screenSize: screenSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final color = StudentColorSelector.getStudentColor(effective);

        // ESTADO: Contenido cargado
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: LiquidPullToRefresh(
            onRefresh: _onRefresh,
            color: AppTheme.accentPurple,
            backgroundColor: AppTheme.getBackgroundColor(context),
            height: 120,
            animSpeedFactor: 9.0,
            showChildOpacityTransition: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _StudentPlainHeader(title: titleText, screenSize: screenSize),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(padM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StudentProfileCard(
                          student: effective,
                          color: color,
                          screenSize: screenSize,
                        ),
                        SizedBox(height: padM),
                        StudentAcademicInfoCard(
                          student: effective,
                          screenSize: screenSize,
                        ),
                        SizedBox(height: padM),
                        StudentKeyInfoCard(
                          student: effective,
                          screenSize: screenSize,
                        ),
                        SizedBox(height: padM),
                        StudentFamilyInfoCard(
                          student: effective,
                          screenSize: screenSize,
                        ),
                        SizedBox(height: padM),
                        StudentAttendanceHistoryCard(
                          student: effective,
                          screenSize: screenSize,
                        ),
                        SizedBox(height: padM),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentPlainHeader extends StatelessWidget {
  final String title;
  final Size screenSize;

  const _StudentPlainHeader({
    required this.title,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppTheme.getMediumPadding(screenSize),
            AppTheme.getMediumPadding(screenSize),
            AppTheme.getMediumPadding(screenSize),
            AppTheme.getSmallPadding(screenSize),
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
                  title,
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
      ),
    );
  }
}

/// ===========================
/// Bloques de carga (skeleton)
/// ===========================
class _LoadingSkeleton extends StatelessWidget {
  final Size screenSize;
  const _LoadingSkeleton({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);

    Widget box(double h) => Container(
          height: h,
          width: double.infinity,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppTheme.getCardColor(context).withOpacity(0.6),
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
            // 🚫 sin sombras
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(screenSize.height * 0.16), // perfil
        SizedBox(height: padS),
        box(screenSize.height * 0.12), // académico
        SizedBox(height: padS),
        box(screenSize.height * 0.12), // llaves
        SizedBox(height: padS),
        box(screenSize.height * 0.14), // familia
        SizedBox(height: padS),
        box(screenSize.height * 0.18), // historial asistencia
      ],
    );
  }
}

/// ===========================
/// Bloque de error + reintento
/// ===========================
class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Size screenSize;

  const _ErrorBlock({
    required this.message,
    required this.onRetry,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final padM = AppTheme.getMediumPadding(screenSize);
    final padS = AppTheme.getSmallPadding(screenSize);
    final radL = AppTheme.getLargeRadius(screenSize);

    return Container(
      padding: EdgeInsets.all(padM),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(radL),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        // 🚫 sin sombras
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: screenSize.height * 0.03,
              // ignore: deprecated_member_use
              color: AppTheme.errorColor.withOpacity(0.9)),
          SizedBox(height: padS),
          Text(
            message,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: padM),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  // ignore: deprecated_member_use
                  AppTheme.getBorderColor(context).withOpacity(0.25),
                ),
                foregroundColor: WidgetStateProperty.all(
                  AppTheme.primaryColor,
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radL),
                    side: BorderSide(
                      color: AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: padM,
                    vertical: padS,
                  ),
                ),
              ),
              onPressed: onRetry,
              child: Text(
                'Reintentar',
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
