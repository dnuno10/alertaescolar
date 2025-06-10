import 'package:alertaescolar/components/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/user_provider.dart';
import '../../app/app_theme.dart';

class UsernameChangeView extends StatefulWidget {
  const UsernameChangeView({super.key});

  @override
  State<UsernameChangeView> createState() => _UsernameChangeViewState();
}

class _UsernameChangeViewState extends State<UsernameChangeView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isUsernameAvailable = true;
  String? _usernameError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.changeUsername),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Username Info
                      _buildCurrentUsernameCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Change Username Form
                      _buildSectionTitle(l10n.newUsername, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildFormCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Action Buttons
                      _buildActionButtons(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Security Notice
                      _buildSecurityNotice(l10n, screenSize),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentUsernameCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;
          return Row(
            children: [
              Container(
                width: screenSize.width * 0.12,
                height: screenSize.width * 0.12,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.account_circle_outlined,
                  color: AppTheme.accentPurple,
                  size: screenSize.width * 0.06,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentUser,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    Text(
                      user?.id ?? l10n.notAvailable,
                      style: AppTheme.getSubtitle1(screenSize).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextPrimaryColor(context),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size screenSize) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New Username Field
            TextFormField(
              controller: _usernameController,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              decoration: InputDecoration(
                labelText: l10n.newUsernameLabel,
                labelStyle: AppTheme.getCaption(screenSize).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                prefixIcon: Icon(
                  Icons.alternate_email_outlined,
                  color: AppTheme.accentPurple,
                  size: screenSize.width * 0.05,
                ),
                suffixIcon: _usernameController.text.isNotEmpty
                    ? Icon(
                        _isUsernameAvailable ? Icons.check_circle : Icons.error,
                        color: _isUsernameAvailable
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        size: screenSize.width * 0.05,
                      )
                    : null,
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: BorderSide(
                    color: AppTheme.accentPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: BorderSide(
                    color: AppTheme.accentPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: const BorderSide(
                    color: AppTheme.accentPurple,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: const BorderSide(
                    color: AppTheme.errorColor,
                    width: 1,
                  ),
                ),
                errorText: _usernameError,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.usernameRequired;
                }
                if (value.trim().length < 3) {
                  return l10n.usernameMinLength;
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return l10n.usernameInvalidCharacters;
                }
                return null;
              },
              onChanged: (value) => _checkUsernameAvailability(value, l10n),
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Password Confirmation Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              decoration: InputDecoration(
                labelText: l10n.confirmYourPassword,
                labelStyle: AppTheme.getCaption(screenSize).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppTheme.accentPurple,
                  size: screenSize.width * 0.05,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.getTextSecondaryColor(context),
                    size: screenSize.width * 0.05,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: BorderSide(
                    color: AppTheme.accentPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: BorderSide(
                    color: AppTheme.accentPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: const BorderSide(
                    color: AppTheme.accentPurple,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: const BorderSide(
                    color: AppTheme.errorColor,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.passwordRequiredForConfirmation;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Username Requirements
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.05),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.accentPurple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.accentPurple,
                        size: screenSize.width * 0.04,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        l10n.usernameRequirements,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  _buildRequirement(l10n.minimumCharacters, screenSize),
                  _buildRequirement(
                      l10n.onlyLettersNumbersUnderscores, screenSize),
                  _buildRequirement(l10n.mustBeUniqueInSystem, screenSize),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, Size screenSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenSize.height * 0.005),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: screenSize.width * 0.03,
            color: AppTheme.accentPurple,
          ),
          SizedBox(width: screenSize.width * 0.02),
          Text(
            text,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n, Size screenSize) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => _clearForm(l10n),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize)),
              side: BorderSide(
                color: AppTheme.accentPurple.withOpacity(0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.clear,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.accentPurple,
              ),
            ),
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading || !_isUsernameAvailable
                ? null
                : () => _changeUsername(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? SizedBox(
                    height: screenSize.height * 0.025,
                    width: screenSize.height * 0.025,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.onPrimaryColor),
                    ),
                  )
                : Text(
                    l10n.changeUser,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onPrimaryColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNotice(AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_outlined,
            color: AppTheme.warningColor,
            size: screenSize.width * 0.06,
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.important,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningColor,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  l10n.usernameChangeWarning,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkUsernameAvailability(String username, AppLocalizations l10n) {
    setState(() {
      _usernameError = null;
    });

    if (username.length >= 3) {
      // Simulate username availability check
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            // For demo purposes, usernames starting with 'admin' are not available
            _isUsernameAvailable = !username.toLowerCase().startsWith('admin');
            if (!_isUsernameAvailable) {
              _usernameError = l10n.usernameNotAvailable;
            }
          });
        }
      });
    }
  }

  void _clearForm(AppLocalizations l10n) {
    setState(() {
      _usernameController.clear();
      _passwordController.clear();
      _isUsernameAvailable = true;
      _usernameError = null;
    });
  }

  Future<void> _changeUsername(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Here you would typically call your user service to change the username
      _showMessage(l10n.usernameChangedSuccessfully);

      // Clear form after successful change
      _clearForm(l10n);
    } catch (e) {
      _showMessage('${l10n.errorChangingUsername}: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.getTextPrimaryColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
        margin: EdgeInsets.all(
            AppTheme.getSmallPadding(MediaQuery.of(context).size)),
      ),
    );
  }
}
