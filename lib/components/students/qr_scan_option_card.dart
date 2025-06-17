import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class QRScanOptionCard extends StatelessWidget {
  final VoidCallback onTap;
  final Size screenSize;

  const QRScanOptionCard({
    super.key,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Column(
              children: [
                Container(
                  width: screenSize.width * 0.2,
                  height: screenSize.width * 0.2,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppTheme.accentPurple,
                    size: screenSize.width * 0.1,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                Text(
                  l10n.scanQRCode,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  l10n.useCameraToScanQR,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.008),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: AppTheme.accentPurple,
                        size: AppTheme.getSmallPadding(screenSize),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Text(
                        'Toca para abrir cámara',
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.accentPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
