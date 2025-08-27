import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final IconData icon;
  final Size screenSize;

  const StatusCard({
    super.key,
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenSize.height * 0.02),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
          Text(
            title,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.2),
          Text(
            time,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
