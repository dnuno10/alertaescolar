import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/notification_provider.dart';
import 'nav_header.dart';

class NotificationHeader extends StatelessWidget {
  final Size screenSize;
  final int Function(List<dynamic>) getFilteredCount;
  final String Function(AppLocalizations) getFilterLabel;

  const NotificationHeader({
    super.key,
    required this.screenSize,
    required this.getFilteredCount,
    required this.getFilterLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Use NavHeader for consistency
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                      ),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: AppTheme.accentPurple,
                        size: screenSize.height * 0.03,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.notifications,
                            style: AppTheme.getH1(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Consumer<NotificationProvider>(
                            builder: (context, provider, child) {
                              final filteredCount =
                                  getFilteredCount(provider.notifications);
                              return Text(
                                '$filteredCount ${getFilterLabel(l10n)}',
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
