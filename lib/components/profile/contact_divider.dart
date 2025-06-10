import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ContactDivider extends StatelessWidget {
  final Size screenSize;

  const ContactDivider({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize)),
      color: AppTheme.getDividerColor(context),
    );
  }
}
