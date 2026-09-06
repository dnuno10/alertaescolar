import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class CurrentNameDisplayCard extends StatelessWidget {
  final Size screenSize;

  const CurrentNameDisplayCard({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: const [],
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.1,
            height: screenSize.width * 0.1,
            child: Icon(
              Icons.badge_outlined,
              color: AppTheme.accentBlue,
              size: screenSize.width * 0.05,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentFullName,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.currentUser;
                    return Container(
                      margin: EdgeInsets.only(
                          top: AppTheme.getSmallPadding(screenSize) * 0.25),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppTheme.accentBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Text(
                        user?.nombreCompleto ?? l10n.notAvailable,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
