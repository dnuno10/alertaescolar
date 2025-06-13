import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class LoginFooterComponent extends StatelessWidget {
  const LoginFooterComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2F3E46);
    final Size size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.termsOfService,
            style: AppTheme.getCaption(size).copyWith(
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Container(
              height: size.height * 0.02,
              width: 2,
              color: textColor,
            ),
          ),
          Text(
            l10n.privacyPolicy,
            style: AppTheme.getCaption(size).copyWith(
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
