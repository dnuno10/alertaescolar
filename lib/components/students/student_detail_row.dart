import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class StudentDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Size screenSize;

  const StudentDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getContainerBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.1,
            height: screenSize.width * 0.1,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(screenSize) * 0.8),
            ),
            child: Icon(
              icon,
              size: screenSize.width * 0.05,
              color: iconColor,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  value,
                  style: AppTheme.getSubtitle2(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
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
