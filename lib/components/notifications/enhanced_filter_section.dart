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
    final rad = AppTheme.getMediumRadius(screenSize);

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
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Container(
            height: screenSize.height * 0.06,
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(rad),
              border:
                  Border.all(color: AppTheme.getBorderColor(context), width: 1),
            ),
            child: TabBar(
              controller: tabController,
              onTap: (i) => onFilterChanged(filters[i]),
              labelPadding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
              ),
              indicator: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.accentPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(rad - 4),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppTheme.accentPurple.withOpacity(0.35),
                  width: 1,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppTheme.accentPurple,
              unselectedLabelColor: AppTheme.getTextSecondaryColor(context),
              dividerColor: Colors.transparent,
              labelStyle: AppTheme.getSubtitle2(screenSize).copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: AppTheme.getSubtitle2(screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
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
