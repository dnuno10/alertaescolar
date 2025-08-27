import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../components/loading_dialog.dart';

class StudentConfirmationView extends StatefulWidget {
  final Map<String, dynamic> validationResult;

  const StudentConfirmationView({
    super.key,
    required this.validationResult,
  });

  @override
  State<StudentConfirmationView> createState() =>
      _StudentConfirmationViewState();
}

class _StudentConfirmationViewState extends State<StudentConfirmationView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final studentData = widget.validationResult['student'];
    final schoolData = widget.validationResult['school'];
    final keyData = widget.validationResult['key'];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: Stack(
            children: [
              // Main content with scroll
              CustomScrollView(
                slivers: [
                  NavHeader(title: l10n.confirmStudentRegistration),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppTheme.getMediumPadding(screenSize),
                        right: AppTheme.getMediumPadding(screenSize),
                        bottom: MediaQuery.of(context).size.height *
                            0.16, // Space for fixed buttons
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),

                          // Success Icon
                          Container(
                            width: screenSize.width * 0.25,
                            height: screenSize.width * 0.25,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.successColor,
                              size: screenSize.width * 0.15,
                            ),
                          ),

                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),

                          // Title
                          Text(
                            l10n.studentToRegister,
                            style: AppTheme.getH2(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // Student Information Card
                          _buildStudentInfoCard(
                              studentData, screenSize, l10n, context),

                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // School Information Card
                          _buildSchoolInfoCard(
                              schoolData, screenSize, l10n, context),

                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // Key Information Card
                          _buildKeyInfoCard(keyData, screenSize, l10n, context),

                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // Confirmation message
                          Container(
                            padding: EdgeInsets.all(
                                AppTheme.getMediumPadding(screenSize)),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.getMediumRadius(screenSize),
                              ),
                              border: Border.all(
                                color: AppTheme.warningColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppTheme.warningColor,
                                  size: screenSize.height * 0.025,
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.getSmallPadding(screenSize)),
                                Expanded(
                                  child: Text(
                                    l10n.confirmRegistrationMessage,
                                    style: AppTheme.getBodyMedium(screenSize)
                                        .copyWith(
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Fixed action buttons at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: AppTheme.getMediumPadding(screenSize),
                    right: AppTheme.getMediumPadding(screenSize),
                    top: AppTheme.getMediumPadding(screenSize),
                    bottom: MediaQuery.of(context).padding.bottom +
                        AppTheme.getMediumPadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.getBorderColor(context),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getShadowColor(context),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomOutlineButton(
                          onPressed: _isLoading ? () {} : _cancelRegistration,
                          label: l10n.cancel,
                          icon: Icons.close_rounded,
                          color: AppTheme.getTextSecondaryColor(context),
                          screenSize: screenSize,
                        ),
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        flex: 2,
                        child: SolidButton(
                          onPressed: _isLoading ? () {} : _confirmRegistration,
                          label: _isLoading
                              ? l10n.registering
                              : l10n.confirmRegistration,
                          icon: _isLoading ? null : Icons.check_rounded,
                          backgroundColor: AppTheme.successColor,
                          screenSize: screenSize,
                        ),
                      ),
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

  Widget _buildStudentInfoCard(Map<String, dynamic> studentData,
      Size screenSize, AppLocalizations l10n, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Información del Estudiante',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Student Avatar and Name
          Row(
            children: [
              Container(
                width: screenSize.width * 0.15,
                height: screenSize.width * 0.15,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                ),
                child: Center(
                  child: Text(
                    studentData['nombre'][0].toUpperCase(),
                    style: AppTheme.getH2(screenSize).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentData['nombre'],
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (studentData['matricula'] != null)
                      Text(
                        'Matrícula: ${studentData['matricula']}',
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Academic Information
          _buildInfoRow('Nivel Educativo:', studentData['nivelEducativo'],
              Icons.school_rounded, AppTheme.accentPurple, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow('Grupo:', studentData['grupo'], Icons.class_rounded,
              AppTheme.accentBlue, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow('Turno:', studentData['turno'], Icons.schedule_rounded,
              AppTheme.successColor, screenSize, context),
          if (studentData['horaInicioTurno'] != null &&
              studentData['horaFinTurno'] != null) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            _buildInfoRow(
                'Horario:',
                '${_formatTime(studentData['horaInicioTurno'])} - ${_formatTime(studentData['horaFinTurno'])}',
                Icons.access_time_rounded,
                AppTheme.warningColor,
                screenSize,
                context),
          ],
        ],
      ),
    );
  }

  Widget _buildSchoolInfoCard(Map<String, dynamic> schoolData, Size screenSize,
      AppLocalizations l10n, BuildContext context) {
    final nivelesEducativos =
        schoolData['nivelesEducativos'] as Map<String, dynamic>;
    final nivelesActivos = <String>[];

    if (nivelesEducativos['preescolar'] == true) {
      nivelesActivos.add('Preescolar');
    }
    if (nivelesEducativos['primaria'] == true) nivelesActivos.add('Primaria');
    if (nivelesEducativos['secundaria'] == true) {
      nivelesActivos.add('Secundaria');
    }
    if (nivelesEducativos['preparatoria'] == true) {
      nivelesActivos.add('Preparatoria');
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.business_rounded,
                color: AppTheme.successColor,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Información de la Escuela',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          _buildInfoRow('Nombre:', schoolData['nombre'], Icons.school_rounded,
              AppTheme.successColor, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow('Código:', schoolData['codigo'], Icons.tag_rounded,
              AppTheme.accentBlue, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow(
              'Tipo:',
              _capitalizeFirst(schoolData['tipo']),
              Icons.category_rounded,
              AppTheme.accentPurple,
              screenSize,
              context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow(
              'Dirección:',
              schoolData['direccion'],
              Icons.location_on_rounded,
              AppTheme.warningColor,
              screenSize,
              context),
          if (nivelesActivos.isNotEmpty) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            _buildInfoRow(
                'Niveles Educativos:',
                nivelesActivos.join(', '),
                Icons.layers_rounded,
                AppTheme.accentPurple,
                screenSize,
                context),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyInfoCard(Map<String, dynamic> keyData, Size screenSize,
      AppLocalizations l10n, BuildContext context) {
    final fechaRegistro = _parseTimestamptz(keyData['fechaRegistro']);
    final fechaDesactivacion = keyData['fechaDesactivacion'] != null
        ? _parseTimestamptz(keyData['fechaDesactivacion'])
        : null;
    final remainingDays = keyData['remainingDays'] as int?;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.key_rounded,
                color: AppTheme.warningColor,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Información de la Llave',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          _buildInfoRow('Código:', keyData['codigo'], Icons.qr_code_rounded,
              AppTheme.warningColor, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow(
              'Registros Restantes:',
              keyData['limiteVinculacion'].toString(),
              Icons.people_rounded,
              AppTheme.accentBlue,
              screenSize,
              context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow(
              'Fecha de Registro:',
              _formatDate(fechaRegistro),
              Icons.calendar_today_rounded,
              AppTheme.successColor,
              screenSize,
              context),
          if (fechaDesactivacion != null) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            _buildInfoRow(
                'Fecha de Expiración:',
                _formatDate(fechaDesactivacion),
                Icons.event_busy_rounded,
                AppTheme.errorColor,
                screenSize,
                context),
          ],
          if (remainingDays != null) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            _buildInfoRow(
                'Días Restantes:',
                remainingDays > 0 ? '$remainingDays días' : 'Expirado',
                Icons.timelapse_rounded,
                remainingDays > 0 ? AppTheme.successColor : AppTheme.errorColor,
                screenSize,
                context),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color,
      Size screenSize, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: screenSize.height * 0.02,
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: ' $value',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return 'N/A';
    try {
      // Handle both time-only strings and full timestamps
      DateTime time;
      if (timeString.contains('T') || timeString.contains(' ')) {
        // It's a full timestamp (timestamptz format)
        time = DateTime.parse(timeString);
      } else {
        // It's a time-only string
        time = DateTime.parse('2023-01-01 $timeString');
      }
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('_formatTime: Error formatting time: $e');
      return timeString;
    }
  }

  // New method to parse timestamptz format
  DateTime _parseTimestamptz(dynamic timestampField) {
    try {
      if (timestampField is String) {
        return DateTime.parse(timestampField);
      } else if (timestampField is DateTime) {
        return timestampField;
      } else {
        return DateTime.parse(timestampField.toString());
      }
    } catch (e) {
      debugPrint('_parseTimestamptz: Error parsing timestamp: $e');
      return DateTime.now(); // Fallback to current time
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _cancelRegistration() {
    Navigator.of(context).pop();
  }

  void _confirmRegistration() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
    });

    // Show loading dialog
    LoadingDialog.show(context, message: l10n.registering);

    try {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final currentUser = userProvider.currentUser;
      if (currentUser == null) {
        throw Exception(l10n.userNotFound);
      }

      debugPrint('_confirmRegistration: Starting registration process');
      debugPrint(
          '_confirmRegistration: Key ID: ${widget.validationResult['keyId']}');
      debugPrint(
          '_confirmRegistration: Student ID: ${widget.validationResult['student']['id']}');
      debugPrint('_confirmRegistration: Tutor ID: ${currentUser.id}');

      // Check if user already has this student registered
      debugPrint(
          '_confirmRegistration: Checking if user already has this student');
      final alreadyHasStudent =
          await studentProvider.checkIfUserAlreadyHasStudent(
        studentId: widget.validationResult['student']['id'],
        tutorId: currentUser.id,
      );

      if (alreadyHasStudent) {
        debugPrint(
            '_confirmRegistration: User already has this student registered');
        // Hide loading dialog
        LoadingDialog.hide(context);
        _showErrorSnackBar('Ya tienes este estudiante registrado en tu cuenta');
        return;
      }

      debugPrint(
          '_confirmRegistration: User does not have this student, proceeding with registration');

      // Show current key state before registration
      final keyStateBefore =
          await studentProvider.getKeyState(widget.validationResult['keyId']);
      if (keyStateBefore != null) {
        debugPrint('_confirmRegistration: Key state BEFORE registration:');
        debugPrint('  - Limite: ${keyStateBefore['limite_vinculacion']}');
        debugPrint('  - Activo: ${keyStateBefore['activo']}');
      }

      final success = await studentProvider.registerStudentWithKey(
        keyId: widget.validationResult['keyId'],
        studentId: widget.validationResult['student']['id'],
        tutorId: currentUser.id,
      );

      // Show key state after registration
      final keyStateAfter =
          await studentProvider.getKeyState(widget.validationResult['keyId']);
      if (keyStateAfter != null) {
        debugPrint('_confirmRegistration: Key state AFTER registration:');
        debugPrint('  - Limite: ${keyStateAfter['limite_vinculacion']}');
        debugPrint('  - Activo: ${keyStateAfter['activo']}');
      }

      if (mounted) {
        // Hide loading dialog
        LoadingDialog.hide(context);

        if (success) {
          debugPrint('_confirmRegistration: Registration successful');
          _showSuccessSnackBar(l10n.studentRegisteredSuccessfully);

          // Navigate back to students list (pop twice to go back to students view)
          Navigator.of(context).pop(); // Close confirmation view
          Navigator.of(context).pop(); // Close add student view
        } else {
          final error = studentProvider.error ?? l10n.errorRegisteringStudent;
          debugPrint('_confirmRegistration: Registration failed: $error');
          _showErrorSnackBar(error);
        }
      }
    } catch (e) {
      debugPrint('_confirmRegistration: Exception during registration: $e');
      if (mounted) {
        // Hide loading dialog
        LoadingDialog.hide(context);
        _showErrorSnackBar('${l10n.errorRegisteringStudent}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(MediaQuery.of(context).size),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(MediaQuery.of(context).size),
          ),
        ),
      ),
    );
  }
}
