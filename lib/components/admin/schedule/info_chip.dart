import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Size screenSize;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: screenSize.width * 0.035,
            color: color,
          ),
          SizedBox(width: screenSize.width * 0.01),
          Flexible(
            child: Text(
              text,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
