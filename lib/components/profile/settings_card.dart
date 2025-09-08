import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Size screenSize;

  const SettingsCard({
    super.key,
    required this.children,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.getMediumRadius(screenSize));
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias, // ← el splash no se sale de la card
        child: Column(children: children),
      ),
    );
  }
}
