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
    final pad = AppTheme.getMediumPadding(screenSize);
    final rad = AppTheme.getLargeRadius(screenSize);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          // Títulos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schoolName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.25),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
