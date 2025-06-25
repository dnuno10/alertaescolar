import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../managers/auth/Google.dart';
import '../../../app/app_theme.dart';

class IntroOptionsComponent extends StatelessWidget {
  const IntroOptionsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      padding: EdgeInsets.only(bottom: AppTheme.getMediumPadding(size) * 1.2),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.getLargeRadius(size) * 1.5),
          topRight: Radius.circular(AppTheme.getLargeRadius(size) * 1.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header pill
          Container(
            width: size.width * 0.15,
            height: 4,
            margin: EdgeInsets.only(
              top: AppTheme.getMediumPadding(size),
              bottom: AppTheme.getLargePadding(size),
            ),
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Google Button
          _GoogleSignInButton(size: size),

          SizedBox(height: AppTheme.getMediumPadding(size)),

          // Register Button
          SolidButton(
            label: l10n.registerWithEmail,
            backgroundColor: AppTheme.accentPurple,
            screenSize: size,
            width: size.width * 0.9,
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(context, '/signup');
            },
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.getMediumPadding(size),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.3,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getBorderColor(context).withOpacity(0.1),
                        AppTheme.getBorderColor(context),
                        AppTheme.getBorderColor(context).withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(size),
                  ),
                  child: Text(
                    l10n.or,
                    style: AppTheme.getCaptionSmall(size).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ),
                Container(
                  width: size.width * 0.3,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getBorderColor(context).withOpacity(0.1),
                        AppTheme.getBorderColor(context),
                        AppTheme.getBorderColor(context).withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Login Button
          SolidButton(
            label: l10n.login,
            backgroundColor: Colors.black,
            screenSize: size,
            width: size.width * 0.9,
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final Size size;

  const _GoogleSignInButton({required this.size});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(size)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _signInWithGoogle(context);
          },
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getMediumPadding(size),
              vertical: AppTheme.getSmallPadding(size),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Logo
                Container(
                  width: size.height * 0.025,
                  height: size.height * 0.025,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('images/google_logo.png'),
                      fit: BoxFit.contain,
                    ),
                    borderRadius:
                        BorderRadius.circular(size.height * 0.025 / 2),
                  ),
                  // Fallback in case image isn't available
                  child: Image.network(
                    'https://developers.google.com/identity/images/g-logo.png',
                    width: size.height * 0.025,
                    height: size.height * 0.025,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.g_mobiledata,
                        color: Colors.blue,
                        size: size.height * 0.025,
                      );
                    },
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(size)),
                Text(
                  l10n.continueWithGoogle,
                  style: AppTheme.getBodyMedium(size).copyWith(
                    color: const Color(0xFF3C4043),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) {
    // Use the Google authentication manager
    Google().signInWithGoogle(context);
  }
}
