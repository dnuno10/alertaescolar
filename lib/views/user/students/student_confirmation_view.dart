import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- NUEVO
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';

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

    final Map<String, dynamic> studentData =
        (widget.validationResult['student'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

    final Map<String, dynamic> schoolData =
        (widget.validationResult['school'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

    final Map<String, dynamic> keyData =
        (widget.validationResult['key'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

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
                        bottom: screenSize.height * 0.16, // espacio para footer
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // Title
                          Row(
                            children: [
                              // Success Icon
                              Container(
                                width: screenSize.width * 0.10,
                                height: screenSize.width * 0.10,
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.successColor,
                                  size: screenSize.width * 0.07,
                                ),
                              ),
                              SizedBox(width: AppTheme.paddingSmall),
                              Text(
                                l10n.studentToRegister,
                                style: AppTheme.getH2(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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

                          // ----------- NUEVO: Aviso y botón para enviar correo -----------
                          Container(
                            padding: EdgeInsets.all(
                                AppTheme.getMediumPadding(screenSize)),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                AppTheme.getMediumRadius(screenSize),
                              ),
                              border: Border.all(
                                color: AppTheme.warningColor.withOpacity(0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: AppTheme.warningColor,
                                      size: screenSize.height * 0.025,
                                    ),
                                    SizedBox(
                                        width: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Expanded(
                                      child: Text(
                                        'Si ves que algún dato no coincide con el alumno, '
                                        'por favor contacta al equipo de Alerta Escolar por correo.',
                                        style:
                                            AppTheme.getBodyMedium(screenSize)
                                                .copyWith(
                                          color: AppTheme.getTextPrimaryColor(
                                              context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height:
                                        AppTheme.getSmallPadding(screenSize)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton.icon(
                                    onPressed: _emailSupport,
                                    icon: const Icon(
                                      Icons.email_rounded,
                                      color: Colors.white,
                                    ),
                                    label: const Text('Enviar correo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ----------------------------------------------------------------
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
                        flex: 2,
                        child: SolidButton(
                          onPressed: _isLoading ? null : _confirmRegistration,
                          label: l10n.confirmRegistration,
                          icon: _isLoading ? null : Icons.check_rounded,
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          screenSize: screenSize,
                          isLoading: _isLoading,
                          semanticsLabel: l10n.confirmRegistration,
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

  // ----------------- Helpers UI existentes -----------------

  Widget _buildStudentInfoCard(Map<String, dynamic> studentData,
      Size screenSize, AppLocalizations l10n, BuildContext context) {
    final nombre = (studentData['nombre'] ?? '').toString().trim();
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    final nivelEducativo =
        (studentData['nivelEducativo'] ?? 'N/A').toString().trim();
    final grupo = (studentData['grupo'] ?? 'N/A').toString().trim();
    final turno = (studentData['turno'] ?? 'N/A').toString().trim();
    final horaInicioTurno = studentData['horaInicioTurno']?.toString();
    final horaFinTurno = studentData['horaFinTurno']?.toString();

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
                    inicial,
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
                      nombre.isNotEmpty ? nombre : '—',
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
          _buildInfoRow('Nivel Educativo:', nivelEducativo,
              Icons.school_rounded, AppTheme.accentPurple, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow('Grupo:', grupo, Icons.class_rounded,
              AppTheme.accentBlue, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow('Turno:', turno, Icons.schedule_rounded,
              AppTheme.successColor, screenSize, context),
          if (horaInicioTurno != null && horaFinTurno != null) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            _buildInfoRow(
              'Horario:',
              '${_formatTime(horaInicioTurno)} - ${_formatTime(horaFinTurno)}',
              Icons.access_time_rounded,
              AppTheme.warningColor,
              screenSize,
              context,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchoolInfoCard(Map<String, dynamic> schoolData, Size screenSize,
      AppLocalizations l10n, BuildContext context) {
    final nivelesEducativos =
        (schoolData['nivelesEducativos'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final nivelesActivos = <String>[];

    if (nivelesEducativos['preescolar'] == true)
      nivelesActivos.add('Preescolar');
    if (nivelesEducativos['primaria'] == true) nivelesActivos.add('Primaria');
    if (nivelesEducativos['secundaria'] == true)
      nivelesActivos.add('Secundaria');
    if (nivelesEducativos['preparatoria'] == true)
      nivelesActivos.add('Preparatoria');

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

          _buildInfoRow('Nombre:', (schoolData['nombre'] ?? '—').toString(),
              Icons.school_rounded, AppTheme.successColor, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow('Código:', (schoolData['codigo'] ?? '—').toString(),
              Icons.tag_rounded, AppTheme.accentBlue, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow(
              'Tipo:',
              _capitalizeFirst((schoolData['tipo'] ?? '—').toString()),
              Icons.category_rounded,
              AppTheme.accentPurple,
              screenSize,
              context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow(
              'Dirección:',
              (schoolData['direccion'] ?? '—').toString(),
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
    final DateTime? fechaDesactivacion = keyData['fechaDesactivacion'] != null
        ? _parseTimestamptz(keyData['fechaDesactivacion'])
        : null;

    // Si el back no manda remainingDays, lo calculamos local:
    final int? remainingDaysFromApi = keyData['remainingDays'] is int
        ? keyData['remainingDays'] as int
        : null;
    final int? remainingDaysFallback = (fechaDesactivacion != null)
        ? fechaDesactivacion.difference(DateTime.now()).inDays
        : null;
    final int? remainingDays = remainingDaysFromApi ?? remainingDaysFallback;

    final limiteVinculacion =
        (keyData['limiteVinculacion'] ?? keyData['limite_vinculacion'])
            ?.toString();

    final codigo = (keyData['codigo'] ?? '—').toString();

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

          _buildInfoRow('Código:', codigo, Icons.qr_code_rounded,
              AppTheme.warningColor, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInfoRow('Registros Restantes:', limiteVinculacion ?? '—',
              Icons.people_rounded, AppTheme.accentBlue, screenSize, context),
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
              context,
            ),
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
      DateTime time;
      if (timeString.contains('T') || timeString.contains(' ')) {
        time = DateTime.parse(timeString);
      } else {
        time = DateTime.parse('2023-01-01T$timeString');
      }
      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (e) {
      debugPrint('_formatTime: Error formatting time: $e');
      return timeString;
    }
  }

  DateTime _parseTimestamptz(dynamic timestampField) {
    try {
      if (timestampField == null) return DateTime.now();
      if (timestampField is DateTime) return timestampField;
      return DateTime.parse(timestampField.toString());
    } catch (e) {
      debugPrint('_parseTimestamptz: Error parsing timestamp: $e');
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _confirmRegistration() async {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final currentUser = userProvider.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar(l10n.userNotFound);
        return;
      }

      final keyId = widget.validationResult['key']?['id'] ??
          widget.validationResult['keyId'];
      final studentId = widget.validationResult['student']?['id'];

      // Registro con revalidación interna (el provider revalida la llave justo antes)
      final ok = await studentProvider.registerStudentWithKey(
        keyId: keyId.toString(),
        studentId: studentId.toString(),
        tutorId: currentUser.id,
      );

      if (!mounted) return;

      if (ok) {
        _showSuccessSnackBar(l10n.studentRegisteredSuccessfully);
        Navigator.of(context).pop(true);
      } else {
        final msg = studentProvider.error ?? l10n.errorRegisteringStudent;
        studentProvider.clearError();
        _showErrorSnackBar(msg);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('${l10n.errorRegisteringStudent}: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- NUEVO: abrir mailto ----------
  Future<void> _emailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'contacto@alertaescolar.mx',
      queryParameters: {
        'subject': 'Soporte - Datos de alumno no coinciden',
        'body':
            'Hola equipo de Alerta Escolar,\n\nHe detectado que algunos datos no coinciden con el alumno mostrado en la app. '
                '¿Podrían ayudarme a revisarlo por favor?\n\nGracias.',
      },
    );

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        _showErrorSnackBar('No se pudo abrir el cliente de correo.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('No se pudo abrir el cliente de correo.');
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
