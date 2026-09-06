import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../textfield/custom_input_field.dart';
import '../../models/contacto_familiar.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../../utils/modern_dropdown.dart';

class NewContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;
  final TextEditingController contactEmailController;
  final TipoParentesco selectedRelation;
  final ValueChanged<TipoParentesco?> onRelationChanged;
  final Size screenSize;

  // NUEVO: encadenado de focus para onSubmitted
  final FocusNode? nameFocus;
  final FocusNode? phoneFocus;
  final FocusNode? emailFocus;

  const NewContactForm({
    super.key,
    required this.formKey,
    required this.contactNameController,
    required this.contactPhoneController,
    required this.contactEmailController,
    required this.selectedRelation,
    required this.onRelationChanged,
    required this.screenSize,
    this.nameFocus,
    this.phoneFocus,
    this.emailFocus,
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
              focusNode: nameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(phoneFocus),
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

            // Phone Field (solo dígitos)
            CustomInputField(
              controller: contactPhoneController,
              label: l10n.phone,
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
              screenSize: screenSize,
              focusNode: phoneFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(emailFocus),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return l10n.phoneRequired;
                if (v.length < 7) {
                  return "Escibe un número válido"; // regla simple
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Email Field (opcional)
            CustomInputField(
              controller: contactEmailController,
              label: l10n.emailOptional,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              screenSize: screenSize,
              focusNode: emailFocus,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value);
                  if (!ok) return l10n.enterValidEmail;
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
