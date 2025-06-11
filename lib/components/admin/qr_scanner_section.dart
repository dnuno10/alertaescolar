import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class QRScannerSection extends StatefulWidget {
  final Size screenSize;

  const QRScannerSection({
    super.key,
    required this.screenSize,
  });

  @override
  State<QRScannerSection> createState() => _QRScannerSectionState();
}

class _QRScannerSectionState extends State<QRScannerSection>
    with TickerProviderStateMixin {
  bool _isScanning = false;
  late AnimationController _scanningController;
  late Animation<double> _scanningAnimation;
  String? _lastScannedStudent;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _scanningController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanningAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanningController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scanningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: widget.screenSize.height * 0.015,
            offset: Offset(0, widget.screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppTheme.accentBlue,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Text(
                l10n.attendanceControl,
                style: AppTheme.getH2(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // QR Scanner Area
          _buildScannerArea(context, l10n),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Last Scan Info
          if (_lastScannedStudent != null) _buildLastScanInfo(context, l10n),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Scan Button
          SolidButton(
            backgroundColor: _isScanning ? AppTheme.errorColor : AppTheme.accentBlue,
            onPressed: _toggleScanning,
            label: _isScanning ? l10n.stopScanning ?? 'Detener escaneo' : l10n.scanQR,
            icon: _isScanning ? Icons.stop_rounded : Icons.qr_code_scanner_rounded,
            screenSize: widget.screenSize,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerArea(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: widget.screenSize.height * 0.25,
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        border: Border.all(
          color: _isScanning 
              ? AppTheme.accentBlue 
              : AppTheme.getBorderColor(context),
          width: _isScanning ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Scanner visual
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _scanningAnimation,
                  builder: (context, child) {
                    return Container(
                      width: widget.screenSize.height * 0.12,
                      height: widget.screenSize.height * 0.12,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isScanning 
                              ? AppTheme.accentBlue.withOpacity(0.5 + _scanningAnimation.value * 0.5)
                              : AppTheme.getTextSecondaryColor(context),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(widget.screenSize)),
                      ),
                      child: Icon(
                        Icons.qr_code_rounded,
                        color: _isScanning 
                            ? AppTheme.accentBlue 
                            : AppTheme.getTextSecondaryColor(context),
                        size: widget.screenSize.height * 0.06,
                      ),
                    );
                  },
                ),
                SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
                Text(
                  _isScanning 
                      ? l10n.scanningActive ?? 'Escaneo activo...'
                      : l10n.readyToScan ?? 'Listo para escanear',
                  style: AppTheme.getCaption(widget.screenSize).copyWith(
                    color: _isScanning 
                        ? AppTheme.accentBlue 
                        : AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Scanning line animation
          if (_isScanning)
            AnimatedBuilder(
              animation: _scanningAnimation,
              builder: (context, child) {
                return Positioned(
                  top: widget.screenSize.height * 0.05 + 
                       (widget.screenSize.height * 0.15) * _scanningAnimation.value,
                  left: AppTheme.getMediumPadding(widget.screenSize),
                  right: AppTheme.getMediumPadding(widget.screenSize),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentBlue.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLastScanInfo(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppTheme.successColor,
            size: widget.screenSize.height * 0.025,
          ),
          SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lastStudentScanned ?? 'Último estudiante escaneado',
                  style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _lastScannedStudent!,
                  style: AppTheme.getCaption(widget.screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_lastScanTime != null)
                  Text(
                    '${l10n.scanTime}: ${_formatTime(_lastScanTime!)}',
                    style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _scanningController.repeat();
      // Simulate a scan after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_isScanning && mounted) {
          _simulateScan();
        }
      });
    } else {
      _scanningController.stop();
    }
  }

  void _simulateScan() {
    final students = [
      'Ana García Martínez (3°A)',
      'Carlos Rodríguez Silva (2°B)',
      'Sofía González Pérez (1°A)',
      'Miguel Torres López (3°A)',
      'Isabella Hernández Cruz (2°B)',
    ];

    setState(() {
      _lastScannedStudent = students[DateTime.now().millisecond % students.length];
      _lastScanTime = DateTime.now();
      _isScanning = false;
    });

    _scanningController.stop();
    _scanningController.reset();

    // Show success message
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.attendanceRegistered,
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize)),
          ),
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
