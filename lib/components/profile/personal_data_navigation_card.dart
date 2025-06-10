import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class PersonalDataNavigationCard extends StatelessWidget {
  final List<Widget> children;
  final Size screenSize;

  const PersonalDataNavigationCard({
    super.key,
    required this.children,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
