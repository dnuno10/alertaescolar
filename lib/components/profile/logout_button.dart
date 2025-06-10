import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  final Size screenSize;

  const LogoutButton({
    super.key,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          gradient: LinearGradient(
            colors: [
              AppTheme.errorColor.withOpacity(0.05),
              AppTheme.errorColor.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppTheme.errorColor.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            splashColor: AppTheme.errorColor.withOpacity(0.1),
            highlightColor: AppTheme.errorColor.withOpacity(0.05),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getMediumPadding(screenSize),
                horizontal: AppTheme.getMediumPadding(screenSize),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.5),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      Icons.logout_outlined,
                      size: screenSize.width * 0.05,
                      color: AppTheme.errorColor,
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Text(
                    l10n.signOut,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppTheme.errorColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
