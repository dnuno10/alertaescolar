import 'package:flutter/material.dart';
import '../textfield/custom_input_field.dart';
import '../buttons/solid_button.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class PasswordChangeCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onChangePassword;
  final Size screenSize;

  const PasswordChangeCard({
    super.key,
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onChangePassword,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Password
            CustomInputField(
              controller: currentPasswordController,
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
              controller: newPasswordController,
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
              controller: confirmPasswordController,
              label: l10n.confirmNewPassword,
              icon: Icons.lock_outline,
              isPassword: true,
              screenSize: screenSize,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return l10n.confirmPassword;
                }
                if (value != newPasswordController.text) {
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
              onPressed: onChangePassword,
              label: l10n.changePassword,
              screenSize: screenSize,
            ),
          ],
        ),
      ),
    );
  }
}
