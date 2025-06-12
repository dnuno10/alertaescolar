import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final Size screenSize;

  const StatusChip({
    super.key,
    required this.text,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.5,
        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize) * 0.5),
      ),
      child: Text(
        text,
        style: AppTheme.getCaptionSmall(screenSize).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
