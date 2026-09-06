import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Size screenSize;

  const SectionContainer({
    super.key,
    required this.title,
    required this.child,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
            boxShadow: const [],
          ),
          child: child,
        ),
      ],
    );
  }
}
