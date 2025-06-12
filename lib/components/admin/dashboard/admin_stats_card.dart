import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class AdminStatsCard extends StatelessWidget {
  final Size screenSize;

  const AdminStatsCard({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.1),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, screenSize.height * 0.008),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with modern design
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Text(
                  '31',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Text(
                l10n.todayAttendance,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Stats items with improved layout
          Row(
            children: [
              Expanded(
                child: _ModernStatItem(
                  icon: Icons.qr_code_2_rounded,
                  color: AppTheme.accentBlue,
                  value: '245',
                  label: 'Total Escaneados',
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: _ModernStatItem(
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successColor,
                  value: '230',
                  label: 'Estudiantes Presentes',
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: _ModernStatItem(
                  icon: Icons.schedule_rounded,
                  color: AppTheme.warningColor,
                  value: '15',
                  label: 'Estudiantes Tarde',
                  screenSize: screenSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModernStatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final Size screenSize;

  const _ModernStatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular icon container
        Container(
          width: screenSize.width * 0.15,
          height: screenSize.width * 0.15,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: screenSize.width * 0.07,
          ),
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Value with larger, bold typography
        Text(
          value,
          style: AppTheme.getH1(screenSize).copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),

        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

        // Label with proper spacing
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
