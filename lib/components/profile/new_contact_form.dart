import 'package:flutter/material.dart';
import '../textfield/custom_input_field.dart';
import 'relation_dropdown.dart';
import '../../models/contacto_familiar.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../../utils/modern_dropdown.dart';
import '../../views/user/profile/edit_family_contact_view.dart'
    show TipoParentescoExtension;

class NewContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;
  final TextEditingController contactEmailController;
  final TipoParentesco selectedRelation;
  final ValueChanged<TipoParentesco?> onRelationChanged;
  final Size screenSize;

  const NewContactForm({
    super.key,
    required this.formKey,
    required this.contactNameController,
    required this.contactPhoneController,
    required this.contactEmailController,
    required this.selectedRelation,
    required this.onRelationChanged,
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
            // Name Field
            CustomInputField(
              controller: contactNameController,
              label: l10n.fullName,
              icon: Icons.person_outline,
              screenSize: screenSize,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.nameRequired;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Relation Dropdown
            ModernDropdown<TipoParentesco>(
              label: l10n.relationship,
              value: selectedRelation,
              items: TipoParentesco.values,
              onChanged: onRelationChanged,
              getLabel: (tipo) => tipo.getLocalizedName(l10n),
              screenSize: screenSize,
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Phone Field
            CustomInputField(
              controller: contactPhoneController,
              label: l10n.phone,
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
              screenSize: screenSize,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.phoneRequired;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Email Field
            CustomInputField(
              controller: contactEmailController,
              label: l10n.emailOptional,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              screenSize: screenSize,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return l10n.enterValidEmail;
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
