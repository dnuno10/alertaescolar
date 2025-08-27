import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class SwitchOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final Function(bool) onChanged;
  final Color color;
  final Size screenSize;

  const SwitchOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: value
            ? color.withOpacity(0.05)
            : AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color:
              value ? color.withOpacity(0.3) : AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
            decoration: BoxDecoration(
              color: value
                  ? color.withOpacity(0.1)
                  : AppTheme.getBorderColor(context).withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: value ? color : AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.022,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  description,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
