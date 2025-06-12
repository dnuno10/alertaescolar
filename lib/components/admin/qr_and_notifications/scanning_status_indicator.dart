import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ScanningStatusIndicator extends StatelessWidget {
  final bool isScanning;
  final Size screenSize;

  const ScanningStatusIndicator({
    super.key,
    required this.isScanning,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
      ),
      decoration: BoxDecoration(
        color: isScanning
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: isScanning
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenSize.height * 0.012,
            height: screenSize.height * 0.012,
            decoration: BoxDecoration(
              color: isScanning
                  ? AppTheme.successColor
                  : AppTheme.getTextSecondaryColor(context),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            isScanning ? l10n.scanning : l10n.inactive,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: isScanning
                  ? AppTheme.successColor
                  : AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
