import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/attendance_scanner_provider.dart';

class AttendanceCameraScannerView extends StatefulWidget {
  const AttendanceCameraScannerView({super.key});

  @override
  State<AttendanceCameraScannerView> createState() =>
      _AttendanceCameraScannerViewState();
}

class _AttendanceCameraScannerViewState
    extends State<AttendanceCameraScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, AttendanceScannerProvider>(
      builder: (context, themeProvider, scannerProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                scannerProvider.stopCameraScanning();
                Navigator.pop(context);
              },
            ),
            title: Text(
              l10n.cameraScanner,
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Status indicator
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                margin: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: _getStatusColor(scannerProvider).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  border: Border.all(
                    color: _getStatusColor(scannerProvider).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(scannerProvider),
                      color: _getStatusColor(scannerProvider),
                      size: 24,
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      child: Text(
                        _getStatusMessage(scannerProvider),
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: _getStatusColor(scannerProvider),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // QR Scanner
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.getMediumPadding(screenSize)),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getLargeRadius(screenSize)),
                  ),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: (QRViewController controller) {
                      this.controller = controller;
                      scannerProvider.onCameraQRViewCreated(controller);
                      scannerProvider.startCameraScanning();
                    },
                    overlay: QrScannerOverlayShape(
                      borderColor: AppTheme.accentBlue,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: screenSize.width * 0.8,
                    ),
                  ),
                ),
              ),

              // Instructions and controls
              Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.qrScannerInstructions,
                        style: AppTheme.getBodyLarge(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      Text(
                        l10n.qrScannerAutomatic,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (scannerProvider.successMessage != null) ...[
                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            scannerProvider.clearMessages();
                            scannerProvider.startCameraScanning();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.getLargePadding(screenSize),
                              vertical: AppTheme.getMediumPadding(screenSize),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getMediumRadius(screenSize)),
                            ),
                          ),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: Text(l10n.scanAnother),
                        ),
                      ],
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

  Color _getStatusColor(AttendanceScannerProvider provider) {
    switch (provider.state) {
      case ScannerState.scanning:
        return AppTheme.accentBlue;
      case ScannerState.processing:
        return AppTheme.accentOrange;
      case ScannerState.success:
        return AppTheme.successColor;
      case ScannerState.error:
        return AppTheme.errorColor;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getStatusIcon(AttendanceScannerProvider provider) {
    switch (provider.state) {
      case ScannerState.scanning:
        return Icons.qr_code_scanner;
      case ScannerState.processing:
        return Icons.hourglass_empty;
      case ScannerState.success:
        return Icons.check_circle;
      case ScannerState.error:
        return Icons.error;
      default:
        return Icons.qr_code_scanner;
    }
  }

  String _getStatusMessage(AttendanceScannerProvider provider) {
    switch (provider.state) {
      case ScannerState.scanning:
        return 'Escaneando código QR...';
      case ScannerState.processing:
        return 'Procesando código...';
      case ScannerState.success:
        return provider.successMessage ?? 'Asistencia registrada exitosamente';
      case ScannerState.error:
        return provider.errorMessage ?? 'Error al procesar el código';
      default:
        return 'Listo para escanear';
    }
  }
}
