import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ContactInfoCard extends StatelessWidget {
  final List<Widget> children;
  final Size screenSize;

  const ContactInfoCard({
    super.key,
    required this.children,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: const [],
      ),
      child: Column(children: children),
    );
  }
}
