import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/attendance_scanner_provider.dart';
import 'attendance_camera_scanner_view.dart';
import 'attendance_physical_scanner_view.dart';

class AttendanceScannerMethodView extends StatelessWidget {
  const AttendanceScannerMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Seleccionar Método de Escaneo',
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header description
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.accentBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.accentBlue,
                        size: 24,
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        child: Text(
                          'Selecciona el método de escaneo que prefieras usar para registrar la asistencia de los estudiantes.',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.getLargePadding(screenSize)),

                // Scanner method options
                Expanded(
                  child: Column(
                    children: [
                      // Camera Scanner Option
                      _buildScannerOption(
                        context: context,
                        screenSize: screenSize,
                        title: 'Cámara del Dispositivo',
                        description:
                            'Usar la cámara del teléfono para escanear códigos QR',
                        icon: Icons.camera_alt_rounded,
                        color: AppTheme.accentBlue,
                        onTap: () => _navigateToCameraScanner(context),
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Physical Scanner Option
                      _buildScannerOption(
                        context: context,
                        screenSize: screenSize,
                        title: 'Escáner Físico',
                        description:
                            'Usar un dispositivo escáner físico de códigos de barras/QR',
                        icon: Icons.scanner_rounded,
                        color: AppTheme.accentOrange,
                        onTap: () => _navigateToPhysicalScanner(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerOption({
    required BuildContext context,
    required Size screenSize,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Consumer<AttendanceScannerProvider>(
      builder: (context, scannerProvider, child) {
        bool isLoading = scannerProvider.isScanning;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
                border: Border.all(
                  color: isLoading
                      ? Colors.grey.withOpacity(0.3)
                      : color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isLoading
                          ? Colors.grey.withOpacity(0.1)
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isLoading
                        ? Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          )
                        : Icon(
                            icon,
                            color: color,
                            size: 40,
                          ),
                  ),

                  SizedBox(width: AppTheme.getLargePadding(screenSize)),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.getBodyLarge(screenSize).copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLoading
                                ? Colors.grey
                                : AppTheme.getTextPrimaryColor(context),
                          ),
                        ),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                        Text(
                          description,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: isLoading
                                ? Colors.grey
                                : AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isLoading ? Colors.grey : color,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCameraScanner(BuildContext context) {
    final scannerProvider =
        Provider.of<AttendanceScannerProvider>(context, listen: false);
    scannerProvider.selectScannerType(ScannerType.camera);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceCameraScannerView(),
      ),
    );
  }

  void _navigateToPhysicalScanner(BuildContext context) {
    final scannerProvider =
        Provider.of<AttendanceScannerProvider>(context, listen: false);
    scannerProvider.selectScannerType(ScannerType.physical);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendancePhysicalScannerView(),
      ),
    );
  }
}
