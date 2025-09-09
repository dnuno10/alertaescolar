// lib/components/school/info_section.dart
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Size screenSize;
  final List<Widget> children;

  const InfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.screenSize,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final rad = AppTheme.getLargeRadius(screenSize);
    final padHeader =
        AppTheme.getMediumPadding(screenSize); // header un poco más cómodo
    final border = AppTheme.getBorderColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(padHeader),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(rad),
                topRight: Radius.circular(rad),
              ),
              border: Border(
                bottom: BorderSide(color: border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getSubtitle1(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: AppTheme.getSmallPadding(screenSize),
              right: AppTheme.getSmallPadding(screenSize),
              bottom: AppTheme.getSmallPadding(screenSize),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
