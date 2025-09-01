import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class SchoolHeaderCard extends StatelessWidget {
  final String schoolName;
  final String subtitle;
  final Size screenSize;

  const SchoolHeaderCard({
    super.key,
    required this.schoolName,
    required this.subtitle,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, screenSize.height * 0.01),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Title with enhanced typography
          Text(
            schoolName,
            style: AppTheme.getH1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Subtitle with modern badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getMediumPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              border: Border.all(
                color: AppTheme.accentBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              subtitle,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
