import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../components/textfield/custom_input_field.dart';

class SignUpBodyComponent extends StatefulWidget {
  const SignUpBodyComponent({super.key});

  @override
  State<SignUpBodyComponent> createState() => _SignUpBodyComponentState();
}

class _SignUpBodyComponentState extends State<SignUpBodyComponent>
    with TickerProviderStateMixin {
  late TextEditingController _emailController;
  late FocusNode _emailNode;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
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
              // Header section
              _buildHeader(size, l10n),
              // Expanded content
              Expanded(
                child: _buildSignUpForm(size, l10n),
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
            onPressed: () => Navigator.pop(context),
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
                  l10n.joinUs,
                  style: AppTheme.getCaption(size).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.createAccount,
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

  Widget _buildSignUpForm(Size size, AppLocalizations l10n) {
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
                  ),

                  SizedBox(height: AppTheme.getLargePadding(size)),

                  // Continue button using SolidButton
                  SolidButton(
                    label: l10n.continue_,
                    backgroundColor: AppTheme.accentPurple,
                    screenSize: size,
                    width: size.width * 0.9,
                    onPressed: _checkAndRegisterEmail,
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: AppTheme.getBodyMedium(size).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          l10n.signIn,
                          style: AppTheme.getBodyMedium(size).copyWith(
                            color: AppTheme.accentPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Divider with proper styling
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
                                    .withOpacity(0.1),
                                AppTheme.getBorderColor(context),
                                AppTheme.getBorderColor(context)
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
                                    .withOpacity(0.1),
                                AppTheme.getBorderColor(context),
                                AppTheme.getBorderColor(context)
                                    .withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Social signup options first
                  SignUpOptionsComponent(size: size),

                  SizedBox(height: AppTheme.getLargePadding(size)),

                  // Terms & Privacy at bottom
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getMediumPadding(size),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color:
                              AppTheme.getBorderColor(context).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/terms');
                          },
                          child: Text(
                            l10n.termsOfService,
                            style: AppTheme.getCaptionSmall(size).copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentPurple,
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
                            color: AppTheme.getTextSecondaryColor(context)
                                .withOpacity(0.3),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/privacy');
                          },
                          child: Text(
                            l10n.privacyPolicy,
                            style: AppTheme.getCaptionSmall(size).copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndRegisterEmail() async {
    final email = _emailController.text.trim();
    final l10n = AppLocalizations.of(context);

    // Validate email before continuing
    if (!_isEmailValid(email)) {
      _showErrorSnackBar(l10n.enterValidEmail);
      return;
    }

    try {
      // Placeholder for email verification logic
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/verify_magic_link',
          arguments: email,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(l10n.signUpErrorMessage);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
        margin: EdgeInsets.all(
            AppTheme.getMediumPadding(MediaQuery.of(context).size)),
      ),
    );
  }
}

class SignUpOptionsComponent extends StatelessWidget {
  final Size size;

  const SignUpOptionsComponent({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GoogleSignUpButton(size: size),
        if (Platform.isIOS) ...[
          SizedBox(height: AppTheme.getMediumPadding(size)),
          _AppleSignUpButton(size: size),
        ],
      ],
    );
  }
}

class _GoogleSignUpButton extends StatelessWidget {
  final Size size;

  const _GoogleSignUpButton({required this.size});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: size.width * 0.9,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
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
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
          onTap: () => _signUpWithGoogle(context),
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
                  l10n.signUpWithGoogle,
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

  void _signUpWithGoogle(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.signingUpWithGoogle),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getMediumRadius(size),
          ),
        ),
        margin: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      ),
    );
  }
}

class _AppleSignUpButton extends StatelessWidget {
  final Size size;

  const _AppleSignUpButton({required this.size});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: size.width * 0.9,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
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
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
          onTap: () => _signUpWithApple(context),
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
                  l10n.signUpWithApple,
                  style: AppTheme.getBodyMedium(size).copyWith(
                    color: Colors.white,
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

  void _signUpWithApple(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.signingUpWithApple),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getMediumRadius(size),
          ),
        ),
        margin: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      ),
    );
  }
}
