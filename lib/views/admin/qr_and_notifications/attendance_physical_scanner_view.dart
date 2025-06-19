import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/attendance_scanner_provider.dart';

class AttendancePhysicalScannerView extends StatefulWidget {
  const AttendancePhysicalScannerView({super.key});

  @override
  State<AttendancePhysicalScannerView> createState() =>
      _AttendancePhysicalScannerViewState();
}

class _AttendancePhysicalScannerViewState
    extends State<AttendancePhysicalScannerView> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _manualInputController = TextEditingController();
  String _inputBuffer = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scannerProvider =
          Provider.of<AttendanceScannerProvider>(context, listen: false);
      scannerProvider.startPhysicalScannerListening();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _manualInputController.dispose();
    final scannerProvider =
        Provider.of<AttendanceScannerProvider>(context, listen: false);
    scannerProvider.stopPhysicalScannerListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, AttendanceScannerProvider>(
      builder: (context, themeProvider, scannerProvider, child) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKey: _handleKeyEvent,
          child: Scaffold(
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
                  scannerProvider.stopPhysicalScannerListening();
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'Escáner Físico',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: _getStatusColor(scannerProvider).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(screenSize)),
                      border: Border.all(
                        color:
                            _getStatusColor(scannerProvider).withOpacity(0.3),
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

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Scanner illustration
                  _buildScannerIllustration(scannerProvider),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Instructions
                  _buildInstructionsCard(),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Manual input section
                  _buildManualInputSection(scannerProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final scannerProvider =
          Provider.of<AttendanceScannerProvider>(context, listen: false);

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_inputBuffer.isNotEmpty) {
          scannerProvider.handlePhysicalScannerInput(_inputBuffer);
          _inputBuffer = '';
        }
      } else if (event.character != null && event.character!.isNotEmpty) {
        _inputBuffer += event.character!;
      }
    }
  }

  Widget _buildScannerIllustration(AttendanceScannerProvider scannerProvider) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: screenSize.width * 0.6,
        height: screenSize.width * 0.4,
        decoration: BoxDecoration(
          color: AppTheme.accentOrange.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
          border: Border.all(
            color: AppTheme.accentOrange.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              width: scannerProvider.isScanning ? 80 : 60,
              height: scannerProvider.isScanning ? 80 : 60,
              child: Icon(
                Icons.scanner_rounded,
                color: AppTheme.accentOrange,
                size: scannerProvider.isScanning ? 60 : 40,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              scannerProvider.isScanning
                  ? 'Escuchando...'
                  : 'Listo para escanear',
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentOrange,
                size: 24,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Instrucciones',
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildInstructionItem('Conecta tu dispositivo escáner físico'),
          _buildInstructionItem(
              'Apunta el escáner al código QR del estudiante'),
          _buildInstructionItem('El código se procesará automáticamente'),
          _buildInstructionItem(
              'También puedes ingresar el código manualmente'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String instruction) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppTheme.getSmallPadding(screenSize) / 2),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              instruction,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputSection(AttendanceScannerProvider scannerProvider) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrada Manual',
            style: AppTheme.getBodyLarge(screenSize).copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Si el escáner físico no funciona, puedes ingresar la matrícula manualmente:',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualInputController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la matrícula del estudiante',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getMediumPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize),
                    ),
                  ),
                  enabled: !scannerProvider.isScanning ||
                      scannerProvider.state != ScannerState.processing,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              ElevatedButton(
                onPressed: (_manualInputController.text.isNotEmpty &&
                        (!scannerProvider.isScanning ||
                            scannerProvider.state != ScannerState.processing))
                    ? () {
                        scannerProvider.handlePhysicalScannerInput(
                            _manualInputController.text.trim());
                        _manualInputController.clear();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getMediumPadding(screenSize),
                    vertical: AppTheme.getMediumPadding(screenSize),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                ),
                child: const Text('Procesar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceScannerProvider provider) {
    switch (provider.state) {
      case ScannerState.scanning:
        return AppTheme.accentOrange;
      case ScannerState.processing:
        return AppTheme.accentBlue;
      case ScannerState.success:
        return AppTheme.successColor;
      case ScannerState.error:
        return AppTheme.errorColor;
      default:
        return AppTheme.accentOrange;
    }
  }

  IconData _getStatusIcon(AttendanceScannerProvider provider) {
    switch (provider.state) {
      case ScannerState.scanning:
        return Icons.scanner_rounded;
      case ScannerState.processing:
        return Icons.hourglass_empty;
      case ScannerState.success:
        return Icons.check_circle;
      case ScannerState.error:
        return Icons.error;
      default:
        return Icons.scanner_rounded;
    }
  }

  String _getStatusMessage(AttendanceScannerProvider provider) {
    switch (provider.state) {
      case ScannerState.scanning:
        return 'Esperando escaneo del dispositivo físico...';
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
