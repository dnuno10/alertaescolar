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
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
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
    super.dispose();
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
            // En algunas versiones no hay onPermissionSet; usamos errorBuilder
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 64),
                      const SizedBox(height: 12),
                      Text(
                        'Error de cámara (${error.errorCode})',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Verifica permisos de cámara y vuelve a intentarlo.',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: widget.onClose,
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Controles superiores
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cerrar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize),
                          ),
                        ),
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
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize),
                          ),
                        ),
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

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Instrucciones
                  Container(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize),
                      ),
                    ),
                    child: Text(
                      l10n.qrScannerPointCamera,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pie con título e instrucciones + marco guía
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Marco guía
                  Container(
                    width: cutout,
                    height: cutout,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          AppTheme.getLargeRadius(screenSize)),
                      border: Border.all(
                        color: AppTheme.accentBlue,
                        width: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            AppTheme.getLargeRadius(screenSize)),
                        topRight: Radius.circular(
                            AppTheme.getLargeRadius(screenSize)),
                      ),
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
                          l10n.qrScannerInstructions,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: Colors.white.withOpacity(0.8),
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
