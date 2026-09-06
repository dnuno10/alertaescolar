import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class PersonalDataInfoCard extends StatelessWidget {
  final List<Widget> children;
  final Size screenSize;

  const PersonalDataInfoCard({
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
        boxShadow: const [],
      ),
      child: Column(children: children),
    );
  }
}
