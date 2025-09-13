import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/components/auth/terms_privacy_footer.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../components/textfield/custom_input_field.dart';
import '../../../managers/auth/Google.dart';
import '../../../managers/auth/Apple.dart';
import '../../../managers/auth/Login.dart';
import '../../../app/app_theme.dart';

class LoginBodyComponent extends StatefulWidget {
  const LoginBodyComponent({super.key});

  @override
  State<LoginBodyComponent> createState() => _LoginBodyComponentState();
}

class _LoginBodyComponentState extends State<LoginBodyComponent>
    with TickerProviderStateMixin {
  late TextEditingController _emailController;
  late FocusNode _emailNode;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailNode = FocusNode();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(size, l10n),
              Expanded(
                child: _buildLoginForm(size, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.getTextPrimaryColor(context),
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.getCardColor(context),
              elevation: 2,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(size)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.welcomeBack,
                  style: AppTheme.getCaption(size).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.loginSubtitle,
                  style: AppTheme.getH2(size).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(Size size, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.getLargeRadius(size) * 1.5),
          topRight: Radius.circular(AppTheme.getLargeRadius(size) * 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
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

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(size),
              ),
              child: Column(
                children: [
                  // Email field
                  CustomInputField(
                    controller: _emailController,
                    label: l10n.email,
                    screenSize: size,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailNode,
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Botón principal: deshabilitado mientras se envía
                  SolidButton(
                    label: _isSubmitting ? l10n.sending : l10n.login,
                    backgroundColor: AppTheme.accentPurple,
                    screenSize: size,
                    width: size.width * 0.9,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            _handleLogin();
                          },
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: AppTheme.getBodyMedium(size).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.signup);
                        },
                        child: Text(
                          l10n.signUp,
                          style: AppTheme.getBodyMedium(size).copyWith(
                            color: AppTheme.accentPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(size),
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
                                AppTheme.getBorderColor(context)
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.1),
                                AppTheme.getBorderColor(context),
                                AppTheme.getBorderColor(context)
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.1),
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
                                AppTheme.getBorderColor(context)
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.1),
                                AppTheme.getBorderColor(context),
                                AppTheme.getBorderColor(context)
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Social login (se deshabilitan si _isSubmitting, SIN loader)
                  LoginOptionsComponent(
                    size: size,
                    isBusy: _isSubmitting,
                    onGoogle: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            try {
                              HapticFeedback.mediumImpact();
                              await Google().signInWithGoogle(context);
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    onApple: _isSubmitting
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            setState(() => _isSubmitting = true);
                            try {
                              await Apple().signInWithApple(context);
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                  ),

                  SizedBox(height: AppTheme.getSmallPadding(size)),

                  // Terms & Privacy
                  TermsPrivacyFooter(size: size),

                  SizedBox(height: AppTheme.getMediumPadding(size)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isEmailValid(email)) {
      _showErrorSnackBar(AppLocalizations.of(context).emailInvalid);
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await LogIn(context).checkAndLogin(email);
    } catch (_) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: AppLocalizations.of(context).unexpectedError,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    CustomSnackBar.show(
      context: context,
      message: message,
      isError: true,
    );
  }
}

class LoginOptionsComponent extends StatelessWidget {
  final Size size;
  final bool isBusy;
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  const LoginOptionsComponent({
    super.key,
    required this.size,
    required this.isBusy,
    this.onGoogle,
    this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GoogleSignInButton(
          size: size,
          onTap: onGoogle,
          isBusy: isBusy,
        ),
        if (showAppleButton()) ...[
          SizedBox(height: AppTheme.getMediumPadding(size)),
          _AppleSignInButton(
            size: size,
            onTap: onApple,
            isBusy: isBusy,
          ),
        ],
      ],
    );
  }

  bool showAppleButton() {
    if (kIsWeb) return false; // Apple Sign in no funciona en web
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final Size size;
  final VoidCallback? onTap;
  final bool isBusy;

  const _GoogleSignInButton({
    required this.size,
    required this.onTap,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: IgnorePointer(
        ignoring: onTap == null,
        child: Container(
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
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(size)),
              onTap: onTap,
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
                      // Fallback
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
                    // 🔕 Sin loader aquí
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

class _AppleSignInButton extends StatelessWidget {
  final Size size;
  final VoidCallback? onTap;
  final bool isBusy;

  const _AppleSignInButton({
    required this.size,
    required this.onTap,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: IgnorePointer(
        ignoring: onTap == null,
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.black,
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
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(size)),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(size),
                  vertical: AppTheme.getSmallPadding(size),
                ),
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
                      l10n.continueWithApple,
                      style: AppTheme.getBodyMedium(size).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // 🔕 Sin loader aquí
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
