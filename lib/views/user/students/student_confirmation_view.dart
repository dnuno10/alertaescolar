import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
              CustomScrollView(
                slivers: [
                  NavHeader(title: l10n.confirmStudentRegistration),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppTheme.getLargePadding(screenSize),
                        right: AppTheme.getLargePadding(screenSize),
                        bottom: screenSize.height * 0.16, // espacio footer fijo
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: screenSize.width * 0.11,
                                  color: AppTheme.successColor),
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize)),
                              Text(
                                "Verificar datos",
                                style: AppTheme.getH2(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "Confirma los datos del estudiante para registrar y activar su credencial.",
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                              height: 1.4,
                            ),
                          ),
                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // Estudiante (ligeramente ajustado)
                          _StudentSection(
                            screenSize: screenSize,
                            studentData: studentData,
                          ),

                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // Escuela (tarjeta horizontal, densa)
                          _SchoolSectionCompact(
                            screenSize: screenSize,
                            schoolData: schoolData,
                          ),

                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          // Llave (tarjeta horizontal, densa)
                          _KeySectionCompact(
                            screenSize: screenSize,
                            keyData: keyData,
                          ),

                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),

                          _SupportNotice(
                            screenSize: screenSize,
                            onTap: _emailSupport,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Acción inferior fija
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: AppTheme.getLargePadding(screenSize),
                    right: AppTheme.getLargePadding(screenSize),
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
                  ),
                  child: Row(
                    children: [
                      Expanded(
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

  // =================== LÓGICA ===================

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

      final ok = await studentProvider.registerStudentWithKey(
        keyId: keyId.toString(),
        studentId: studentId.toString(),
        tutorId: currentUser.id,
      );

      if (!mounted) return;

      if (ok) {
        _showSuccessSnackBar(l10n.studentRegisteredSuccessfully);

        // Regresar a la pantalla de "Mis estudiantes" (2 pantallas atrás)
        // Pop StudentConfirmationView -> AddStudentView -> StudentsView
        Navigator.of(context).pop(); // Cerrar StudentConfirmationView
        Navigator.of(context)
            .pop(true); // Cerrar AddStudentView y notificar a StudentsView
      } else {
        final msg = studentProvider.error ?? l10n.errorRegisteringStudent;
        studentProvider.clearError();
        _showErrorSnackBar(msg);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(
        '${AppLocalizations.of(context).errorRegisteringStudent}: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
    } catch (_) {
      if (mounted) {
        _showErrorSnackBar('No se pudo abrir el cliente de correo.');
      }
    }
  }

  // =================== HELPERS UI ===================

  void _showSuccessSnackBar(String message) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(size)
              .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(size)),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(size)
              .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(size)),
        ),
      ),
    );
  }
}

// =================== SECCIONES (UI) ===================

class _GroupedContainer extends StatelessWidget {
  const _GroupedContainer({required this.screenSize, required this.child});

  final Size screenSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = AppTheme.getLargeRadius(screenSize);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        ),
        child: child,
      ),
    );
  }
}

class _StudentSection extends StatelessWidget {
  const _StudentSection({required this.screenSize, required this.studentData});
  final Size screenSize;
  final Map<String, dynamic> studentData;

  @override
  Widget build(BuildContext context) {
    final nombre = (studentData['nombre'] ?? '').toString().trim();
    final matricula = (studentData['matricula'] ?? '—').toString().trim();
    final nivelEducativo =
        (studentData['nivelEducativo'] ?? '—').toString().trim();
    final grupo = (studentData['grupo'] ?? '—').toString().trim();
    final turno = (studentData['turno'] ?? '—').toString().trim();
    final horaInicioTurno = studentData['horaInicioTurno']?.toString();
    final horaFinTurno = studentData['horaFinTurno']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Column(
        children: [
          // Header con avatar y nombre
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                left: AppTheme.getMediumPadding(screenSize),
                right: AppTheme.getMediumPadding(screenSize),
                top: AppTheme.getMediumPadding(screenSize),
                bottom: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
                topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre.isNotEmpty ? nombre : '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.getH2(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      if (matricula.isNotEmpty && matricula != '—')
                        Text(
                          'Matrícula: $matricula',
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                // Ícono decorativo
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.width * 0.06,
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal con iconos
          Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StudentInfoRow(
                  icon: Icons.school_rounded,
                  label: 'Nivel',
                  value: nivelEducativo,
                ),
                if (grupo.isNotEmpty && grupo != '—') ...[
                  _StudentInfoRow(
                    icon: Icons.groups_rounded,
                    label: 'Grupo',
                    value: grupo,
                  ),
                ],

                SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                // Turno
                if (turno.isNotEmpty && turno != '—')
                  _StudentInfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Turno',
                    value: turno,
                  ),

                // Horario si está disponible
                if (horaInicioTurno != null && horaFinTurno != null)
                  _StudentInfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Horario de clases',
                    value:
                        '${_formatTime(horaInicioTurno)} - ${_formatTime(horaFinTurno)}',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return '—';
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
    } catch (_) {
      return timeString;
    }
  }
}

// Componente para información en fila (estilo Settings de iOS)
class _StudentInfoRow extends StatelessWidget {
  const _StudentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(size) * 0.8,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.getTextSecondaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(size)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.getCaption(size).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value.isEmpty || value == '—' ? 'No especificado' : value,
                  style: AppTheme.getBodyMedium(size).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------- Sección Escuela (compacta y en fila) --------
class _SchoolSectionCompact extends StatelessWidget {
  const _SchoolSectionCompact({
    required this.screenSize,
    required this.schoolData,
  });

  final Size screenSize;
  final Map<String, dynamic> schoolData;

  @override
  Widget build(BuildContext context) {
    final nombre = (schoolData['nombre'] ?? '—').toString().trim();
    final codigo = (schoolData['codigo'] ?? '—').toString().trim();
    final tipoRaw = (schoolData['tipo'] ?? '—').toString().trim();
    final tipo = _capitalizeFirst(tipoRaw);
    final direccion = (schoolData['direccion'] ?? '').toString().trim();
    final telefono = (schoolData['telefono'] ?? '').toString().trim();
    final email = (schoolData['email'] ?? '').toString().trim();
    final sitioWeb = (schoolData['sitio_web'] ?? '').toString().trim();
    final descripcion = (schoolData['descripcion'] ?? '').toString().trim();

    final niveles =
        (schoolData['nivelesEducativos'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

    final nivelesActivos = <String>[
      if (niveles['preescolar'] == true) 'Preescolar',
      if (niveles['primaria'] == true) 'Primaria',
      if (niveles['secundaria'] == true) 'Secundaria',
      if (niveles['preparatoria'] == true) 'Preparatoria',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la institución (hasta 3 líneas, con fade)
                  Text(
                    nombre,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    style: AppTheme.getH2(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),

                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.8),

                  // Badges: Código (neutro), Tipo (color), Niveles (badges individuales)
                  Wrap(
                    spacing: AppTheme.getSmallPadding(screenSize) * 0.6,
                    runSpacing: AppTheme.getSmallPadding(screenSize) * 0.6,
                    children: [
                      _SoftBadge(text: codigo.isEmpty ? '—' : codigo),
                      if (tipo.isNotEmpty && tipo != '—')
                        _Pill(text: tipo, color: AppTheme.successColor),
                      ...nivelesActivos.map((n) => _SoftBadge(text: n)),
                    ],
                  ),

                  // Contacto: chips clickables (sin iconos, minimal)
                  if (telefono.isNotEmpty ||
                      email.isNotEmpty ||
                      sitioWeb.isNotEmpty) ...[
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Wrap(
                      spacing: AppTheme.getSmallPadding(screenSize) * 0.6,
                      runSpacing: AppTheme.getSmallPadding(screenSize) * 0.6,
                      children: [
                        if (telefono.isNotEmpty)
                          _TapBadge(
                            text: telefono,
                            onTap: () async {
                              final uri = Uri(scheme: 'tel', path: telefono);
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            },
                          ),
                        if (email.isNotEmpty)
                          _TapBadge(
                            text: email,
                            onTap: () async {
                              final uri = Uri(scheme: 'mailto', path: email);
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            },
                          ),
                        if (sitioWeb.isNotEmpty)
                          _TapBadge(
                            text: sitioWeb,
                            onTap: () async {
                              final url = _normalizeUrl(sitioWeb);
                              final uri = Uri.parse(url);
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            },
                          ),
                      ],
                    ),
                  ],

                  // Bloques expandibles para textos largos (sin truncar información)
                  if (direccion.isNotEmpty) ...[
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 1.1),
                    _ExpandableTextBlock(
                      label: 'Dirección',
                      text: direccion,
                      collapsedLines: 2,
                    ),
                  ],
                  if (descripcion.isNotEmpty) ...[
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.8),
                    _ExpandableTextBlock(
                      label: 'Descripción',
                      text: descripcion,
                      collapsedLines: 3,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

// ---------- ÁTOMOS NUEVOS PARA LA SECCIÓN ESCUELA ----------

// Badge neutro (borde fino, sin color de fondo agresivo)
class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(size) * 0.9,
        vertical: AppTheme.getSmallPadding(size) * 0.45,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Text(
        text,
        style: AppTheme.getCaption(size).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
    );
  }
}

// Badge clicable (para teléfono, email, web)
class _TapBadge extends StatelessWidget {
  const _TapBadge({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(size) * 0.9,
            vertical: AppTheme.getSmallPadding(size) * 0.45,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppTheme.getBorderColor(context), width: 1),
          ),
          child: Text(
            text,
            style: AppTheme.getCaption(size).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              height: 1.0,
              decoration:
                  TextDecoration.underline, // sutil indicación de enlace
            ),
          ),
        ),
      ),
    );
  }
}

// Bloque expandible para textos largos (dirección/descr.)
class _ExpandableTextBlock extends StatefulWidget {
  const _ExpandableTextBlock({
    required this.label,
    required this.text,
    this.collapsedLines = 2,
  });

  final String label;
  final String text;
  final int collapsedLines;

  @override
  State<_ExpandableTextBlock> createState() => _ExpandableTextBlockState();
}

class _ExpandableTextBlockState extends State<_ExpandableTextBlock> {
  bool _expanded = false;
  bool _overflow = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detecta si el texto desborda para decidir si mostramos "Ver más"
    final size = MediaQuery.of(context).size;
    final tp = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: AppTheme.getBodyMedium(size).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
      maxLines: widget.collapsedLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);
    _overflow = tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.getCaption(size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            maxLines: widget.collapsedLines,
            overflow: TextOverflow.fade,
            softWrap: true,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          secondChild: Text(
            widget.text,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          sizeCurve: Curves.easeOutCubic,
        ),
        if (_overflow) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Text(
              _expanded ? 'Ver menos' : 'Ver más',
              style: AppTheme.getCaption(size).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Normaliza URL para abrir con url_launcher
String _normalizeUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}

// -------- Sección Llave (compacta y en fila) --------

// === REEMPLAZA SOLO ESTA CLASE Y AGREGA LOS DOS ÁTOMOS DEBAJO ===

class _KeySectionCompact extends StatelessWidget {
  const _KeySectionCompact({
    required this.screenSize,
    required this.keyData,
  });

  final Size screenSize;
  final Map<String, dynamic> keyData;

  @override
  Widget build(BuildContext context) {
    // Fechas
    final fechaRegistro = _parseTimestamptz(keyData['fechaRegistro']);
    final DateTime? fechaDesactivacion = keyData['fechaDesactivacion'] != null
        ? _parseTimestamptz(keyData['fechaDesactivacion'])
        : null;

    // Días restantes (si viene del API o calculado)
    final int? remainingDaysFromApi = keyData['remainingDays'] is int
        ? keyData['remainingDays'] as int
        : null;
    final int? remainingDaysFallback = (fechaDesactivacion != null)
        ? fechaDesactivacion.difference(DateTime.now()).inDays
        : null;
    final int? remainingDaysRaw = remainingDaysFromApi ?? remainingDaysFallback;

    // Siempre mostrarlos en verde (clamp a 0 para evitar negativos)
    final int? remainingDays = remainingDaysRaw != null
        ? (remainingDaysRaw < 0 ? 0 : remainingDaysRaw)
        : null;

    // Otros datos
    final limiteVinculacion =
        (keyData['limiteVinculacion'] ?? keyData['limite_vinculacion'])
            ?.toString();
    final codigo = (keyData['codigo'] ?? '—').toString();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label superior del código
            Text(
              'Código de la llave',
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.4),

            // Código destacado
            _CodePill(
              text: codigo,
              screenSize: screenSize,
              context: context,
            ),

            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Chips compactas (días restantes en verde + registros disponibles)
            Wrap(
              spacing: AppTheme.getSmallPadding(screenSize) * 0.6,
              runSpacing: AppTheme.getSmallPadding(screenSize) * 0.6,
              children: [
                if (remainingDays != null)
                  _Pill(
                    text: '$remainingDays días',
                    color: AppTheme.successColor, // siempre verde
                  ),
                if (limiteVinculacion != null)
                  _Pill(
                    text: 'Registros disponibles: $limiteVinculacion',
                    color: AppTheme.accentBlue,
                  ),
              ],
            ),

            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 1.2),

            // Mini datos en malla 2xN
            _TwoColWrap(
              gap: AppTheme.getSmallPadding(screenSize),
              children: [
                _InfoBlock(
                  label: 'Fecha de registro',
                  value: _formatDate(fechaRegistro),
                ),
                if (fechaDesactivacion != null)
                  _InfoBlock(
                    label: 'Fecha de expiración',
                    value: _formatDate(fechaDesactivacion),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseTimestamptz(dynamic ts) {
    try {
      if (ts == null) return DateTime.now();
      if (ts is DateTime) return ts;
      return DateTime.parse(ts.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }
}

class _CodePill extends StatelessWidget {
  const _CodePill({
    required this.text,
    required this.screenSize,
    required this.context,
  });

  final String text;
  final Size screenSize;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize) * 0.6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(this.context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.getBorderColor(this.context)),
      ),
      child: Text(
        text.isEmpty ? '—' : text,
        style: AppTheme.getH2(screenSize).copyWith(
          color: AppTheme.getTextPrimaryColor(this.context),
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.28), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }
}

class _TwoColWrap extends StatelessWidget {
  const _TwoColWrap({required this.children, required this.gap});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final tileW = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((w) => SizedBox(width: tileW, child: w))
              .toList(growable: false),
        );
      },
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final labelStyle = AppTheme.getCaption(size).copyWith(
      color: AppTheme.getTextSecondaryColor(context),
      fontWeight: FontWeight.w600,
    );
    final valueStyle = AppTheme.getBodyMedium(size).copyWith(
      color: AppTheme.getTextPrimaryColor(context),
      fontWeight: FontWeight.w700,
      height: 1.25,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: valueStyle,
        ),
      ],
    );
  }
}

class _SupportNotice extends StatelessWidget {
  const _SupportNotice({required this.screenSize, required this.onTap});
  final Size screenSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _GroupedContainer(
      screenSize: screenSize,
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Ves algún dato incorrecto?',
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
            Text(
              'Por favor, contáctanos por correo para ayudarte a revisarlo.',
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getMediumPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  'Enviar correo a soporte',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
