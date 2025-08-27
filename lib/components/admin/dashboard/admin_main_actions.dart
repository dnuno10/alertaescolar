import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../views/admin/qr_and_notifications/notification_send_view.dart';
import '../../../views/admin/schedule/schedule_management_view.dart';
import 'admin_action_card.dart';

class AdminMainActions extends StatelessWidget {
  final Size screenSize;

  const AdminMainActions({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // Non-null assertion added

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withOpacity(0.1),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.mainActions, // Replaced with localization key
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.manageAnnouncementsAndSchedules, // Replaced with localization key
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Action buttons
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      child: AdminActionCard(
                        title: l10n
                            .sendAnnouncement, // Replaced with localization key
                        description: l10n
                            .sendNotificationsToStudents, // Replaced with localization key
                        icon: Icons.send_rounded,
                        color: AppTheme.accentOrange,
                        onTap: () => _navigateToNotificationSend(context),
                        screenSize: screenSize,
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      child: AdminActionCard(
                        title: l10n
                            .viewSchedules, // Replaced with localization key
                        description: l10n
                            .manageClassSchedules, // Replaced with localization key
                        icon: Icons.schedule_rounded,
                        color: AppTheme.accentBlue,
                        onTap: () => _navigateToScheduleManagement(context),
                        screenSize: screenSize,
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile layout - vertical
                return Column(
                  children: [
                    AdminActionCard(
                      title: l10n
                          .sendAnnouncement, // Replaced with localization key
                      description: l10n
                          .sendNotificationsToStudents, // Replaced with localization key
                      icon: Icons.send_rounded,
                      color: AppTheme.accentOrange,
                      onTap: () => _navigateToNotificationSend(context),
                      screenSize: screenSize,
                    ),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    AdminActionCard(
                      title:
                          l10n.viewSchedules, // Replaced with localization key
                      description: l10n
                          .manageClassSchedules, // Replaced with localization key
                      icon: Icons.schedule_rounded,
                      color: AppTheme.accentBlue,
                      onTap: () => _navigateToScheduleManagement(context),
                      screenSize: screenSize,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToNotificationSend(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSendView(
          preselectedType: 'comunicado',
        ),
      ),
    );
  }

  void _navigateToScheduleManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScheduleManagementView(),
      ),
    );
  }
}
