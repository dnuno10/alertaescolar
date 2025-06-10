import 'package:alertaescolar/components/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class PasswordSecurityView extends StatefulWidget {
  const PasswordSecurityView({super.key});

  @override
  State<PasswordSecurityView> createState() => _PasswordSecurityViewState();
}

class _PasswordSecurityViewState extends State<PasswordSecurityView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
              NavHeader(title: l10n.security),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Password Change Section
                      _buildSectionTitle(l10n.changePassword, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildPasswordChangeCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Security Tips Section
                      _buildSectionTitle(l10n.securityTips, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildSecurityTipsCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Account Deletion Section
                      _buildSectionTitle(l10n.dangerZone, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildDangerZoneCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
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

  Widget _buildPasswordChangeCard(AppLocalizations l10n, Size screenSize) {
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
            // Current Password
            _buildPasswordField(
              controller: _currentPasswordController,
              label: l10n.currentPassword,
              obscure: _obscureCurrentPassword,
              l10n: l10n,
              screenSize: screenSize,
              onToggleVisibility: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return l10n.enterCurrentPassword;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // New Password
            _buildPasswordField(
              controller: _newPasswordController,
              label: l10n.newPassword,
              obscure: _obscureNewPassword,
              l10n: l10n,
              screenSize: screenSize,
              onToggleVisibility: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return l10n.enterNewPassword;
                }
                if (value!.length < 8) {
                  return l10n.passwordMinLength;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            _buildPasswordField(
              controller: _confirmPasswordController,
              label: l10n.confirmNewPassword,
              obscure: _obscureConfirmPassword,
              l10n: l10n,
              screenSize: screenSize,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return l10n.confirmPassword;
                }
                if (value != _newPasswordController.text) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize)),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () {}, //_isLoading ? null : () => _changePassword(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: AppTheme.onPrimaryColor,
                  padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(screenSize)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  elevation: 0,
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
                        l10n.changePassword,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onPrimaryColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    required AppLocalizations l10n,
    required Size screenSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            hintText: '${l10n.enter} $label',
            hintStyle: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.width * 0.05,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.getTextSecondaryColor(context),
                size: screenSize.width * 0.05,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: AppTheme.getInputFillColor(context),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTipsCard(AppLocalizations l10n, Size screenSize) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.securityTips,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildSecurityTip(l10n.securityTip1, screenSize),
          _buildSecurityTip(l10n.securityTip2, screenSize),
          _buildSecurityTip(l10n.securityTip3, screenSize),
          _buildSecurityTip(l10n.securityTip4, screenSize),
        ],
      ),
    );
  }

  Widget _buildSecurityTip(String tip, Size screenSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenSize.width * 0.015,
            height: screenSize.width * 0.015,
            margin: EdgeInsets.only(top: screenSize.height * 0.01),
            decoration: const BoxDecoration(
              color: AppTheme.accentPurple,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              tip,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.errorColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_outlined,
                color: AppTheme.errorColor,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.dangerZone,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.dangerZoneDesc,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete_forever_outlined,
                  color: AppTheme.errorColor,
                  size: screenSize.width * 0.05,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.deleteAccount,
                        style: AppTheme.getSubtitle2(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.003),
                      Text(
                        l10n.deleteAccountDesc,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _showDeleteAccountDialog(l10n, screenSize),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.delete,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AppLocalizations l10n, Size screenSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppTheme.errorColor,
              size: screenSize.width * 0.06,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.deleteAccount,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteAccountWarning,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Text(
                '• ${l10n.deleteAccountDesc}\n• Se perderán todos tus datos de estudiantes\n• No podrás recuperar tu cuenta',
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount(l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.deleteAccount,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(AppLocalizations l10n) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call for account deletion
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.accountDeletionStarted,
            style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.onPrimaryColor,
            ),
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(MediaQuery.of(context).size)),
          ),
        ),
      );

      // Navigate back to main screen (simulate logout)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
