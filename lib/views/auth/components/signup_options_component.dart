import 'dart:io';
import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class SignUpOptionsComponent extends StatefulWidget {
  const SignUpOptionsComponent({super.key});

  @override
  State<SignUpOptionsComponent> createState() => _SignUpOptionsComponentState();
}

class _SignUpOptionsComponentState extends State<SignUpOptionsComponent> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),

        // Classical Google Button
        _GoogleSignInButton(size: size),

        SizedBox(height: size.height * 0.015),

        // Classical Apple Button (only on iOS)
        Platform.isIOS
            ? _AppleSignInButton(size: size)
            : const SizedBox.shrink(),
      ],
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
      ),
    );
    print('Google Sign-in initiated');
  }
}

class _AppleSignInButton extends StatelessWidget {
  final Size size;

  const _AppleSignInButton({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
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
          onTap: () => _signInWithApple(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apple,
                color: Colors.white,
                size: size.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(size)),
              Text(
                'Continuar con Apple',
                style: AppTheme.getBodyMedium(size).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signInWithApple(BuildContext context) {
    // TODO: Implement Apple Sign-in logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Apple Sign-in will be implemented soon'),
        backgroundColor: AppTheme.accentBlue,
      ),
    );
    print('Apple Sign-in initiated');
  }
}
