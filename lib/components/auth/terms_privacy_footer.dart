import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsPrivacyFooter extends StatelessWidget {
  const TermsPrivacyFooter({
    super.key,
    required this.size,
    this.termsRoute = AppRoutes.terms, // '/terms'
    this.privacyRoute = AppRoutes.privacy, // '/privacy'
    this.verticalPaddingFactor = 1.0, // permite ajustar padding si quieres
    this.accentColor,
  });

  final Size size;
  final String termsRoute;
  final String privacyRoute;
  final double verticalPaddingFactor;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dividerColor =
        AppTheme.getTextSecondaryColor(context).withOpacity(0.3);
    final accent = accentColor ?? AppTheme.accentPurple;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.getMediumPadding(size) * verticalPaddingFactor,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.getBorderColor(context).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(context, termsRoute);
            },
            child: Text(
              l10n.termsOfService,
              style: AppTheme.getCaptionSmall(size).copyWith(
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(size),
            ),
            child: Container(
              height: size.height * 0.015,
              width: 1,
              color: dividerColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(context, privacyRoute);
            },
            child: Text(
              l10n.privacyPolicy,
              style: AppTheme.getCaptionSmall(size).copyWith(
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
