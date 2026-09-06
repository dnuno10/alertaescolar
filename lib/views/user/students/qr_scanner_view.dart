import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class QRScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;
  final VoidCallback onClose;

  const QRScannerView({
    super.key,
    required this.onCodeScanned,
    required this.onClose,
  });

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _scanLineController;
  bool flashOn = false;
  bool _handled = false; // evita lecturas múltiples

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 250,
      returnImage: false,
      formats: const [
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
      ],
    );

    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Intento de arranque (si falla, el widget mostrará error vía errorBuilder)
    _controller.start().catchError((_) {});
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload: pausa y reanuda para evitar cámara bloqueada
    _controller.stop().then((_) => _controller.start()).catchError((_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausa/resume para evitar cámara activa en background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start().catchError((_) {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  Widget _buildErrorView(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
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
              onPressed: widget.onClose,
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final cutout = screenSize.shortestSide * 0.8;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              debugPrint(
                  'QR Scanner error: ${error.errorCode} - ${error.errorDetails}');
              // Solo mostrar error para problemas reales y críticos
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                return _buildErrorView('Sin permisos de cámara',
                    'Habilita los permisos de cámara en la configuración del dispositivo para escanear códigos QR');
              } else if (error.errorCode ==
                  MobileScannerErrorCode.unsupported) {
                return _buildErrorView('Cámara no compatible',
                    'Este dispositivo no es compatible con el escáner de códigos QR');
              }
              // Para errores temporales, de inicialización u otros no críticos, mostrar la cámara normal
              // Esto permite que MobileScanner maneje internamente los errores menores
              return child ?? Container();
            },
          ),

          // Controles superiores - solo botones
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cerrar
                  Container(
                    child: IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onClose();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Flash
                  Container(
                    child: IconButton(
                      tooltip: flashOn ? 'Apagar flash' : 'Encender flash',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _toggleFlash();
                      },
                      icon: Icon(
                        flashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Marco QR centrado
          Center(
            child: SizedBox(
              width: cutout,
              height: cutout,
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
                          top: BorderSide(color: AppTheme.accentBlue, width: 4),
                          left:
                              BorderSide(color: AppTheme.accentBlue, width: 4),
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
                          top: BorderSide(color: AppTheme.accentBlue, width: 4),
                          right:
                              BorderSide(color: AppTheme.accentBlue, width: 4),
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
                          bottom:
                              BorderSide(color: AppTheme.accentBlue, width: 4),
                          left:
                              BorderSide(color: AppTheme.accentBlue, width: 4),
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
                          bottom:
                              BorderSide(color: AppTheme.accentBlue, width: 4),
                          right:
                              BorderSide(color: AppTheme.accentBlue, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Línea de escaneo animada - minimalista
                  AnimatedBuilder(
                    animation: _scanLineController,
                    builder: (context, child) {
                      return Positioned(
                        top: (cutout * 0.15) +
                            (cutout * 0.7 * _scanLineController.value),
                        left: 60,
                        right: 60,
                        child: Container(
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(0.75),
                            boxShadow: const [],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Pie con título e instrucciones
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(screenSize)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.qrScannerTitle,
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      l10n.qrScannerPointCamera,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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

  void _onDetect(BarcodeCapture capture) async {
    if (_handled) return;

    final code = capture.barcodes
        .map((b) => b.rawValue?.trim() ?? '')
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');

    if (code.isEmpty) return;

    _handled = true;
    await _controller.stop(); // pausa antes de salir
    if (!mounted) return;
    widget.onCodeScanned(code);
  }

  Future<void> _toggleFlash() async {
    try {
      await _controller.toggleTorch();
      // Si no podemos leer el estado real, invertimos localmente
      if (!mounted) return;
      setState(() => flashOn = !flashOn);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El dispositivo no soporta flash')),
      );
    }
  }
}
