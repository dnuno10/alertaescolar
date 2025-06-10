import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../textfield/custom_input_field.dart';

class ManualInputCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController keyController;
  final Size screenSize;

  const ManualInputCard({
    super.key,
    required this.formKey,
    required this.keyController,
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
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.manualEntry,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              l10n.enterStudentKeyCode,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            CustomInputField(
              label: l10n.keyCode,
              controller: keyController,
              icon: Icons.key_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterKeyCode;
                }
                if (value.trim().length < 6) {
                  return l10n.keyCodeMinLength;
                }
                return null;
              },
              screenSize: screenSize,
            ),
          ],
        ),
      ),
    );
  }
}
