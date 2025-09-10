// lib/components/scanner/processing_view.dart
// Versión minimalista, SIN SOMBRAS, centrada, limpia y profesional.
// Mantiene lógica original, headless/full UI y retorno detallado.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../services/scanner_service.dart';
import '../../../managers/turno_provider.dart';

enum ProcessingDisplayMode { full, headless }

class ProcessingOutcome {
  final bool success;
  final String? message;
  final Map<String, dynamic>? student;
  final Map<String, dynamic>? access;

  const ProcessingOutcome({
    required this.success,
    this.message,
    this.student,
    this.access,
  });
}

class ProcessingView extends StatefulWidget {
  final String scannedCode;
  final String adminId;
  final String escuelaId;
  final ScannerAccessType accessType;
  final bool isDefaultEntryConfig;
  final bool isExtracurricular;
  final ProcessingDisplayMode displayMode;
  final bool returnDetailedResult;

  const ProcessingView({
    super.key,
    required this.scannedCode,
    required this.adminId,
    required this.escuelaId,
    required this.accessType,
    required this.isDefaultEntryConfig,
    this.isExtracurricular = false,
    this.displayMode = ProcessingDisplayMode.full,
    this.returnDetailedResult = false,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView>
    with TickerProviderStateMixin {
  final ScannerService _scannerService = ScannerService();

  bool _isProcessing = true;
  bool _showResult = false;
  bool _isSuccess = false;
  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _accessData;
  String? _errorMessage;

  bool _processingStarted = false;
  bool _hasPopped = false;
  bool _disposed = false;
  Timer? _autoPopTimer;

  // Animations
  late final AnimationController _processingAnimationController;
  late final AnimationController _resultAnimationController;
  late final AnimationController _slideInAnimationController;
  late final Animation<double> _processingRotationAnimation;
  late final Animation<Offset> _slideInAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    Future.microtask(_startProcessingOnce);
  }

  void _initAnimations() {
    _processingAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this)
      ..repeat();

    _resultAnimationController = AnimationController(
        duration: const Duration(milliseconds: 420), vsync: this);

    _slideInAnimationController = AnimationController(
        duration: const Duration(milliseconds: 360), vsync: this);

    _processingRotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
          parent: _processingAnimationController, curve: Curves.linear),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideInAnimationController, curve: Curves.easeOutQuart));
  }

  void _startProcessingOnce() {
    if (_processingStarted) return;
    _processingStarted = true;
    _startProcessing();
  }

  String? _digForError(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      final s = data.trim();
      return s.isEmpty ? null : s;
    }
    if (data is Map) {
      const fields = [
        'error',
        'message',
        'mensaje',
        'detail',
        'descripcion',
        'razon',
        'reason'
      ];
      for (final k in fields) {
        if (data.containsKey(k)) {
          final found = _digForError(data[k]);
          if (found != null && found.isNotEmpty) return found;
        }
      }
      for (final v in data.values) {
        final found = _digForError(v);
        if (found != null && found.isNotEmpty) return found;
      }
      return null;
    }
    if (data is List) {
      for (final v in data) {
        final found = _digForError(v);
        if (found != null && found.isNotEmpty) return found;
      }
    }
    return null;
  }

  Future<void> _startProcessing() async {
    if (!mounted) return;

    try {
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
      if (turnoProvider.currentEscuelaId != widget.escuelaId) {
        await turnoProvider.loadTurnos(escuelaId: widget.escuelaId);
      }

      final result = await _scannerService.processScannedCode(
        scannedCode: widget.scannedCode,
        adminId: widget.adminId,
        escuelaIdFromContext: widget.escuelaId,
        accessType: widget.accessType,
        isDefaultEntryConfig: widget.isDefaultEntryConfig,
        isExtracurricular: widget.isExtracurricular,
        turnoProvider: turnoProvider,
      );

      if (!mounted) return;
      _processingAnimationController.stop();

      final success = result['success'] == true;
      String? message;

      if (success) {
        _studentData = result['student'] as Map<String, dynamic>?;
        _accessData = result['access'] as Map<String, dynamic>?;
        message = result['access']?['message']?.toString();
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      } else {
        String? specificError = _digForError(result);
        if ((result['noop'] == true || result['success'] == true) &&
            result['reason'] != null) {
          switch (result['reason']) {
            case 'recentDuplicate':
              specificError ??=
                  'Este alumno ya fue escaneado hace menos de 1 minuto. Espera antes de volver a escanearlo.';
              break;
            case 'hardwareRebound':
              specificError ??=
                  'Se detectó un rebote del lector. Intenta nuevamente.';
              break;
          }
        }
        if (specificError == null || specificError.isEmpty) {
          final err = (result['error']?.toString() ?? '').trim();
          if (err.isNotEmpty) specificError = err;
        }
        message = (specificError != null && specificError.isNotEmpty)
            ? specificError
            : 'No fue posible determinar la causa. Revisa el log para más detalles.';
        try {
          HapticFeedback.heavyImpact();
        } catch (_) {}
      }

      final outcome = ProcessingOutcome(
        success: success,
        message: message,
        student: _studentData,
        access: _accessData,
      );

      if (widget.displayMode == ProcessingDisplayMode.headless) {
        _return(outcome);
        return;
      }

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _showResult = true;
        _isSuccess = success;
        if (!success) _errorMessage = message;
      });

      _resultAnimationController.forward();
      _slideInAnimationController.forward();

      _autoPopTimer?.cancel();
      _autoPopTimer = Timer(Duration(milliseconds: success ? 2000 : 2000), () {
        if (mounted) _return(outcome);
      });
    } catch (e) {
      if (!mounted) return;
      _processingAnimationController.stop();

      String errorString = e.toString();
      String? clean = _digForError(errorString);
      if (clean == null || clean.isEmpty) {
        if (errorString.contains('scanner_service') ||
            errorString.contains('ScannerService')) {
          clean =
              'Error en el servicio de escáner: ${errorString.replaceAll(RegExp(r'^(Exception:|Error:)\\s*'), '')}';
        } else if (errorString.contains('supabase') ||
            errorString.contains('database') ||
            errorString.contains('PostgrestException')) {
          clean =
              'Error de conexión con la base de datos: ${errorString.replaceAll(RegExp(r'^(Exception:|Error:)\\s*'), '')}';
        } else if (errorString.contains('network') ||
            errorString.contains('connection') ||
            errorString.contains('timeout')) {
          clean =
              'Error de conexión de red: ${errorString.replaceAll(RegExp(r'^(Exception:|Error:)\\s*'), '')}';
        } else {
          clean = errorString
              .replaceAll(
                  RegExp(
                      r'^(Exception:|Error:|FormatException:|StateError:)\\s*'),
                  '')
              .trim();
        }
      }

      final outcome = ProcessingOutcome(success: false, message: clean);

      if (widget.displayMode == ProcessingDisplayMode.headless) {
        _return(outcome);
        return;
      }

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _showResult = true;
        _isSuccess = false;
        _errorMessage = outcome.message;
      });

      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
      _resultAnimationController.forward();
      _slideInAnimationController.forward();

      _autoPopTimer?.cancel();
      _autoPopTimer = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) _return(outcome);
      });
    }
  }

  void _return(ProcessingOutcome outcome) {
    if (!mounted || _hasPopped) return;
    _hasPopped = true;

    final Object navResult =
        widget.returnDetailedResult ? outcome : outcome.success;

    _autoPopTimer?.cancel();
    _autoPopTimer = null;

    try {
      _processingAnimationController.stop();
    } catch (_) {}
    try {
      _resultAnimationController.stop();
    } catch (_) {}
    try {
      _slideInAnimationController.stop();
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 40), () {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(navResult);
      }
    });
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _autoPopTimer?.cancel();

    try {
      _processingAnimationController.dispose();
    } catch (_) {}
    try {
      _resultAnimationController.dispose();
    } catch (_) {}
    try {
      _slideInAnimationController.dispose();
    } catch (_) {}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (widget.displayMode == ProcessingDisplayMode.headless) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _ProcessingBody(
          size: size,
          child: _buildProcessingContent(size),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: [
          if (_isProcessing)
            _ProcessingBody(size: size, child: _buildProcessingContent(size)),
          if (_showResult)
            _ProcessingBody(size: size, child: _buildResultContent(size)),
        ],
      ),
    );
  }

  // ========================= UI MINIMAL =========================

  Widget _buildProcessingContent(Size size) {
    final padL = AppTheme.getLargePadding(size);
    final padM = AppTheme.getMediumPadding(size);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loader circular minimal
          SizedBox(
            width: size.shortestSide * 0.18,
            height: size.shortestSide * 0.18,
            child: AnimatedBuilder(
              animation: _processingRotationAnimation,
              builder: (_, __) {
                return Transform.rotate(
                  angle: _processingRotationAnimation.value * 2 * math.pi,
                  child: CustomPaint(
                    painter: _RingPainter(
                      color: AppTheme.accentOrange,
                      strokeWidth: 3.0,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: padL),
          Text(
            'Procesando',
            style: AppTheme.getH1(size).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: padM),
          // Display del código (flat, sin sombras, un solo nivel)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padL),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.accentOrange.withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(size)),
                border: Border.all(
                    // ignore: deprecated_member_use
                    color: AppTheme.accentOrange.withOpacity(0.36),
                    width: 1),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padL, vertical: padM),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Código escaneado',
                      style: AppTheme.getCaption(size).copyWith(
                        // ignore: deprecated_member_use
                        color: AppTheme.accentOrange.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(size)),
                    SelectableText(
                      widget.scannedCode,
                      style: AppTheme.getH2(size).copyWith(
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(Size size) {
    return _isSuccess && _studentData != null
        ? _buildSuccessContent(size)
        : _buildErrorContent(size);
  }

  Widget _buildSuccessContent(Size size) {
    final padL = AppTheme.getLargePadding(size);
    final padM = AppTheme.getMediumPadding(size);
    final padS = AppTheme.getSmallPadding(size);

    final cardRadius = BorderRadius.circular(AppTheme.getLargeRadius(size));

    final timeText = _accessData != null
        ? _formatTime12h(DateTime.parse(_accessData!['time']).toLocal())
        : 'N/A';

    return FadeTransition(
      opacity: _resultAnimationController,
      child: SlideTransition(
        position: _slideInAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícono de éxito (sin sombras, sin contenedor adicional)
              Icon(Icons.check_circle_rounded,
                  size: size.shortestSide * 0.22, color: Colors.green.shade600),
              SizedBox(height: padL),
              Text(
                'Escaneo exitoso',
                style: AppTheme.getH1(size).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padL),

              // Tarjeta plana con datos del alumno y registro
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.getBackgroundColor(context),
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                  borderRadius: cardRadius,
                ),
                child: Padding(
                  padding: EdgeInsets.all(padM),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LabelValue(
                        label: 'Estudiante',
                        value: _studentData!['name'] ?? 'N/A',
                        size: size,
                        alignCenter: true,
                      ),
                      SizedBox(height: padS),
                      const _DividerThin(),
                      SizedBox(height: padS),
                      _TwoCols(
                        left: _InfoPill(
                          icon: Icons.badge_outlined,
                          label: 'Matrícula',
                          value: _studentData!['matricula'] ?? 'N/A',
                          size: size,
                          monospace: true,
                        ),
                        right: _InfoPill(
                          icon: Icons.school_outlined,
                          label: 'Grado/Grupo',
                          value: _studentData!['grupo'] ?? 'N/A',
                          size: size,
                        ),
                        size: size,
                      ),
                      SizedBox(height: padS),
                      _TwoCols(
                        left: _InfoPill(
                          icon: Icons.layers_outlined,
                          label: 'Nivel',
                          value: _studentData!['nivel'] ?? 'N/A',
                          size: size,
                        ),
                        right: _InfoPill(
                          icon: Icons.schedule_outlined,
                          label: 'Turno',
                          value: _studentData!['turno'] ?? 'N/A',
                          size: size,
                        ),
                        size: size,
                      ),
                      SizedBox(height: padS),
                      _InfoPill(
                        icon: Icons.access_time_filled,
                        label: 'Hora de registro',
                        value: timeText,
                        size: size,
                        monospace: true,
                        wide: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContent(Size size) {
    final padL = AppTheme.getLargePadding(size);
    final padM = AppTheme.getMediumPadding(size);

    return FadeTransition(
      opacity: _resultAnimationController,
      child: SlideTransition(
        position: _slideInAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: size.shortestSide * 0.22, color: Colors.red.shade600),
              SizedBox(height: padL),
              Text(
                'Error de escaneo',
                style: AppTheme.getH1(size).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padM),
              // Mensaje de error (plano)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                  borderRadius:
                      BorderRadius.circular(AppTheme.getLargeRadius(size)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padM),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18,
                              color: AppTheme.getTextSecondaryColor(context)),
                          SizedBox(width: AppTheme.getSmallPadding(size)),
                          Flexible(
                            child: Text(
                              _errorMessage ?? 'Error desconocido',
                              style: AppTheme.getBodyMedium(size).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                height: 1.35,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(size)),
                      const _DividerThin(),
                      SizedBox(height: AppTheme.getSmallPadding(size)),
                      Text(
                        'Código escaneado',
                        style: AppTheme.getCaption(size).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(size)),
                      SelectableText(
                        widget.scannedCode,
                        style: AppTheme.getBodyMedium(size).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontFamily: 'monospace',
                          letterSpacing: 0.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime12h(DateTime dt) {
    final local = dt.toLocal();
    int hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    return '$hour:$minute $period';
  }
}

// ========================= WIDGETS DE SOPORTE (planos, sin sombras) =========================

class _ProcessingBody extends StatelessWidget {
  final Size size;
  final Widget child;
  const _ProcessingBody({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    final padV = AppTheme.getLargePadding(size);
    return SafeArea(
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: padV),
          child: child,
        ),
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Size size;
  final bool alignCenter;
  const _LabelValue({
    required this.label,
    required this.value,
    required this.size,
    this.alignCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.getCaption(size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
          textAlign: alignCenter ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: AppTheme.getSmallPadding(size) * 0.5),
        Text(
          value,
          style: AppTheme.getH2(size).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
          textAlign: alignCenter ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TwoCols extends StatelessWidget {
  final Widget left;
  final Widget right;
  final Size size;
  const _TwoCols({required this.left, required this.right, required this.size});

  @override
  Widget build(BuildContext context) {
    final gap = AppTheme.getSmallPadding(size);
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: gap),
        Expanded(child: right),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Size size;
  final bool monospace;
  final bool wide;
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.size,
    this.monospace = false,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final padM = AppTheme.getMediumPadding(size);
    final padS = AppTheme.getSmallPadding(size);
    return DecoratedBox(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Theme.of(context).cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(size)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padM, vertical: padS * 1.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16, color: AppTheme.getTextSecondaryColor(context)),
                SizedBox(width: padS * 0.6),
                Flexible(
                  child: Text(
                    label,
                    style: AppTheme.getCaption(size).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: padS * 0.6),
            Text(
              value,
              style: AppTheme.getBodyMedium(size).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w700,
                letterSpacing: monospace ? 0.8 : 0.2,
                fontFamily: monospace ? 'monospace' : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerThin extends StatelessWidget {
  const _DividerThin();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: FractionallySizedBox(
        widthFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _RingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);

    final base = Paint()
      // ignore: deprecated_member_use
      ..color = color.withOpacity(0.18)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Anillo base (completo)
    canvas.drawArc(rect, 0, 2 * math.pi, false, base);
    // Arco activo (40% del círculo)
    canvas.drawArc(rect, -math.pi / 2, 0.8 * math.pi, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
