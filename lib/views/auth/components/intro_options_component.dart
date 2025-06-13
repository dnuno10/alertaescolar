import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/buttons/solid_button.dart';

class IntroOptionsComponent extends StatelessWidget {
  const IntroOptionsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2F3E46);
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.3,
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
              color: (Theme.of(context).primaryColor).withValues(alpha: 0.2),
              width: 1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size.height * 0.04),
              topRight: Radius.circular(size.height * 0.04))),
      width: size.width,
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          // Google Button
          _GoogleSignInButton(size: size),
          SizedBox(height: size.height * 0.015),

          // Register Button
          SolidButton(
            label: l10n.registerWithEmail,
            backgroundColor: isDark ? const Color(0xFF2A2A2A) : textColor,
            screenSize: size,
            width: size.width * 0.9,
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
            child: Container(
              width: size.width * 0.8,
              height: 1,
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2)),
            ),
          ),

          // Login Button
          SolidButton(
            label: l10n.login,
            backgroundColor:
                isDark ? const Color(0xFF2A2A2A) : const Color(0xFF566573),
            screenSize: size,
            width: size.width * 0.9,
            onPressed: () {
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
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
          onTap: () => _signInWithGoogle(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google Logo
              Container(
                width: size.height * 0.025,
                height: size.height * 0.025,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://developers.google.com/identity/images/g-logo.png',
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(size)),
              Text(
                'Continuar con Google',
                style: AppTheme.getBodyMedium(size).copyWith(
                  color: const Color(0xFF3C4043),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) {
    // TODO: Implement Google Sign-in logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google Sign-in will be implemented soon'),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
    print('Google Sign-in initiated');
  }
}
