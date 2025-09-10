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
    final rad = AppTheme.getMediumRadius(screenSize);
    final pad = AppTheme.getSmallPadding(screenSize);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            _buildStatItem(context, stats[i], rad, pad),
            if (i <
                stats.length -
                    1) // No agregar espacio después del último elemento
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, Map<String, dynamic> stat, double rad, double pad) {
    final Color c = stat['color'] as Color;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(screenSize),
        horizontal: AppTheme.getSmallPadding(screenSize),
      ),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          // Ícono con fondo sutil
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(screenSize),
              ),
              // ignore: deprecated_member_use
              border: Border.all(color: c.withOpacity(0.25), width: 1),
            ),
            child: Icon(
              stat['icon'] as IconData,
              color: c,
              size: screenSize.height * 0.024,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          // Texto expandido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  stat['subtitle'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
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
