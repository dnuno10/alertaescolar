import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'modern_time_selector.dart';

class ModernShiftSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(TimeOfDay) onStartChanged;
  final Function(TimeOfDay) onEndChanged;
  final Size screenSize;

  const ModernShiftSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: color.withOpacity(0.2)),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child:
                    Icon(icon, color: color, size: screenSize.height * 0.025),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                title,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: ModernTimeSelector(
                  label: l10n.entry,
                  time: startTime,
                  onTimeChanged: onStartChanged,
                  color: color,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: ModernTimeSelector(
                  label: l10n.exit,
                  time: endTime,
                  onTimeChanged: onEndChanged,
                  color: color,
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
