import 'package:flutter/material.dart';
import '../textfield/custom_input_field.dart';
import '../buttons/custom_outline_button.dart';
import '../buttons/solid_button.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class PersonalInfoFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final bool isLoading;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final Size screenSize;

  // Opcionales para mejor UX de foco entre campos
  final FocusNode? nameFocus;
  final FocusNode? lastNameFocus;

  const PersonalInfoFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.lastNameController,
    required this.isLoading,
    required this.onReset,
    required this.onSave,
    required this.screenSize,
    this.nameFocus,
    this.lastNameFocus,
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
        boxShadow: const [],
      ),
      child: Column(
        children: [
          // Indicador fino de guardado en curso (además del LoadingDialog del provider)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? Column(
                    key: const ValueKey('progress'),
                    children: [
                      LinearProgressIndicator(
                        minHeight: 2,
                        color: AppTheme.accentPurple,
                        backgroundColor:
                            // ignore: deprecated_member_use
                            AppTheme.getBorderColor(context).withOpacity(0.4),
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('noprog')),
          ),

          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Name Field
                CustomInputField(
                  controller: nameController,
                  label: l10n.firstName,
                  screenSize: screenSize,
                  focusNode: nameFocus,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.firstNameRequired;
                    }
                    if (value.trim().length < 2) {
                      return l10n.firstNameMinLength;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    if (lastNameFocus != null) {
                      lastNameFocus!.requestFocus();
                    } else {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Last Name Field
                CustomInputField(
                  controller: lastNameController,
                  label: l10n.lastNames,
                  screenSize: screenSize,
                  focusNode: lastNameFocus,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.lastNamesRequired;
                    }
                    if (value.trim().length < 2) {
                      return l10n.lastNamesMinLength;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),

                SizedBox(height: AppTheme.getLargePadding(screenSize)),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomOutlineButton(
                        onPressed: isLoading ? () {} : onReset,
                        label: l10n.reset,
                        color: AppTheme.accentPurple,
                        screenSize: screenSize,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: SolidButton(
                        backgroundColor: AppTheme.accentPurple,
                        width: double.infinity,
                        onPressed: isLoading ? () {} : onSave,
                        label: l10n.saveChanges,
                        screenSize: screenSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
