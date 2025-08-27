import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class QuickStatsSection extends StatelessWidget {
  final Size screenSize;
  final List<Map<String, dynamic>> stats;

  const QuickStatsSection({
    super.key,
    required this.screenSize,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getSmallPadding(screenSize),
                horizontal: AppTheme.getSmallPadding(screenSize) * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.7),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: screenSize.height * 0.02,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    stat['title'] as String,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    stat['subtitle'] as String,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
