import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class DescriptionSection extends StatelessWidget {
  final String description;
  final Size screenSize;

  const DescriptionSection({
    super.key,
    required this.description,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
                topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: AppTheme.warningColor,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  l10n.aboutSchool,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Text(
              description,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
