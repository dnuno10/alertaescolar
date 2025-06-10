import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/tips_cards/info_notice_card.dart';
import 'package:alertaescolar/components/profile/family_section_title.dart';
import 'package:alertaescolar/components/profile/family_contacts_list.dart';
import 'package:alertaescolar/components/profile/new_contact_form.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../../models/contacto_familiar.dart';

class FamilyInformationView extends StatefulWidget {
  const FamilyInformationView({super.key});

  @override
  State<FamilyInformationView> createState() => _FamilyInformationViewState();
}

class _FamilyInformationViewState extends State<FamilyInformationView> {
  final _formKey = GlobalKey<FormState>();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  TipoParentesco _selectedRelation = TipoParentesco.padre;
  bool _isLoading = false;

  // Mock data for existing family contacts using the model
  final List<ContactoFamiliar> _familyContacts = [
    ContactoFamiliar(
      id: '1',
      usuarioId: 'user_1',
      nombre: 'María González',
      parentesco: TipoParentesco.madre,
      telefono: '+52 555 123 4567',
      email: 'maria.gonzalez@email.com',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
    ),
    ContactoFamiliar(
      id: '2',
      usuarioId: 'user_1',
      nombre: 'Carlos González',
      parentesco: TipoParentesco.padre,
      telefono: '+52 555 987 6543',
      email: 'carlos.gonzalez@email.com',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 25)),
    ),
  ];

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

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.familyInformation),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Existing Family Contacts Section
                      FamilySectionTitle(
                        title: l10n.familyContactsRegistered,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      FamilyContactsList(
                        familyContacts: _familyContacts,
                        onEditContact: _editContact,
                        onDeleteContact: _deleteContact,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Add New Contact Section
                      FamilySectionTitle(
                        title: l10n.addNewContact,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      NewContactForm(
                        formKey: _formKey,
                        contactNameController: _contactNameController,
                        contactPhoneController: _contactPhoneController,
                        contactEmailController: _contactEmailController,
                        selectedRelation: _selectedRelation,
                        onRelationChanged: (TipoParentesco? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedRelation = newValue;
                            });
                          }
                        },
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Action Buttons
                      _buildActionButtons(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Information Notice
                      InfoNoticeCard(
                        l10n: l10n,
                        screenSize: screenSize,
                      ),
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

  Widget _buildActionButtons(AppLocalizations l10n, Size screenSize) {
    return Row(
      children: [
        Expanded(
          child: CustomOutlineButton(
              onPressed: _isLoading ? () {} : () => _clearForm(),
              label: l10n.clear,
              color: AppTheme.accentPurple,
              screenSize: screenSize),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: SolidButton(
              backgroundColor: AppTheme.accentPurple,
              onPressed: _isLoading ? () {} : () => _addContact(l10n),
              label: l10n.addContact,
              screenSize: screenSize,
              width: double.infinity),
        ),
      ],
    );
  }

  void _clearForm() {
    setState(() {
      _contactNameController.clear();
      _contactPhoneController.clear();
      _contactEmailController.clear();
      _selectedRelation = TipoParentesco.padre;
    });
  }

  void _addContact(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Add contact to list using the model
      final newContact = ContactoFamiliar(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _contactNameController.text.trim(),
        parentesco: _selectedRelation,
        telefono: _contactPhoneController.text.trim(),
        email: _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
        fechaRegistro: DateTime.now(),
        usuarioId: 'user_1', // Set the user ID
      );

      setState(() {
        _familyContacts.add(newContact);
      });

      _showMessage(l10n.familyContactAddedSuccessfully);
      _clearForm();
    } catch (e) {
      _showMessage('${l10n.errorAddingContact}: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editContact(ContactoFamiliar contact, AppLocalizations l10n) {
    // Implementation for editing contact
    _showMessage(l10n.editContactFeatureComingSoon);
  }

  void _deleteContact(
      ContactoFamiliar contact, AppLocalizations l10n, Size screenSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
        title: Text(
          l10n.deleteContact,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          '${l10n.confirmDeleteContact} ${contact.nombre}?',
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _familyContacts.remove(contact);
              });
              Navigator.pop(context);
              _showMessage(l10n.contactDeleted);
            },
            child: Text(
              l10n.delete,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
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
