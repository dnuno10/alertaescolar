import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool flashOn = false;
  bool _handled = false; // evita lecturas múltiples / rebotes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload: pausa y reanuda para evitar cámara bloqueada
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausa/resume para evitar cámara activa en background
    if (controller == null) return;
    if (state == AppLifecycleState.paused) {
      controller!.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final cutout =
        screenSize.shortestSide * 0.8; // más robusto en rotación/tablets

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            onPermissionSet: (ctrl, permitted) async {
              if (!permitted) {
                // Feedback y salida limpia si no hay permisos
                HapticFeedback.mediumImpact();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permiso de cámara denegado')),
                );
                await Future.delayed(const Duration(milliseconds: 300));
                if (!mounted) return;
                widget.onClose();
              }
            },
            overlay: QrScannerOverlayShape(
              borderColor: AppTheme.accentBlue,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: cutout,
            ),
            formatsAllowed: const [
              BarcodeFormat.qrcode,
              BarcodeFormat.code128,
              BarcodeFormat.code39,
            ],
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

          // Pie con título e instrucciones
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(AppTheme.getLargeRadius(screenSize)),
                    topRight:
                        Radius.circular(AppTheme.getLargeRadius(screenSize)),
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
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    setState(() => this.controller = controller);

    // Sincroniza estado real del flash al crear
    try {
      final status = await controller.getFlashStatus();
      if (mounted && status != null) {
        setState(() => flashOn = status);
      }
    } catch (_) {
      // Ignora si el dispositivo no soporta flash
    }

    // Debounce/one-shot para evitar lecturas múltiples
    controller.scannedDataStream.listen((scanData) async {
      final code = scanData.code;
      if (_handled || code == null || code.isEmpty) return;
      _handled = true;

      await controller.pauseCamera();
      if (!mounted) return;
      widget.onCodeScanned(code);
    });
  }

  Future<void> _toggleFlash() async {
    final c = controller;
    if (c == null) return;
    try {
      await c.toggleFlash();
      final status = await c.getFlashStatus();
      if (!mounted) return;
      setState(() => flashOn = status ?? !flashOn);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El dispositivo no soporta flash')),
      );
    }
  }
}
