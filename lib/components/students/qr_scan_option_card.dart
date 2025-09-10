import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class QRScanOptionCard extends StatelessWidget {
  /// onTap puede ser null para representar estado “deshabilitado”
  final VoidCallback? onTap;

  const QRScanOptionCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    final borderRadius = BorderRadius.circular(AppTheme.getMediumRadius(size));

    final content = Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      child: Column(
        children: [
          Container(
            width: size.width * 0.2,
            height: size.width * 0.2,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(size)),
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: AppTheme.accentPurple,
              size: size.width * 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(size)),
          Text(
            l10n.scanQRCode,
            style: AppTheme.getSubtitle1(size).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            l10n.useCameraToScanQR,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.008),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(size),
              vertical: AppTheme.getSmallPadding(size) * 0.5,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(size),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: AppTheme.accentPurple,
                  size: AppTheme.getSmallPadding(size),
                ),
                SizedBox(width: AppTheme.getSmallPadding(size) * 0.5),
                Text(
                  // Añade esta key al ARB: tapToOpenCamera
                  l10n.tapToOpenCamera,
                  style: AppTheme.getCaption(size).copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: borderRadius,
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
        clipBehavior: Clip.antiAlias, // el ripple respeta el radio
        borderRadius: borderRadius,
        child: Semantics(
          button: true,
          enabled: onTap != null,
          label: l10n.scanQRCode,
          hint: l10n.useCameraToScanQR,
          child: InkWell(
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    onTap!();
                  },
            borderRadius: borderRadius,
            child: Opacity(
              opacity:
                  onTap == null ? 0.6 : 1.0, // feedback visual deshabilitado
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
