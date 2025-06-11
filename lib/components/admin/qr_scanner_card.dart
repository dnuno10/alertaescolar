import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class QRScannerCard extends StatelessWidget {
  final Size screenSize;
  final bool isScanning;
  final Animation<double> scaleAnimation;
  final VoidCallback onToggleScanning;
  final Function(Map<String, dynamic>) onStudentScanned;

  const QRScannerCard({
    super.key,
    required this.screenSize,
    required this.isScanning,
    required this.scaleAnimation,
    required this.onToggleScanning,
    required this.onStudentScanned,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        children: [
          // Scanner Header
          Row(
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.scanQR,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Scanner Interface
          AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                child: GestureDetector(
                  onTap: isScanning ? _simulateStudentScan : null,
                  child: Container(
                    width: screenSize.width * 0.5,
                    height: screenSize.width * 0.5,
                    decoration: BoxDecoration(
                      color: isScanning
                          ? AppTheme.accentBlue.withOpacity(0.1)
                          : AppTheme.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(screenSize)),
                      border: Border.all(
                        color: isScanning
                            ? AppTheme.accentBlue
                            : AppTheme.getBorderColor(context),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isScanning
                          ? Icons.qr_code_scanner_rounded
                          : Icons.qr_code_rounded,
                      size: screenSize.width * 0.15,
                      color: isScanning
                          ? AppTheme.accentBlue
                          : AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Status Text
          Text(
            isScanning ? l10n.scanningActive : l10n.readyToScan,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: isScanning
                  ? AppTheme.accentBlue
                  : AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Toggle Button
          SolidButton(
            backgroundColor:
                isScanning ? AppTheme.errorColor : AppTheme.accentBlue,
            onPressed: onToggleScanning,
            label: isScanning ? l10n.stopScanning : l10n.scanQR,
            icon: isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
            screenSize: screenSize,
            width: double.infinity,
          ),

          if (isScanning) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              'Toca el área del scanner para simular escaneo',
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _simulateStudentScan() {
    // Mock student data for simulation
    final mockStudents = [
      {
        'studentName': 'Ana García López',
        'studentId': 'EST001',
        'grade': '6° A',
        'status': 'present',
        'scanTime': 'Ahora',
      },
      {
        'studentName': 'Carlos Mendoza',
        'studentId': 'EST002',
        'grade': '5° B',
        'status': 'late',
        'scanTime': 'Ahora',
      },
      {
        'studentName': 'María Fernández',
        'studentId': 'EST003',
        'grade': '4° C',
        'status': 'present',
        'scanTime': 'Ahora',
      },
    ];

    // Select random student
    final randomStudent =
        mockStudents[DateTime.now().millisecond % mockStudents.length];

    // Call the callback with the mock data
    onStudentScanned(randomStudent);
  }
}
