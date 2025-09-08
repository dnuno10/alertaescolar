// physical_scanner_view.dart
import 'dart:async';

import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'processing_view.dart';
import '../../../widgets/custom_snack_bar.dart';

/// Vista para lectores de QR físicos (USB/Bluetooth) que emulan teclado.
/// - Captura el input de teclado y lo "commitea" al presionar Enter/Tab o tras un
///   breve periodo de inactividad (buffer).
/// - Evita reentradas mientras procesa y asegura el enfoque del teclado.
/// - Integra con `scanner_service.dart` vía `ProcessingView`.
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
    this.isExtracurricular = false, // Por defecto falso
  });

  @override
  State<PhysicalScannerView> createState() => _PhysicalScannerViewState();
}

class _PhysicalScannerViewState extends State<PhysicalScannerView> {
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

  // Rutas Lottie (cámbialas si usas otros nombres)
  static const String _lottieScan = 'assets/anim/qr_code_scanner.json';
  static const String _lottieProcessing = 'assets/anim/processing_spinner.json';

  @override
  void initState() {
    super.initState();

    // Oculta el teclado del sistema en móviles (no lo necesitamos para scanners)
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
        return isExtracurricular ? 'Entrada Extracurricular' : 'Entrada Fija';
      case ScannerAccessType.exit:
        return isExtracurricular ? 'Salida Extracurricular' : 'Salida Fija';
    }
  }

  Color _getAccessTypeColor() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? Colors.green : Colors.red;
      case ScannerAccessType.entry:
        return Colors.green; // Verde para todas las entradas
      case ScannerAccessType.exit:
        return Colors.red; // Rojo para todas las salidas
    }
  }

  // ========================
  // Entrada del lector (teclado)
  // ========================

  void _onKeyEvent(KeyEvent event) {
    if (!mounted || _busy) return; // si estamos procesando, ignorar input
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    // ESC → limpiar buffer
    if (key == LogicalKeyboardKey.escape) {
      _clearBuffer();
      return;
    }

    // Backspace → eliminar último caracter si existe
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
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingView(
            scannedCode: code,
            adminId: admin.id,
            escuelaId: escuelaId,
            accessType: widget.accessType ?? ScannerAccessType.automatic,
            isDefaultEntryConfig: widget.isDefaultEntryConfig ?? true,
            isExtracurricular: widget.isExtracurricular, // Nuevo parámetro
            displayMode: displayMode,
            returnDetailedResult: returnDetailed,
          ),
        ),
      );

      if (!mounted) return;

      // 5) Manejo de retorno
      if (_showResultInProcessing) {
        // Modo clásico: ProcessingView ya mostró UI. Solo propagar OK a caller.
        if (result == true ||
            (result is ProcessingOutcome && result.success == true)) {
          widget.onCodeScanned(code);
        }
        return; // IMPORTANTE: Salir aquí para NO mostrar CustomSnackBar
      }

      // Headless: esperamos un ProcessingOutcome para mostrar mensaje
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
      // Siempre reiniciar para el siguiente escaneo
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
            NavHeader(title: 'Escáner Físico'),

            // Main content
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
                child: Column(
                  children: [
                    // Indicador de tipo de acceso
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: _getAccessTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getAccessTypeColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getAccessTypeColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            _getAccessTypeText(),
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: _getAccessTypeColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),

                    // Visualización del "área" de escaneo usando Lottie
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 340,
                          // altura generosa para efecto
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      AppTheme.accentOrange.withOpacity(0.25),
                                  width: 1,
                                ),
                                color: AppTheme.accentOrange.withOpacity(0.03),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _listening
                                    ? _LottieBox(
                                        asset: _lottieScan,
                                        repeat: true,
                                        hintIcon: Icons.qr_code_scanner,
                                        hintText:
                                            'Escanea un código QR con tu lector físico',
                                      )
                                    : _LottieBox(
                                        asset: _lottieProcessing,
                                        repeat: true,
                                        hintIcon: Icons.hourglass_empty,
                                        hintText: 'Procesando...',
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppTheme.getLargePadding(screenSize)),

                    // Estado
                    Text(
                      _listening ? 'Listo para escanear' : 'Procesando...',
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w300,
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
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.accentOrange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _buffer,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.accentOrange,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    ],

                    // Switch "Revisión de alumno" (fondo, centrado)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: AppTheme.getLargePadding(screenSize),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.getTextSecondaryColor(context)
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Revisión de alumno',
                              style: AppTheme.getCaption(screenSize),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: _showResultInProcessing,
                              onChanged: (v) =>
                                  setState(() => _showResultInProcessing = v),
                              activeColor: AppTheme.accentBlue,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Ayuda
                    Container(
                      padding:
                          EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                      decoration: BoxDecoration(
                        color: AppTheme.getTextSecondaryColor(context)
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.getTextSecondaryColor(context)
                              .withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: AppTheme.getTextSecondaryColor(context),
                            size: 24,
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            'Conecta tu lector de códigos QR USB o Bluetooth y escanea directamente. Los códigos aparecerán automáticamente.',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            textAlign: TextAlign.center,
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
      ),
    );
  }
}

/// Widget auxiliar que intenta cargar una animación Lottie y
/// muestra un “fallback” elegante si el asset no existe.
class _LottieBox extends StatelessWidget {
  final String asset;
  final bool repeat;
  final IconData? hintIcon;
  final String? hintText;

  const _LottieBox({
    required this.asset,
    this.repeat = true,
    this.hintIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animación Lottie de fondo
        Lottie.asset(
          asset,
          repeat: repeat,
          fit: BoxFit.contain,
        ),
        // Icono por encima
        if (hintIcon != null)
          Icon(
            hintIcon,
            size: 64,
            color: AppTheme.accentOrange.withOpacity(0.8),
          ),
      ],
    );
  }
}

class _FallbackScan extends StatefulWidget {
  final IconData hintIcon;
  final String hintText;

  const _FallbackScan({
    required this.hintIcon,
    required this.hintText,
  });

  @override
  State<_FallbackScan> createState() => _FallbackScanState();
}

class _FallbackScanState extends State<_FallbackScan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.95, end: 1.05)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return Center(
          child: Transform.scale(
            scale: _pulse.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.hintIcon,
                    size: 56, color: AppTheme.accentOrange.withOpacity(0.7)),
                const SizedBox(height: 8),
                Text(
                  widget.hintText,
                  textAlign: TextAlign.center,
                  style: AppTheme.getBodyMedium(MediaQuery.of(context).size)
                      .copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
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
