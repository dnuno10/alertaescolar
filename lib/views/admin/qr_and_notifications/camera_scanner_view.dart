import 'dart:async';
import 'dart:io';

import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import 'processing_view.dart';
import '../../../widgets/custom_snack_bar.dart';

class CameraScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;
  final ScannerAccessType? accessType;
  final bool? isDefaultEntryConfig;
  final bool isExtracurricular;

  /// true  => mostrar detalles en ProcessingView (pantalla completa)
  /// false => headless (solo loader) y mensaje por CustomSnackBar
  final bool initialShowResultInProcessing;

  const CameraScannerView({
    super.key,
    required this.onCodeScanned,
    this.accessType,
    this.isDefaultEntryConfig,
    this.isExtracurricular = false,
    this.initialShowResultInProcessing = true,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final MobileScannerController _controller;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _navigating = false; // evita múltiples pushes / resumes concurrentes
  bool _processing = false;
  String? _lastProcessedCode;
  DateTime? _lastProcessTime;

  bool _showCamera = true;

  // Animaciones UI
  late final AnimationController _accessTypeAnimationController;

  bool _showResultInProcessing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 250,
      returnImage: false,
      formats: const [BarcodeFormat.qrCode], // Limitar a QR para menos falsos
    );

    _accessTypeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _showResultInProcessing = widget.initialShowResultInProcessing;

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await Future.delayed(const Duration(milliseconds: 120));
      await _controller.start();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');

      // No mostrar error si es solo un problema temporal o de inicialización
      // Solo mostrar error si realmente es un problema de permisos o hardware
      if (e.toString().contains('permission') ||
          e.toString().contains('Permission') ||
          e.toString().contains('unauthorized')) {
        if (!mounted) return;
        setState(() => _hasError = true);
        return;
      }

      // Reintento único para errores temporales
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _controller.start();
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      } catch (e2) {
        debugPrint('Camera retry failed: $e2');
        // Solo mostrar error si es realmente un problema persistente
        if (e2.toString().contains('permission') ||
            e2.toString().contains('Permission') ||
            e2.toString().contains('unauthorized')) {
          if (!mounted) return;
          setState(() => _hasError = true);
        } else {
          // Para otros errores, intentar usar el errorBuilder del MobileScanner
          if (!mounted) return;
          setState(() {
            _isInitialized = true;
            _hasError = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _controller.dispose();
    } catch (e) {
      debugPrint('Camera dispose error: $e');
    }
    _accessTypeAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || !_showCamera) return;

    try {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached) {
        _controller.stop();
      } else if (state == AppLifecycleState.resumed) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          if (!mounted) return;
          if (_navigating) return;
          try {
            await _controller.start();
          } catch (e) {
            debugPrint('Camera resume on resume error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Camera lifecycle error: $e');
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot Reload handling
    try {
      if (!_showCamera) return;
      if (Platform.isAndroid) {
        _controller.stop();
        Future.delayed(const Duration(milliseconds: 200), () async {
          if (!mounted) return;
          try {
            await _controller.start();
          } catch (e) {
            debugPrint('Android reassemble resume error: $e');
          }
        });
      } else if (Platform.isIOS) {
        _controller.start().catchError((_) {});
      }
    } catch (e) {
      debugPrint('Camera reassemble error: $e');
    }
  }

  // ========================
  // UI
  // ========================
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (!_hasError && _showCamera)
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                debugPrint(
                    'Camera error: ${error.errorCode} - ${error.errorDetails}');
                // Solo mostrar error para problemas reales de permisos o hardware
                if (error.errorCode ==
                    MobileScannerErrorCode.permissionDenied) {
                  return _buildErrorState(context,
                      title: 'Sin permisos de cámara',
                      message:
                          'Habilita los permisos de cámara para escanear códigos QR');
                } else if (error.errorCode ==
                    MobileScannerErrorCode.unsupported) {
                  return _buildErrorState(context,
                      title: 'Cámara no compatible',
                      message:
                          'Este dispositivo no soporta el escáner de códigos');
                }
                // Para errores temporales, de inicialización u otros, mostrar la cámara normal
                // Esto permite que el errorBuilder del MobileScanner maneje los errores menores
                return child ?? Container();
              },
            ),
          // Solo mostrar error si es un error crítico confirmado
          if (_hasError && !_showCamera)
            _buildErrorState(context,
                title: 'Error de cámara',
                message:
                    'No se puede acceder a la cámara. Verifica los permisos.'),
          if (!_hasError) _buildScannerOverlay(screenSize),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context,
      {String title = 'Error al inicializar la cámara',
      String message = 'Verifica los permisos de cámara'}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(Size screenSize) {
    final cutOut = screenSize.width * 0.7;

    return SafeArea(
      child: Column(
        children: [
          // Top controls
          Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                  screenSize: screenSize,
                ),

                // Etiqueta de modo de acceso (centro)
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: _getAccessTypeColor().withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getAccessTypeText(),
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Reservamos espacio simétrico
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Área central - Marco QR centrado
          Expanded(
            child: Center(
              child: SizedBox(
                width: cutOut,
                height: cutOut,
                child: Stack(
                  children: [
                    // Esquina superior izquierda
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                            left: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Esquina superior derecha
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                            right: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Esquina inferior izquierda
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                            left: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Esquina inferior derecha
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                            right: BorderSide(
                                color: AppTheme.accentBlue, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Línea de escaneo animada - minimalista
                    AnimatedBuilder(
                      animation: _accessTypeAnimationController,
                      builder: (context, child) {
                        return Positioned(
                          top: (cutOut * 0.15) +
                              (cutOut *
                                  0.7 *
                                  _accessTypeAnimationController.value),
                          left: 60,
                          right: 60,
                          child: Container(
                            height: 1.5,
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(0.75),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentBlue.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom instructions + switch centrado
          Container(
            margin: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner,
                    color: Colors.white, size: 32),
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                Text(
                  'Apunta la cámara al código QR',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Switch "Revisión de alumno"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.25), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_search_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Revisión de alumno',
                        style: AppTheme.getCaption(screenSize)
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _showResultInProcessing,
                        onChanged: (v) {
                          setState(() => _showResultInProcessing = v);
                        },
                        activeColor: AppTheme.accentBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Size screenSize,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  // ========================
  // Detección / Navegación
  // ========================
  void _onDetect(BarcodeCapture capture) async {
    if (!_isInitialized || _navigating || _processing) return;

    final code = capture.barcodes
        .map((b) => b.rawValue?.trim() ?? '')
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');

    if (code.isEmpty) return;

    // Establecer flag de navegación y procesar
    setState(() {
      _navigating = true;
    });

    try {
      await _handleScanAndNavigate(code);
    } finally {
      // Asegurar que _navigating siempre se resetea
      if (mounted) {
        setState(() {
          _navigating = false;
        });
      }
    }
  }

  Future<void> _handleScanAndNavigate(String code) async {
    if (_processing) {
      debugPrint('🔒 SCANNER: Already processing, ignoring scan: $code');
      return;
    }

    final now = DateTime.now();
    if (_lastProcessedCode == code &&
        _lastProcessTime != null &&
        now.difference(_lastProcessTime!).inSeconds < 2) {
      debugPrint('🔒 SCANNER: Same code scanned too quickly, ignoring: $code');
      return;
    }

    _processing = true;
    _lastProcessedCode = code;
    _lastProcessTime = now;

    debugPrint('🔒 SCANNER: Starting to process code: $code');

    try {
      // 1) Pausar detección temporalmente
      setState(() {
        _showCamera = false;
      });

      try {
        await _controller.stop();
      } catch (e) {
        debugPrint('Error stopping camera: $e');
      }

      // 2) Procesar navegación
      await _processScannedCode(code);
    } finally {
      // 3) Asegurar que siempre se restaure el estado, incluso si hay errores
      if (mounted) {
        debugPrint('🔒 SCANNER: Restoring camera state');

        setState(() {
          _showCamera = true;
          _processing = false;
        });

        // 4) Reiniciar cámara con delay para estabilidad
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          try {
            await _controller.start();
            debugPrint('🔒 SCANNER: Camera restarted successfully');
          } catch (e) {
            debugPrint('Failed to restart camera: $e');
            // Intentar reiniciar una vez más
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              try {
                await _controller.start();
                debugPrint('🔒 SCANNER: Camera restarted on retry');
              } catch (e2) {
                debugPrint('Failed to restart camera on retry: $e2');
                setState(() => _hasError = true);
              }
            }
          }
        }
      }
    }

    debugPrint('🔒 SCANNER: Finished processing code: $code');
  }

  Future<void> _processScannedCode(String code) async {
    if (!mounted) return;

    try {
      final userProvider = context.read<UserProvider>();

      // 1) Usuario autenticado
      late final Usuario admin;
      try {
        admin = userProvider.requireCurrentUser();
      } catch (_) {
        _showErrorMessage('Error: Usuario no autenticado');
        return;
      }

      // 2) Asegurar escuelaId en memoria (o lanzar)
      String escuelaId;
      try {
        escuelaId = await userProvider.ensureEscuelaIdOrThrow();
      } catch (_) {
        await userProvider.ensureEscuelaIdLoaded();
        final cached = userProvider.currentUser?.escuelaId;
        if (cached == null || cached.isEmpty) {
          _showErrorMessage('No se pudo determinar la escuela del usuario');
          await Future.delayed(const Duration(milliseconds: 250));
          if (mounted) Navigator.of(context).maybePop();
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
        _showFeedbackMessage(msg, success: success);
        if (success) widget.onCodeScanned(code);
      } else if (result == true) {
        _showFeedbackMessage('Notificación enviada correctamente.',
            success: true);
        widget.onCodeScanned(code);
      } else {
        _showFeedbackMessage('No se pudo registrar el escaneo (sin detalles).',
            success: false);
      }
    } catch (e) {
      debugPrint('Error processing scanned code: $e');
      _showErrorMessage('Error al procesar el código: $e');
    }
  }

  // ========================
  // Mensajes
  // ========================
  void _showFeedbackMessage(String text, {required bool success}) {
    // Verificar si ya hay un snackbar activo - si es así, no mostrar nuevo
    if (CustomSnackBar.isActive) {
      debugPrint('SnackBar descartado: ya hay uno activo - $text');
      return;
    }

    final controller = CustomSnackBar.show(
      context: context,
      message: text,
      isError: !success,
      duration: const Duration(seconds: 3),
      replace: true,
    );

    if (controller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorMessage(String text) =>
      _showFeedbackMessage(text, success: false);

  // ========================
  // Helpers UI
  // ========================

  String _getAccessTypeText() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;
    final isExtracurricular = widget.isExtracurricular;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? 'Entrada Automática' : 'Salida Automática';
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
        return Colors.green;
      case ScannerAccessType.exit:
        return Colors.red;
    }
  }
}
