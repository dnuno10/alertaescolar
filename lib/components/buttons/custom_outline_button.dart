import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color color;
  final Size screenSize;
  final bool isExpanded;

  const CustomOutlineButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.color,
    required this.screenSize,
    this.icon,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: AppTheme.getSmallPadding(screenSize),
        ),
        side: BorderSide(color: color, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(screenSize),
          ),
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: screenSize.width * 0.045, color: color),
                SizedBox(width: screenSize.width * 0.02),
                DefaultTextStyle.merge(
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  child: Text(
                    label,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            )
          : DefaultTextStyle.merge(
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              child: Text(
                label,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
    );

    return isExpanded ? Expanded(child: button) : button;
  }
}
