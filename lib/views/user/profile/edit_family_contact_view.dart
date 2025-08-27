import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/buttons/action_buttons_row.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/family_provider.dart';
import '../../../models/contacto_familiar.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/modern_dropdown.dart';

class EditFamilyContactView extends StatefulWidget {
  final ContactoFamiliar contact;

  const EditFamilyContactView({
    super.key,
    required this.contact,
  });

  @override
  State<EditFamilyContactView> createState() => _EditFamilyContactViewState();
}

class _EditFamilyContactViewState extends State<EditFamilyContactView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _contactEmailController;
  late TipoParentesco _selectedRelation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing contact data
    _contactNameController = TextEditingController(text: widget.contact.nombre);
    _contactPhoneController =
        TextEditingController(text: widget.contact.telefono);
    _contactEmailController =
        TextEditingController(text: widget.contact.email ?? '');
    _selectedRelation = widget.contact.parentesco;
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          NavHeader(title: l10n.editContact),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: _buildEditContactForm(context, l10n, screenSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditContactForm(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
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
            // Name Field
            CustomInputField(
              controller: _contactNameController,
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
              value: _selectedRelation,
              items: TipoParentesco.values,
              onChanged: (TipoParentesco? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRelation = newValue;
                  });
                }
              },
              getLabel: (tipo) => tipo.getLocalizedName(l10n),
              screenSize: screenSize,
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Phone Field
            CustomInputField(
              controller: _contactPhoneController,
              label: l10n.phone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
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
              controller: _contactEmailController,
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

            SizedBox(height: AppTheme.getLargePadding(screenSize)),

            // Action buttons
            ActionButtonsRow(
              onClearPressed: () {
                Navigator.of(context).pop();
              },
              onAddPressed: () => _updateContact(l10n),
              isLoading: _isLoading,
              screenSize: screenSize,
              clearButtonText: l10n.cancel,
              addButtonText: l10n.save,
            ),
          ],
        ),
      ),
    );
  }

  void _updateContact(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final familyProvider =
          Provider.of<FamilyProvider>(context, listen: false);

      // Create updated contact object
      final updatedContact = ContactoFamiliar(
        id: widget.contact.id,
        usuarioId: widget.contact.usuarioId,
        nombre: _contactNameController.text.trim(),
        parentesco: _selectedRelation,
        telefono: _contactPhoneController.text.trim(),
        email: _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
        fechaRegistro: widget.contact.fechaRegistro,
      );

      // Update contact using provider
      final success =
          await familyProvider.updateFamilyContact(context, updatedContact);

      if (mounted) {
        if (success) {
          _showMessage(l10n.contactUpdatedSuccessfully, isError: false);
          Navigator.of(context).pop(true); // Return true to indicate success
        } else if (familyProvider.error != null) {
          _showMessage('${l10n.errorUpdatingContact}: ${familyProvider.error}',
              isError: true);
          familyProvider.clearError();
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('${l10n.errorUpdatingContact}: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    CustomSnackBar.show(
      context: context,
      message: message,
      isError: isError,
    );
  }
}
