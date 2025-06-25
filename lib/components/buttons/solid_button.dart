import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SolidButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? fontColor;
  final Size screenSize;
  final double? width;

  const SolidButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.screenSize,
    this.width,
    this.fontColor,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppTheme.accentPurple,
      foregroundColor: AppTheme.onPrimaryColor,
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(screenSize),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppTheme.getSmallRadius(screenSize),
        ),
      ),
    );

    final textStyle = DefaultTextStyle.merge(
      style: AppTheme.getCaptionSmall(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: fontColor ?? AppTheme.onPrimaryColor,
      ),
      child: Text(
        label,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          fontWeight: FontWeight.w600,
          color: fontColor ?? AppTheme.onPrimaryColor,
          letterSpacing: 0.1,
        ),
      ),
    );

    return SizedBox(
      width: width,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onPressed();
              },
              icon: Icon(
                icon,
                size: screenSize.width * 0.045,
                color: AppTheme.onPrimaryColor,
              ),
              label: textStyle,
              style: buttonStyle,
            )
          : ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onPressed();
              },
              child: textStyle,
              style: buttonStyle,
            ),
    );
  }
}
