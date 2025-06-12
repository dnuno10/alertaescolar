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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
                topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
              border: Border(
                bottom: BorderSide(
                  color: color.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  title,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
