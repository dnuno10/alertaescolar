import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';

class DirectoryStatsCard extends StatelessWidget {
  final Size screenSize;
  final List<Alumno> allStudents;
  final List<Alumno> filteredStudents;

  const DirectoryStatsCard({
    super.key,
    required this.screenSize,
    required this.allStudents,
    required this.filteredStudents,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeStudents = allStudents.where((s) => s.activo).length;
    final inactiveStudents = allStudents.length - activeStudents;
    final newThisMonth = allStudents.where((s) {
      final now = DateTime.now();
      final monthAgo = DateTime(now.year, now.month - 1, now.day);
      return s.fechaRegistro.isAfter(monthAgo);
    }).length;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.directoryStats,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.totalStudents,
                  allStudents.length.toString(),
                  Icons.people_rounded,
                  AppTheme.accentBlue,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.activeStudents,
                  activeStudents.toString(),
                  Icons.check_circle_rounded,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.inactiveStudents,
                  inactiveStudents.toString(),
                  Icons.pause_circle_rounded,
                  AppTheme.warningColor,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.newThisMonth,
                  newThisMonth.toString(),
                  Icons.person_add_rounded,
                  AppTheme.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: screenSize.width * 0.08,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            value,
            style: AppTheme.getH2(screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
