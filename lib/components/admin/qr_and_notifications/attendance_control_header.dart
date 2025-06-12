import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'scanning_status_indicator.dart';
import 'action_button.dart';

class AttendanceControlHeader extends StatelessWidget {
  final bool isScanning;
  final Size screenSize;
  final VoidCallback onConfigurationTap;
  final VoidCallback onNotificationTap;

  const AttendanceControlHeader({
    super.key,
    required this.isScanning,
    required this.screenSize,
    required this.onConfigurationTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            AppTheme.getSmallPadding(screenSize),
        left: AppTheme.getMediumPadding(screenSize),
        right: AppTheme.getMediumPadding(screenSize),
        bottom: AppTheme.getLargePadding(screenSize),
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Actions Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.attendanceControl,
                      style: AppTheme.getH1(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      l10n.scanQRToRegisterAttendance,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Row(
                children: [
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  // Status indicator
                  ScanningStatusIndicator(
                      isScanning: isScanning, screenSize: screenSize),
                ],
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          Row(
            children: [
              ActionButton(
                  color: AppTheme.accentBlue,
                  icon: Icons.settings_rounded,
                  onTap: onConfigurationTap,
                  screenSize: screenSize),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              // Notification button
              ActionButton(
                color: AppTheme.accentOrange,
                icon: Icons.notifications_rounded,
                onTap: onNotificationTap,
                screenSize: screenSize,
                label: l10n.sendNotification,
              ),
            ],
          )
        ],
      ),
    );
  }
}
