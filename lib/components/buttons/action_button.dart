import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Size screenSize;

  const ActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(color: AppTheme.getBorderColor(context)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: screenSize.height * 0.015,
              offset: Offset(0, screenSize.height * 0.005),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: screenSize.height * 0.07,
              height: screenSize.height * 0.07,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: screenSize.height * 0.035,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              title,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
