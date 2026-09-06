import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../managers/auth/Google.dart';
import '../../../app/app_theme.dart';
import '../../../app/app_routes.dart';

class IntroOptionsComponent extends StatelessWidget {
  const IntroOptionsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      width: size.width,
      padding: EdgeInsets.only(
        bottom: AppTheme.getMediumPadding(size) * 1.2 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        boxShadow: const [],
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

          // Signup Button
          Semantics(
            button: true,
            label: l10n.registerWithEmail,
            child: SolidButton(
              label: l10n.registerWithEmail,
              backgroundColor: AppTheme.accentPurple,
              screenSize: size,
              width: size.width * 0.9,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, AppRoutes.signup);
              },
            ),
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.getMediumPadding(size),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DividerStripe(size: size, context: context),
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
                _DividerStripe(size: size, context: context),
              ],
            ),
          ),

          // Login Button
          Semantics(
            button: true,
            label: l10n.login,
            child: SolidButton(
              label: l10n.login,
              // Evita Colors.black “crudo”; usa el tema
              backgroundColor: AppTheme.getBackgroundColor(context),
              screenSize: size,
              foregroundColor: AppTheme.getTextPrimaryColor(context),
              width: size.width * 0.9,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerStripe extends StatelessWidget {
  const _DividerStripe({
    required this.size,
    required this.context,
  });

  final Size size;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.3,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // ignore: deprecated_member_use
            AppTheme.getBorderColor(this.context).withOpacity(0.1),
            AppTheme.getBorderColor(this.context),
            // ignore: deprecated_member_use
            AppTheme.getBorderColor(this.context).withOpacity(0.1),
          ],
        ),
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
    final radius = AppTheme.getSmallRadius(size);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: size.width * 0.9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.white, // Google button debe ser blanco
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              Google().signInWithGoogle(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(size),
                vertical: AppTheme.getSmallPadding(size),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Logo (con fallback seguro)
                  SizedBox(
                    width: size.height * 0.025,
                    height: size.height * 0.025,
                    child: Image.asset(
                      'images/google_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.g_mobiledata,
                        color: Colors.blue,
                        size: size.height * 0.025,
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(size)),
                  Text(
                    l10n.continueWithGoogle,
                    style: AppTheme.getBodyMedium(size).copyWith(
                      color: isDark
                          ? AppTheme.getBackgroundColor(context)
                          : AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w500,
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
