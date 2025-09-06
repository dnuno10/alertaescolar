import 'dart:async';
import 'dart:io';

import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../app/app_theme.dart';
import 'processing_view.dart';

// Usa la ruta real donde vive tu clase CustomSnackBar
import '../../../widgets/custom_snack_bar.dart';

class CameraScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;
  final ScannerAccessType? accessType;
  final bool? isDefaultEntryConfig;

  /// true  => mostrar detalles en ProcessingView (pantalla completa)
  /// false => headless (solo loader) y mensaje por CustomSnackBar
  final bool initialShowResultInProcessing;

  const CameraScannerView({
    super.key,
    required this.onCodeScanned,
    this.accessType,
    this.isDefaultEntryConfig,
    this.initialShowResultInProcessing = true,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Generamos una GlobalKey nueva por cada instancia de cámara
  late GlobalKey _qrKey;

  QRViewController? _controller;
  StreamSubscription<Barcode>? _scanSub;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _navigating = false; // evita múltiples pushes / resumes concurrentes
  bool _pausedByLifecycle = false;

  // Mostramos/ocultamos la vista para forzar dispose/recreate del PlatformView
  bool _showCamera = true;
  int _cameraInstanceId = 0;

  // Animaciones UI
  late final AnimationController _accessTypeAnimationController;

  // Switch para decidir el comportamiento de post-proceso
  bool _showResultInProcessing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _qrKey = GlobalKey(debugLabel: 'QR_$_cameraInstanceId');
    _accessTypeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _showResultInProcessing = widget.initialShowResultInProcessing;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCameraController(); // cancela stream + dispose controller seguro
    _accessTypeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _disposeCameraController() async {
    // Cerrar stream y cámara con cuidado
    try {
      await _scanSub?.cancel();
    } catch (_) {}
    _scanSub = null;

    final c = _controller;
    _controller = null;
    if (c != null) {
      try {
        await c.pauseCamera();
      } catch (_) {}

      // ⚡ iOS FIX: Añadir delay antes de dispose para iOS UiKitView
      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      try {
        c.dispose();
      } catch (e) {
        debugPrint('Camera dispose error: $e');
      }
    }

    _isInitialized = false;
  }

  void _recreateCameraKey() {
    _cameraInstanceId++;
    _qrKey = GlobalKey(debugLabel: 'QR_$_cameraInstanceId');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si la cámara no está visible, no intentes pausar/reanudar
    if (_controller == null || !_isInitialized || !_showCamera) return;

    try {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached) {
        _pausedByLifecycle = true;
        _controller!.pauseCamera();
      } else if (state == AppLifecycleState.resumed) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          if (!mounted || _controller == null) return;
          if (_navigating) return;
          try {
            await _controller!.resumeCamera();
            _pausedByLifecycle = false;
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
    // Manejo recomendado por plataforma durante Hot Reload
    try {
      if (_controller == null || !_showCamera) return;
      if (Platform.isAndroid) {
        _controller!.pauseCamera();
        Future.delayed(const Duration(milliseconds: 200), () async {
          if (!mounted || _controller == null) return;
          try {
            await _controller!.resumeCamera();
          } catch (e) {
            debugPrint('Android reassemble resume error: $e');
          }
        });
      } else if (Platform.isIOS) {
        _controller!.resumeCamera();
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
            QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
              cameraFacing: CameraFacing.back,
              // Limitar a QR reduce carga y falsos positivos
              formatsAllowed: const [BarcodeFormat.qrcode],
              overlay: QrScannerOverlayShape(
                borderColor: _navigating ? Colors.green : AppTheme.accentBlue,
                borderRadius: 24,
                borderLength: 80,
                borderWidth: 4,
                cutOutSize: screenSize.width * 0.7,
              ),
              onPermissionSet: (ctrl, hasPermission) {
                if (!hasPermission) _failWithPermissionError();
              },
            ),
          if (_hasError) _buildErrorState(context),
          if (!_hasError) _buildScannerOverlay(screenSize),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
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
            const Text(
              'Error al inicializar la cámara',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifica los permisos de cámara',
              style: TextStyle(color: Colors.white70, fontSize: 14),
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
                    child: AnimatedBuilder(
                      animation: _accessTypeAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0,
                              -20 * (1 - _accessTypeAnimationController.value)),
                          child: Opacity(
                            opacity: _accessTypeAnimationController.value,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppTheme.getMediumPadding(screenSize),
                                vertical: AppTheme.getSmallPadding(screenSize),
                              ),
                              decoration: BoxDecoration(
                                color: _getAccessTypeColor().withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1),
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
                        );
                      },
                    ),
                  ),
                ),

                // Reservamos espacio simétrico
                const SizedBox(width: 48),
              ],
            ),
          ),

          const Spacer(),

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
              mainAxisSize: MainAxisSize
                  .min, // importante para que el switch quede pegado debajo
              children: [
                Icon(Icons.qr_code_scanner,
                    color: AppTheme.accentBlue, size: 32),
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

                // Switch debajo (centrado) - etiqueta fija "Revisión de alumno"
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
                      Icon(
                        Icons.person_search_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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
                          // Podrías persistir por escuela si lo deseas
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
  // Cámara / Escaneo
  // ========================

  void _onQRViewCreated(QRViewController controller) {
    if (!mounted) return;

    _controller = controller;

    // Algunos OEMs no disparan onPermissionSet
    controller.getCameraInfo().catchError((_) {});

    _initializeCamera(controller);
  }

  Future<void> _initializeCamera(QRViewController controller) async {
    if (!mounted) return;

    try {
      // Pequeño delay para asegurar que el Surface esté creado
      await Future.delayed(const Duration(milliseconds: 120));

      await controller.resumeCamera();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      // Suscripción EXACTAMENTE una vez por instancia
      _scanSub = controller.scannedDataStream.listen((scanData) {
        if (!_isInitialized || _navigating) return;
        final code = scanData.code;
        if (code == null || code.isEmpty) return;

        // Bloquea reentradas inmediatamente
        _navigating = true;

        // Al navegar, desmontamos la cámara para evitar recreating_view en iOS
        _handleScanAndNavigate(code);
      }, onError: (e) {
        debugPrint('Scan stream error: $e');
      });

      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Camera initialization error: $e');

      // Reintento único
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await controller.resumeCamera();
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        _scanSub = controller.scannedDataStream.listen((scanData) {
          if (!_isInitialized || _navigating) return;
          final code = scanData.code;
          if (code == null || code.isEmpty) return;
          _navigating = true;
          _handleScanAndNavigate(code);
        }, onError: (e) {
          debugPrint('Scan stream error (retry): $e');
        });

        debugPrint('Camera initialized on retry');
      } catch (e2) {
        debugPrint('Camera retry failed: $e2');
        if (!mounted) return;
        setState(() => _hasError = true);
      }
    }
  }

  Future<void> _handleScanAndNavigate(String code) async {
    // 1) Ocultar cámara → fuerza dispose del PlatformView
    setState(() {
      _showCamera = false;
    });
    await _disposeCameraController();

    // 2) Procesar navegación
    await _processScannedCode(code);

    // 3) Volver a mostrar cámara completamente limpia (nueva key y controller)
    if (!mounted) return;
    setState(() {
      _recreateCameraKey(); // nueva GlobalKey => nuevo PlatformView
      _showCamera = true;
      _navigating = false;
    });
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
        // Intento no bloqueante de resolución (por si aún no estaba cacheado)
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
            escuelaId: escuelaId, // <-- YA DEFINIDO
            accessType: widget.accessType ?? ScannerAccessType.automatic,
            isDefaultEntryConfig: widget.isDefaultEntryConfig ?? true,
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
                : 'No se pudo registrar el escaneo.'); // motivo de error
        _showFeedbackMessage(msg, success: success);
        if (success) widget.onCodeScanned(code);
      } else if (result == true) {
        // Por compatibilidad
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
    // Usa tu CustomSnackBar; si falla, fallback a SnackBar nativo
    final controller = CustomSnackBar.show(
      context: context,
      message: text,
      isError: !success,
      duration: const Duration(seconds: 3),
      replace: true,
    );

    if (controller == null) {
      // Fallback
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

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? 'Entrada Automática' : 'Salida Automática';
      case ScannerAccessType.entry:
        return 'Entrada';
      case ScannerAccessType.exit:
        return 'Salida';
    }
  }

  Color _getAccessTypeColor() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? Colors.green : Colors.orange;
      case ScannerAccessType.entry:
        return Colors.blue;
      case ScannerAccessType.exit:
        return Colors.red;
    }
  }

  // ========================
  // Errores de permiso
  // ========================
  void _failWithPermissionError() {
    setState(() => _hasError = true);
    _showFeedbackMessage(
      'Permisos de cámara requeridos para escanear códigos QR',
      success: false,
    );
  }
}
