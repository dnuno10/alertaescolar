import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/attendance_scanner_provider.dart';
import '../../../components/admin/qr_and_notifications/attendance_control_header.dart';
import 'attendance_scanner_method_view.dart';
import 'notification_send_view.dart';
import 'scanner_configuration_view.dart';

class AttendanceControlView extends StatefulWidget {
  const AttendanceControlView({super.key});

  @override
  State<AttendanceControlView> createState() => _AttendanceControlViewState();
}

class _AttendanceControlViewState extends State<AttendanceControlView>
    with TickerProviderStateMixin {
  // Configuration variables
  TimeOfDay _morningStartTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _morningEndTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _afternoonStartTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _afternoonEndTime = const TimeOfDay(hour: 18, minute: 0);
  int _toleranceMinutes = 15;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, AttendanceScannerProvider>(
      builder: (context, themeProvider, scannerProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Header - mantenemos el header existente
              SliverToBoxAdapter(
                child: AttendanceControlHeader(
                  isScanning: scannerProvider.isScanning,
                  screenSize: screenSize,
                  onConfigurationTap: _showConfigurationDialog,
                  onNotificationTap: _showNotificationDialog,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR Scanner Section - Nueva implementación moderna
                      _buildQRScannerSection(
                          context, screenSize, scannerProvider),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Recent scans section
                      if (scannerProvider.scannedHistory.isNotEmpty)
                        _buildRecentScansSection(
                            context, screenSize, scannerProvider),
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

  Widget _buildQRScannerSection(BuildContext context, Size screenSize,
      AttendanceScannerProvider scannerProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status indicator
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppTheme.accentBlue,
                  size: 32,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Control de Asistencia QR',
                      style: AppTheme.getH2(screenSize).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize) / 2),
                    Text(
                      scannerProvider.isScanning
                          ? 'Escaneando códigos QR...'
                          : 'Registra la asistencia de estudiantes',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: scannerProvider.isScanning
                            ? AppTheme.accentBlue
                            : AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              if (scannerProvider.isScanning)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Recent scan result indicator
          if (scannerProvider.successMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              margin: EdgeInsets.only(
                  bottom: AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.successColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      scannerProvider.successMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Error message indicator
          if (scannerProvider.errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              margin: EdgeInsets.only(
                  bottom: AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      scannerProvider.errorMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Scanner Buttons - LAS DOS OPCIONES DE ESCANEO
          Row(
            children: [
              // Camera Scanner Button
              Expanded(
                child: _buildScannerButton(
                  context: context,
                  screenSize: screenSize,
                  title: 'Cámara',
                  subtitle: 'Usar cámara del dispositivo',
                  icon: Icons.camera_alt_rounded,
                  color: AppTheme.accentBlue,
                  scannerType: ScannerType.camera,
                  onTap: () => _navigateToCameraScanner(context),
                ),
              ),

              SizedBox(width: AppTheme.getMediumPadding(screenSize)),

              // Physical Scanner Button
              Expanded(
                child: _buildScannerButton(
                  context: context,
                  screenSize: screenSize,
                  title: 'Escáner Físico',
                  subtitle: 'Usar dispositivo externo',
                  icon: Icons.scanner_rounded,
                  color: AppTheme.accentOrange,
                  scannerType: ScannerType.physical,
                  onTap: () => _navigateToPhysicalScanner(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerButton({
    required BuildContext context,
    required Size screenSize,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required ScannerType scannerType,
    required VoidCallback onTap,
  }) {
    return Consumer<AttendanceScannerProvider>(
      builder: (context, scannerProvider, child) {
        bool isLoading = scannerProvider.isScanning &&
            scannerProvider.selectedScannerType == scannerType;
        bool isActive = scannerProvider.selectedScannerType == scannerType;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: scannerProvider.isScanning && !isActive ? null : onTap,
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              child: Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withOpacity(0.15)
                      : color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  border: Border.all(
                    color: isActive
                        ? color.withOpacity(0.5)
                        : color.withOpacity(0.2),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with loading state
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isActive
                            ? color.withOpacity(0.2)
                            : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            )
                          : Icon(
                              icon,
                              color: color,
                              size: 28,
                            ),
                    ),

                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                    // Title
                    Text(
                      title,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? color
                            : AppTheme.getTextPrimaryColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppTheme.getSmallPadding(screenSize) / 2),

                    // Subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? color.withOpacity(0.8)
                            : AppTheme.getTextSecondaryColor(context),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentScansSection(BuildContext context, Size screenSize,
      AttendanceScannerProvider scannerProvider) {
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
            blurRadius: 8,
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
                Icons.history_rounded,
                color: AppTheme.accentBlue,
                size: 20,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Escaneos Recientes',
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ...scannerProvider.scannedHistory
              .take(5)
              .map(
                (code) => Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(screenSize) / 2),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Text(
                        'Matrícula: $code',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  void _navigateToCameraScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceScannerMethodView(),
      ),
    ).then((_) {
      // Clear messages when returning from scanner
      final scannerProvider =
          Provider.of<AttendanceScannerProvider>(context, listen: false);
      scannerProvider.clearMessages();
    });
  }

  void _navigateToPhysicalScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceScannerMethodView(),
      ),
    ).then((_) {
      // Clear messages when returning from scanner
      final scannerProvider =
          Provider.of<AttendanceScannerProvider>(context, listen: false);
      scannerProvider.clearMessages();
    });
  }

  void _showConfigurationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerConfigurationView(
          morningStartTime: _morningStartTime,
          morningEndTime: _morningEndTime,
          afternoonStartTime: _afternoonStartTime,
          afternoonEndTime: _afternoonEndTime,
          toleranceMinutes: _toleranceMinutes,
          onSave: (morningStart, morningEnd, afternoonStart, afternoonEnd,
              tolerance) {
            setState(() {
              _morningStartTime = morningStart;
              _morningEndTime = morningEnd;
              _afternoonStartTime = afternoonStart;
              _afternoonEndTime = afternoonEnd;
              _toleranceMinutes = tolerance;
            });
          },
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationSendView(),
      ),
    );
  }
}
