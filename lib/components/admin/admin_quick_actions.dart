import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../views/admin/attendance_control_view.dart';
import '../../views/admin/students_directory_view.dart';
import '../../views/admin/announcements_view.dart';
import '../../views/admin/schedule_management_view.dart';

class AdminQuickActions extends StatelessWidget {
  final Size screenSize;

  const AdminQuickActions({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: AppTheme.getH2(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Container(
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
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      title: l10n.attendanceControl,
                      subtitle: l10n.scanQR,
                      color: AppTheme.accentBlue,
                      screenSize: screenSize,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AttendanceControlView(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.people_rounded,
                      title: l10n.studentsDirectory,
                      subtitle: l10n.searchStudents,
                      color: AppTheme.successColor,
                      screenSize: screenSize,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentsDirectoryView(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.campaign_rounded,
                      title: l10n.announcements,
                      subtitle: l10n.createAnnouncement,
                      color: AppTheme.accentPurple,
                      screenSize: screenSize,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnnouncementsView(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.schedule_rounded,
                      title: l10n.scheduleManagement,
                      subtitle: l10n.configureSchedules,
                      color: AppTheme.warningColor,
                      screenSize: screenSize,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduleManagementView(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Size screenSize;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screenSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                title,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenSize.height * 0.002),
              Text(
                subtitle,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontSize: screenSize.height * 0.014,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
