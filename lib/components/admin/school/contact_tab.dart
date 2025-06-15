import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../components/textfield/custom_input_field.dart';
import '../../../components/textfield/custom_text_area_field.dart';
import '../../../components/admin/school/section_card.dart';

class ContactTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController direccionController;
  final TextEditingController telefonoController;
  final TextEditingController emailController;
  final TextEditingController sitioWebController;
  final bool isLoading;
  final VoidCallback onSave;

  const ContactTab({
    super.key,
    required this.formKey,
    required this.direccionController,
    required this.telefonoController,
    required this.emailController,
    required this.sitioWebController,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              title: l10n.contactInfo,
              icon: Icons.contact_phone_rounded,
              color: AppTheme.successColor,
              children: [
                CustomTextAreaField(
                  label: l10n.schoolAddress,
                  controller: direccionController,
                  icon: Icons.location_on_rounded,
                  maxLines: 2,
                  validator: (value) =>
                      value?.isEmpty == true ? l10n.fieldRequired : null,
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        controller: telefonoController,
                        label: l10n.schoolPhone,
                        screenSize: screenSize,
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value?.isEmpty == true ? l10n.fieldRequired : null,
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      child: CustomInputField(
                        controller: emailController,
                        label: l10n.schoolEmail,
                        screenSize: screenSize,
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty == true) return l10n.fieldRequired;
                          if (value != null && !value.contains('@'))
                            return l10n.invalidEmail;
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                CustomInputField(
                  controller: sitioWebController,
                  label: l10n.website,
                  screenSize: screenSize,
                  icon: Icons.language_rounded,
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
            SizedBox(height: AppTheme.getLargePadding(screenSize)),
            SolidButton(
              onPressed: isLoading ? () {} : onSave,
              label: isLoading ? l10n.saving : l10n.updateSettings,
              icon: isLoading ? null : Icons.save_rounded,
              backgroundColor: AppTheme.accentPurple,
              screenSize: screenSize,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
