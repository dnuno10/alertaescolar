import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onCodeScanned;
  final VoidCallback onClose;

  const QRScannerWidget({
    super.key,
    required this.onCodeScanned,
    required this.onClose,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool flashOn = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR Scanner
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppTheme.accentBlue,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: screenSize.width * 0.8,
            ),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize),
                          ),
                        ),
                        child: IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Flash toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize),
                          ),
                        ),
                        child: IconButton(
                          onPressed: _toggleFlash,
                          icon: Icon(
                            flashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Instructions
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
                      'Apunta la cámara al código QR del estudiante',
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

          // Bottom instructions
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
                      'Escanear Código QR',
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      'Posiciona el código QR dentro del marco para escanearlo automáticamente',
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

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        widget.onCodeScanned(scanData.code!);
      }
    });
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        flashOn = !flashOn;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
