import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  final Size screenSize;
  final bool enabled;

  const LogoutButton({
    super.key,
    required this.onTap,
    required this.screenSize,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppTheme.getMediumRadius(screenSize));

    final textColor =
        enabled ? AppTheme.errorColor : AppTheme.errorColor.withOpacity(0.6);

    return Semantics(
      button: true,
      label: l10n.signOut,
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
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
            borderRadius: radius,
            clipBehavior: Clip.antiAlias, // ← ripple no se sale del borde
            child: InkWell(
              onTap: enabled
                  ? () {
                      HapticFeedback.mediumImpact();
                      onTap();
                    }
                  : null,
              splashColor: AppTheme.errorColor.withOpacity(0.1),
              highlightColor: AppTheme.errorColor.withOpacity(0.05),
              child: Padding(
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
                          AppTheme.getSmallRadius(screenSize),
                        ),
                      ),
                      child: Icon(
                        Icons.logout_outlined,
                        size: screenSize.width * 0.05,
                        color: textColor,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      l10n.signOut,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
