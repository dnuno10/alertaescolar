import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';

class DialogActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Size screenSize;

  const DialogActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.screenSize,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor ??
            (backgroundColor != null ? AppTheme.onPrimaryColor : null),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
      ),
      child: Text(
        label,
        style: AppTheme.getCaption(screenSize).copyWith(
          fontWeight: FontWeight.w600,
          color: textColor ??
              (backgroundColor != null
                  ? AppTheme.onPrimaryColor
                  : AppTheme.getTextSecondaryColor(context)),
        ),
      ),
    );
  }
}
