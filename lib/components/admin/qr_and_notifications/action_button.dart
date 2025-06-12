import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Size screenSize;

  const ActionButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.screenSize,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: screenSize.height * 0.025,
                ),
                if (label != null) ...[
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    label!,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: color,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
