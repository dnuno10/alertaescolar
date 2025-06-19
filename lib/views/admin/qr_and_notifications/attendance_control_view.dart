import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/attendance_scanner_provider.dart';
import '../../../components/admin/qr_and_notifications/attendance_control_header.dart';
import 'notification_send_view.dart';
import 'scanner_configuration_view.dart';
import 'camera_scanner_view.dart';
import 'physical_scanner_view.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../../l10n/app_localizations.dart';

class AttendanceControlView extends StatefulWidget {
  const AttendanceControlView({super.key});

  @override
  State<AttendanceControlView> createState() => _AttendanceControlViewState();
}

class _AttendanceControlViewState extends State<AttendanceControlView> {
  // Configuration variables
  TimeOfDay _morningStartTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _morningEndTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _afternoonStartTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _afternoonEndTime = const TimeOfDay(hour: 18, minute: 0);
  int _toleranceMinutes = 15;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Consumer2<ThemeProvider, AttendanceScannerProvider>(
      builder: (context, themeProvider, scannerProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Header
              SliverToBoxAdapter(
                child: AttendanceControlHeader(
                  isScanning: false, // Ya no manejamos el estado aquí
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
                    children: [
                      // Main Scanner Section
                      _buildMainScannerSection(context, screenSize, l10n),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Recent scans section
                      if (scannerProvider.scannedHistory.isNotEmpty)
                        _buildRecentScansSection(
                            context, screenSize, scannerProvider, l10n),
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

  Widget _buildMainScannerSection(
      BuildContext context, Size screenSize, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildScannerSelection(context, screenSize, l10n),
    );
  }

  Widget _buildScannerSelection(
      BuildContext context, Size screenSize, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        children: [
          // Scanner Options mejorados
          Column(
            children: [
              // Physical Scanner
              _buildEnhancedScannerOption(
                context: context,
                screenSize: screenSize,
                title: 'Escáner Físico',
                subtitle: 'Conectar dispositivo externo',
                description: 'Ideal para uso intensivo y profesional',
                icon: Icons.scanner_rounded,
                secondaryIcon: Icons.bluetooth_rounded,
                color: AppTheme.accentOrange,
                onTap: _navigateToPhysicalScanner,
              ),
              SizedBox(height: AppTheme.getLargePadding(screenSize)),
              // Camera Scanner
              _buildEnhancedScannerOption(
                context: context,
                screenSize: screenSize,
                title: 'Cámara del Dispositivo',
                subtitle: 'Escanear usando la cámara integrada',
                description: 'Rápido y preciso para códigos QR',
                icon: Icons.camera_alt_rounded,
                secondaryIcon: Icons.flash_on_rounded,
                color: AppTheme.accentBlue,
                onTap: _navigateToCameraScanner,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Información adicional
          Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getTextSecondaryColor(context).withOpacity(0.05),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              border: Border.all(
                color: AppTheme.getTextSecondaryColor(context).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: 20,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    'Selecciona el método de escaneo que prefieras. Ambos registran la asistencia automáticamente.',
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontSize:
                          AppTheme.getBodyMedium(screenSize).fontSize! * 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedScannerOption({
    required BuildContext context,
    required Size screenSize,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required IconData secondaryIcon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.08),
                color.withOpacity(0.03),
              ],
            ),
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header Row with Icons and Title
              Row(
                children: [
                  // Title and Secondary Icon Row
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Flexible(
                          child: Text(
                            title,
                            style: AppTheme.getH2(screenSize).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Secondary Icon and Arrow
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                secondaryIcon,
                                color: color,
                                size: 18,
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getSmallPadding(screenSize)),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: color,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Content Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getMediumPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize),
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Text(
                      subtitle,
                      style: AppTheme.getBodyLarge(screenSize).copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Description with icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                  // Status indicator
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getSmallPadding(screenSize),
                          vertical: AppTheme.getSmallPadding(screenSize) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: color,
                              size: 16,
                            ),
                            SizedBox(
                                width:
                                    AppTheme.getSmallPadding(screenSize) / 2),
                            Text(
                              'Tocar para usar',
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToCameraScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScannerView(
          onCodeScanned: _handleScannedCode,
        ),
      ),
    );
  }

  void _navigateToPhysicalScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhysicalScannerView(
          onCodeScanned: _handleScannedCode,
        ),
      ),
    );
  }

  Widget _buildRecentScansSection(BuildContext context, Size screenSize,
      AttendanceScannerProvider scannerProvider, AppLocalizations l10n) {
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
                        '${l10n.studentId}: $code',
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

  void _handleScannedCode(String code) {
    final l10n = AppLocalizations.of(context);
    final scannerProvider =
        Provider.of<AttendanceScannerProvider>(context, listen: false);

    // Process the scanned code through the provider
    scannerProvider.handlePhysicalScannerInput(code);
  }

  // Configuration and notification dialogs
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
        builder: (context) => const NotificationSendView(),
      ),
    );
  }
}
