import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final Size screenSize;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      title: Text(
        title,
        style: AppTheme.getSubtitle1(screenSize).copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      content: content,
      actions: actions,
    );
  }
}
