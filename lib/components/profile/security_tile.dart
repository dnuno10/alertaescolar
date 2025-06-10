import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Size screenSize;

  const SecurityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.1,
            height: screenSize.width * 0.1,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: color,
              size: screenSize.width * 0.05,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
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
