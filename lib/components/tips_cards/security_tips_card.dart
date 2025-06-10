import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SecurityTipsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final Size screenSize;

  const SecurityTipsCard({
    super.key,
    required this.l10n,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.securityTips,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildSecurityTip(context, l10n.securityTip1),
          _buildSecurityTip(context, l10n.securityTip2),
          _buildSecurityTip(context, l10n.securityTip3),
          _buildSecurityTip(context, l10n.securityTip4),
        ],
      ),
    );
  }

  Widget _buildSecurityTip(BuildContext context, String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenSize.width * 0.015,
            height: screenSize.width * 0.015,
            margin: EdgeInsets.only(top: screenSize.height * 0.01),
            decoration: const BoxDecoration(
              color: AppTheme.accentPurple,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              tip,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
