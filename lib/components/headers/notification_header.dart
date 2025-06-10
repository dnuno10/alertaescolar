import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/notification_provider.dart';

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
      child: Container(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notifications,
                          style: AppTheme.getH1(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        Consumer<NotificationProvider>(
                          builder: (context, provider, child) {
                            final filteredCount =
                                getFilteredCount(provider.notifications);
                            return Text(
                              '$filteredCount ${getFilterLabel(l10n)}',
                              style: AppTheme.getSubtitle1(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
