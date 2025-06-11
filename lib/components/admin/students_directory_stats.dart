import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class StudentsDirectoryStats extends StatelessWidget {
  final Size screenSize;

  const StudentsDirectoryStats({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Mock data for directory statistics
    final stats = {
      'totalStudents': 385,
      'activeStudents': 378,
      'inactiveStudents': 7,
      'newThisMonth': 12,
      'grades': 6,
      'groups': 18,
    };

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.directoryStats ?? 'Estadísticas del directorio',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Main stats grid
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _MainStatCard(
                  value: stats['totalStudents'].toString(),
                  label: l10n.totalStudents ?? 'Total estudiantes',
                  icon: Icons.groups_rounded,
                  color: AppTheme.accentBlue,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _StatCard(
                  value: stats['activeStudents'].toString(),
                  label: l10n.activeStudents,
                  color: AppTheme.successColor,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _StatCard(
                  value: stats['inactiveStudents'].toString(),
                  label: l10n.inactiveStudents,
                  color: AppTheme.errorColor,
                  screenSize: screenSize,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Secondary stats
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SecondaryStatItem(
                    icon: Icons.fiber_new_rounded,
                    value: stats['newThisMonth'].toString(),
                    label: l10n.newThisMonth ?? 'Nuevos este mes',
                    color: AppTheme.accentPurple,
                    screenSize: screenSize,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: _SecondaryStatItem(
                    icon: Icons.school_rounded,
                    value: stats['grades'].toString(),
                    label: l10n.grades ?? 'Grados',
                    color: AppTheme.warningColor,
                    screenSize: screenSize,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: _SecondaryStatItem(
                    icon: Icons.class_rounded,
                    value: stats['groups'].toString(),
                    label: l10n.groups ?? 'Grupos',
                    color: AppTheme.successColor,
                    screenSize: screenSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Size screenSize;

  const _MainStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: screenSize.height * 0.04,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTheme.getH1(screenSize).copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Size screenSize;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.getH2(screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            label,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SecondaryStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Size screenSize;

  const _SecondaryStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: screenSize.height * 0.025,
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
