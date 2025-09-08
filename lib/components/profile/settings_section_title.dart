import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;
  final Size screenSize;

  const SettingsSectionTitle({
    super.key,
    required this.title,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true, // ← accesibilidad
      child: Text(
        title,
        style: AppTheme.getSubtitle1(screenSize).copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimaryColor(context),
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
