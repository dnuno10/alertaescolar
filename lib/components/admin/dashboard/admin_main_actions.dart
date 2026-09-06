import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../views/admin/qr_and_notifications/notification_send_view.dart';
import '../../../views/admin/schedule/schedule_management_view.dart';

class AdminMainActions extends StatelessWidget {
  final Size screenSize;

  const AdminMainActions({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.mainActions,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: screenSize.height * 0.004),
              Text(
                l10n.manageAnnouncementsAndSchedules,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Action Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        title: l10n.sendAnnouncement,
                        description: l10n.sendNotificationsToStudents,
                        icon: Icons.send_rounded,
                        gradient: [
                          AppTheme.accentOrange,
                          // ignore: deprecated_member_use
                          AppTheme.accentOrange.withOpacity(0.8)
                        ],
                        onTap: () => _navigateToNotificationSend(context),
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        title: l10n.viewSchedules,
                        description: l10n.manageClassSchedules,
                        icon: Icons.schedule_rounded,
                        gradient: [
                          AppTheme.accentBlue,
                          // ignore: deprecated_member_use
                          AppTheme.accentBlue.withOpacity(0.8)
                        ],
                        onTap: () => _navigateToScheduleManagement(context),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildActionCard(
                      context: context,
                      title: l10n.sendAnnouncement,
                      description: l10n.sendNotificationsToStudents,
                      icon: Icons.send_rounded,
                      gradient: [
                        AppTheme.accentOrange,
                        // ignore: deprecated_member_use
                        AppTheme.accentOrange.withOpacity(0.8)
                      ],
                      onTap: () => _navigateToNotificationSend(context),
                    ),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildActionCard(
                      context: context,
                      title: l10n.viewSchedules,
                      description: l10n.manageClassSchedules,
                      icon: Icons.schedule_rounded,
                      gradient: [
                        AppTheme.accentBlue,
                        // ignore: deprecated_member_use
                        AppTheme.accentBlue.withOpacity(0.8)
                      ],
                      onTap: () => _navigateToScheduleManagement(context),
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

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 1.5),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: gradient[0],
                size: screenSize.height * 0.03,
              ),

              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 1.2),

              // Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTheme.getBodyLarge(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                      softWrap: true,
                    ),

                    SizedBox(height: screenSize.height * 0.002),

                    // Description
                    Text(
                      description,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: screenSize.height * 0.016,
                color: gradient[0],
              ),
            ],
          ),
        ),
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
