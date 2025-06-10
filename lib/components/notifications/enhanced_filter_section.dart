import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class EnhancedFilterSection extends StatelessWidget {
  final Size screenSize;
  final TabController tabController;
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const EnhancedFilterSection({
    super.key,
    required this.screenSize,
    required this.tabController,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = ['access_alerts', 'communications', 'all'];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getLargePadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categories,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Container(
            height: screenSize.height * 0.065,
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(
                AppTheme.getMediumRadius(screenSize),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: screenSize.height * 0.01,
                  offset: Offset(0, screenSize.height * 0.0025),
                ),
              ],
            ),
            child: TabBar(
              controller: tabController,
              labelColor: AppTheme.accentPurple,
              unselectedLabelColor: AppTheme.getTextSecondaryColor(context),
              indicatorColor: AppTheme.accentPurple,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTheme.getSubtitle2(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: AppTheme.getSubtitle2(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              dividerColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize) * 0.5,
              ),
              onTap: (index) => onFilterChanged(filters[index]),
              tabs: [
                Tab(text: l10n.accessAlerts),
                Tab(text: l10n.announcements),
                Tab(text: l10n.allNotifications),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
