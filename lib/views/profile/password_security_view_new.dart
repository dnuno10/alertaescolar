import 'package:alertaescolar/components/custom_input_field.dart';
import 'package:alertaescolar/components/danger_zone_card.dart';
import 'package:alertaescolar/components/nav_header.dart';
import 'package:alertaescolar/components/solid_button.dart';
import 'package:alertaescolar/components/tips_cards/security_tips_card.dart';
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

                      SecurityTipsCard(l10n: l10n, screenSize: screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Account Deletion Section
                      _buildSectionTitle(l10n.dangerZone, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      DangerZoneCard(l10n: l10n, screenSize: screenSize),

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
            CustomInputField(
              controller: _currentPasswordController,
              label: l10n.currentPassword,
              icon: Icons.lock_outline,
              isPassword: true,
              screenSize: screenSize,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return l10n.enterCurrentPassword;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // New Password
            CustomInputField(
              controller: _newPasswordController,
              label: l10n.newPassword,
              icon: Icons.lock_outline,
              isPassword: true,
              screenSize: screenSize,
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

            CustomInputField(
              controller: _confirmPasswordController,
              label: l10n.confirmNewPassword,
              icon: Icons.lock_outline,
              isPassword: true,
              screenSize: screenSize,
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
            SolidButton(
              backgroundColor: AppTheme.accentPurple,
              width: double.infinity,
              onPressed: () {},
              label: l10n.changePassword,
              screenSize: screenSize,
            ),
          ],
        ),
      ),
    );
  }
}
