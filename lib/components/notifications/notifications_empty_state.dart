import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class NotificationsEmptyState extends StatelessWidget {
  final Size screenSize;

  const NotificationsEmptyState({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize) * 1.5),
      margin: EdgeInsets.only(bottom: screenSize.height * 0.1),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenSize.height * 0.1,
            height: screenSize.height * 0.1,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: screenSize.height * 0.05,
              color: AppTheme.accentPurple,
            ),
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
          Text(
            l10n.noNotifications,
            style: AppTheme.getH2(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            l10n.notificationsWillAppearHere,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
