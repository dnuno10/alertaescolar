// physical_scanner_view.dart (SIN LOTTIE)
import 'dart:async';
import 'dart:math' as math;

import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'processing_view.dart';
import '../../../widgets/custom_snack_bar.dart';

/// Vista para lectores de QR físicos (USB/Bluetooth) que emulan teclado.
/// Versión sin Lottie: animaciones puras en Flutter (CustomPainter + Animations).
class PhysicalScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;
  final ScannerAccessType? accessType;
  final bool? isDefaultEntryConfig;
  final bool isExtracurricular; // Nuevo parámetro

  const PhysicalScannerView({
    super.key,
    required this.onCodeScanned,
    this.accessType,
    this.isDefaultEntryConfig,
    this.isExtracurricular = false,
  });

  @override
  State<PhysicalScannerView> createState() => _PhysicalScannerViewState();
}

class _PhysicalScannerViewState extends State<PhysicalScannerView>
    with TickerProviderStateMixin {
  // Estado de escucha / proceso
  bool _listening = true; // UI/animación
  bool _busy = false; // evita reentradas mientras navegamos

  // Switch: revisión del alumno (ProcessingView full vs headless)
  bool _showResultInProcessing = true;

  // Buffer de entrada
  final FocusNode _focusNode = FocusNode();
  String _buffer = '';
  DateTime? _lastKeyAt;
  Timer? _commitTimer;

  @override
  void initState() {
    super.initState();

    // Oculta el teclado del sistema en móviles
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Asegurar foco para recibir eventos del lector
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _focusNode.requestFocus();
      try {
        await context.read<UserProvider>().ensureEscuelaIdLoaded();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _commitTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // ========================
  // Helpers de UI / meta
  // ========================
  String _getAccessTypeText() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;
    final isExtracurricular = widget.isExtracurricular;
    final l10n = AppLocalizations.of(context);

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? l10n.automaticEntry : l10n.automaticExit;
      case ScannerAccessType.entry:
        return isExtracurricular ? 'Entrada extracurricular' : 'Entrada';
      case ScannerAccessType.exit:
        return isExtracurricular ? 'Salida extracurricular' : 'Salida';
    }
  }

  Color _getAccessTypeColor() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? Colors.green : Colors.red;
      case ScannerAccessType.entry:
        return Colors.green;
      case ScannerAccessType.exit:
        return Colors.red;
    }
  }

  // ========================
  // Entrada del lector (teclado)
  // ========================

  void _onKeyEvent(KeyEvent event) {
    if (!mounted || _busy) return;
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    // ESC → limpiar buffer
    if (key == LogicalKeyboardKey.escape) {
      _clearBuffer();
      return;
    }

    // Backspace → eliminar último caracter
    if (key == LogicalKeyboardKey.backspace) {
      if (_buffer.isNotEmpty) {
        _buffer = _buffer.substring(0, _buffer.length - 1);
      }
      return;
    }

    try {
      final now = DateTime.now();

      // Reinicio de buffer si hubo pausa larga (>350ms)
      if (_lastKeyAt != null &&
          now.difference(_lastKeyAt!).inMilliseconds > 350) {
        _buffer = '';
      }
      _lastKeyAt = now;

      final ch = event.character;

      // Commit explícito (Enter / NumpadEnter / Tab)
      final isCommitKey = key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter ||
          key == LogicalKeyboardKey.tab;

      if (isCommitKey || ch == '\n' || ch == '\r') {
        _commitBuffer();
        return;
      }

      // Agregar caracteres imprimibles
      if (ch != null &&
          ch.isNotEmpty &&
          ch.codeUnitAt(0) >= 32 &&
          ch.codeUnitAt(0) <= 126) {
        _buffer += ch;

        // Seguridad: si el buffer es demasiado largo → commit
        if (_buffer.length > 100) {
          _commitBuffer();
          return;
        }

        // Reprogramar commit automático por inactividad (200ms típico HID)
        _commitTimer?.cancel();
        _commitTimer = Timer(const Duration(milliseconds: 200), _commitBuffer);
      }
      // otras teclas se ignoran
    } catch (e) {
      debugPrint('Key event error: $e');
      _clearBuffer();
    }
  }

  void _clearBuffer() {
    _commitTimer?.cancel();
    _commitTimer = null;
    _buffer = '';
    _lastKeyAt = null;
  }

  void _commitBuffer() {
    _commitTimer?.cancel();
    _commitTimer = null;

    final code = _buffer.replaceAll('\r', '').replaceAll('\n', '').trim();
    _clearBuffer();
    if (code.isEmpty || code.length < 3) return;
    if (_busy) return;

    _busy = true;
    _setListening(false);
    _processScannedCode(code);
  }

  void _setListening(bool value) {
    if (!mounted) return;
    setState(() => _listening = value);

    // Recuperar foco para el siguiente escaneo
    if (value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  // ========================
  // Flujo de proceso
  // ========================

  Future<void> _processScannedCode(String code) async {
    if (!mounted) return;

    try {
      final userProvider = context.read<UserProvider>();

      // 1) Usuario autenticado
      late final Usuario admin;
      try {
        admin = userProvider.requireCurrentUser();
      } catch (_) {
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Error: Usuario no autenticado',
          isError: true,
        );
        return;
      }

      // 2) Asegurar escuelaId
      String escuelaId;
      try {
        escuelaId = await userProvider.ensureEscuelaIdOrThrow();
      } catch (_) {
        await userProvider.ensureEscuelaIdLoaded(); // intento suave
        final cached = userProvider.currentUser?.escuelaId;
        if (cached == null || cached.isEmpty) {
          if (!mounted) return;
          CustomSnackBar.show(
            context: context,
            message: 'No se pudo determinar la escuela del usuario',
            isError: true,
          );
          return;
        }
        escuelaId = cached;
      }

      // 3) Elegir modo según el switch
      final displayMode = _showResultInProcessing
          ? ProcessingDisplayMode.full
          : ProcessingDisplayMode.headless;

      final returnDetailed = !_showResultInProcessing; // si headless => true

      // 4) Navegar a ProcessingView con parámetros completos
      // ignore: use_build_context_synchronously
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingView(
            scannedCode: code,
            adminId: admin.id,
            escuelaId: escuelaId,
            accessType: widget.accessType ?? ScannerAccessType.automatic,
            isDefaultEntryConfig: widget.isDefaultEntryConfig ?? true,
            isExtracurricular: widget.isExtracurricular,
            displayMode: displayMode,
            returnDetailedResult: returnDetailed,
          ),
        ),
      );

      if (!mounted) return;

      // 5) Manejo de retorno
      if (_showResultInProcessing) {
        if (result == true ||
            (result is ProcessingOutcome && result.success == true)) {
          widget.onCodeScanned(code);
        }
        return;
      }

      if (result is ProcessingOutcome) {
        final success = result.success;
        final msg = result.message ??
            (success
                ? 'Notificación enviada correctamente.'
                : 'No se pudo registrar el escaneo.');
        CustomSnackBar.show(
          context: context,
          message: msg,
          isError: !success,
        );
        if (success) widget.onCodeScanned(code);
      } else if (result == true) {
        CustomSnackBar.show(
          context: context,
          message: 'Notificación enviada correctamente.',
        );
        widget.onCodeScanned(code);
      } else {
        CustomSnackBar.show(
          context: context,
          message: 'No se pudo registrar el escaneo (sin detalles).',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Error processing scanned code: $e');
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: '${AppLocalizations.of(context).errorProcessingCode}: $e',
        isError: true,
      );
    } finally {
      _busy = false;
      _setListening(true);
    }
  }

  // ========================
  // UI
  // ========================
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // Header
            NavHeader(title: 'Escáner físico'),

            // Main content
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
                child: Column(
                  children: [
                    // Indicador de modo (minimal)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.8,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: _getAccessTypeColor().withOpacity(0.07),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: _getAccessTypeColor().withOpacity(0.18),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getAccessTypeText(),
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: _getAccessTypeColor(),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),

                    // Área animada (sin Lottie)
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 360,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _ScannerArea(
                              listening: _listening,
                              accent: AppTheme.accentOrange,
                              background: AppTheme.getCardColor(context)
                                  // ignore: deprecated_member_use
                                  .withOpacity(.6),
                              borderRadius:
                                  BorderRadius.circular(16), // consistente
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppTheme.getLargePadding(screenSize)),

                    // Estado (tipografía > iconografía)
                    Text(
                      _listening ? 'Listo para escanear' : 'Procesando…',
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w400,
                        letterSpacing: .2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                    // Buffer visible (opcional/debug)
                    if (_buffer.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getMediumPadding(screenSize),
                          vertical: AppTheme.getSmallPadding(screenSize),
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppTheme.accentOrange.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: AppTheme.accentOrange.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _buffer,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.accentOrange,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    ],

                    // Switch "Revisión de alumno"
                    Align(
                      alignment: Alignment
                          .center, // le da constraints “flojos” al hijo
                      child: DecoratedBox(
                        // en lugar de Container para evitar que expanda
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.1),
                              width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.05,
                              vertical: screenSize.height * 0.01),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_rounded,
                                  color: AppTheme.getTextPrimaryColor(context),
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Revisión de alumno',
                                style: AppTheme.getCaption(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextPrimaryColor(context)),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: _showResultInProcessing,
                                onChanged: (v) =>
                                    setState(() => _showResultInProcessing = v),
                                activeColor: AppTheme.accentBlue,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                //visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                    // Ayuda minimal
                    Container(
                      padding:
                          EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                      decoration: BoxDecoration(
                        color: AppTheme.getTextSecondaryColor(context)
                            // ignore: deprecated_member_use
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.getTextSecondaryColor(context)
                              // ignore: deprecated_member_use
                              .withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Conecta tu lector USB/Bluetooth y escanea. El código se procesará automáticamente.',
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Caja de escaneo con borde degradado animado y línea de barrido.
/// Cuando [listening] es false, muestra un spinner minimalista.
class _ScannerArea extends StatefulWidget {
  final bool listening;
  final Color accent;
  final Color background;
  final BorderRadius borderRadius;

  const _ScannerArea({
    required this.listening,
    required this.accent,
    required this.background,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<_ScannerArea> createState() => _ScannerAreaState();
}

class _ScannerAreaState extends State<_ScannerArea>
    with TickerProviderStateMixin {
  late final AnimationController _borderCtrl;
  late final AnimationController _sweepCtrl;
  late final AnimationController _spinnerCtrl;

  @override
  void initState() {
    super.initState();
    // Borde con gradiente que "respira"
    _borderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Línea de barrido vertical
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Spinner para estado "procesando"
    _spinnerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _borderCtrl.dispose();
    _sweepCtrl.dispose();
    _spinnerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listening = widget.listening;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: widget.borderRadius,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo sutil
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.02),
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Borde animado (degradado)
            AnimatedBuilder(
              animation: _borderCtrl,
              builder: (_, __) {
                final t = _borderCtrl.value;
                final c1 = Color.lerp(widget.accent, Colors.white, .7)!;
                final c2 = Color.lerp(widget.accent, Colors.white, .35)!;
                return CustomPaint(
                  painter: _GradientBorderPainter(
                    progress: t,
                    // ignore: deprecated_member_use
                    color1: c1.withOpacity(0.7),
                    // ignore: deprecated_member_use
                    color2: c2.withOpacity(0.35),
                    strokeWidth: 1.3,
                    borderRadius: widget.borderRadius,
                  ),
                );
              },
            ),

            // Contenido según estado
            if (listening) ...[
              // Icono QR en el centro
              Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 80,
                  // ignore: deprecated_member_use
                  color: widget.accent.withOpacity(0.3),
                ),
              ),
              // Línea de barrido vertical
              AnimatedBuilder(
                animation: _sweepCtrl,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _SweepLinePainter(
                      position: _sweepCtrl.value, // 0..1
                      // ignore: deprecated_member_use
                      color: widget.accent.withOpacity(0.28),
                      // ignore: deprecated_member_use
                      glow: widget.accent.withOpacity(0.10),
                    ),
                  );
                },
              ),
              // Pista de texto
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Escanea un código con tu lector físico',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getTextPrimaryColor(context)
                              // ignore: deprecated_member_use
                              .withOpacity(.65),
                          letterSpacing: .2,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ] else ...[
              // Spinner minimalista
              Center(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: AnimatedBuilder(
                    animation: _spinnerCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _SpinnerDotsPainter(
                        turn: _spinnerCtrl.value,
                        // ignore: deprecated_member_use
                        baseColor: widget.accent.withOpacity(.20),
                        dotColor: widget.accent,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Procesando…',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(.65),
                          letterSpacing: .2,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Borde degradado que se anima alrededor del rectángulo.
class _GradientBorderPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color1;
  final Color color2;
  final double strokeWidth;
  final BorderRadius borderRadius;

  _GradientBorderPainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      transform: GradientRotation(progress * math.pi * 2),
      colors: [color1, color2, color1],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// Línea de barrido vertical con leve "glow".
class _SweepLinePainter extends CustomPainter {
  final double position; // 0..1
  final Color color;
  final Color glow;

  _SweepLinePainter({
    required this.position,
    required this.color,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * position;

    // Glow difuso
    final glowPaint = Paint()
      ..color = glow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(x - 8, 0, 16, size.height), glowPaint);

    // Línea principal
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(x - 1, 0, 2, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant _SweepLinePainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color ||
        oldDelegate.glow != glow;
  }
}

/// Spinner con 8 puntos orbitando.
class _SpinnerDotsPainter extends CustomPainter {
  final double turn; // 0..1
  final Color baseColor;
  final Color dotColor;

  _SpinnerDotsPainter({
    required this.turn,
    required this.baseColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.35;
    const dots = 8;

    final basePaint = Paint()..color = baseColor;
    final dotPaint = Paint()..color = dotColor;

    for (int i = 0; i < dots; i++) {
      final angle = (i / dots) * 2 * math.pi + (turn * 2 * math.pi);
      final offset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      // Tamaño varia ligeramente para efecto
      final dotSize = i == 0 ? 6.0 : 4.0;
      final paint = i == 0 ? dotPaint : basePaint;

      canvas.drawCircle(offset, dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerDotsPainter oldDelegate) {
    return oldDelegate.turn != turn ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.dotColor != dotColor;
  }
}
