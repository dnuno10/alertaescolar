import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class EmptyNotificationsCard extends StatelessWidget {
  final Size screenSize;

  const EmptyNotificationsCard({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(
          AppTheme.getLargeRadius(screenSize),
        ),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenSize.height * 0.06,
            height: screenSize.height * 0.06,
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(screenSize),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.03,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.noNotifications,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            l10n.notificationsWillAppearHere,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
