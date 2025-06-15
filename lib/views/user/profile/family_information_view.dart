import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/tips_cards/info_notice_card.dart';
import 'package:alertaescolar/components/profile/family_section_title.dart';
import 'package:alertaescolar/components/profile/family_contacts_list.dart';
import 'package:alertaescolar/components/profile/new_contact_form.dart';
import 'package:alertaescolar/components/buttons/action_buttons_row.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/managers/family_provider.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/views/user/profile/edit_family_contact_view.dart'; // Added this import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../models/contacto_familiar.dart';

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

  @override
  void initState() {
    super.initState();
    // Load family contacts when the view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFamilyContacts();
    });
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
      body: Consumer<FamilyProvider>(
        builder: (context, familyProvider, _) {
          return CustomScrollView(
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
                        familyContacts: familyProvider
                            .contacts, // Cambiar de familyContacts a contacts
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

                      // Action Buttons - Using the new component
                      ActionButtonsRow(
                        onClearPressed: _clearForm,
                        onAddPressed: () => _addContact(l10n),
                        isLoading: _isLoading,
                        screenSize: screenSize,
                      ),

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
          );
        },
      ),
    );
  }
// Actualizar las llamadas a _showMessage en _loadFamilyContacts

  Future<void> _loadFamilyContacts() async {
    // Check if mounted before proceeding
    if (!mounted) return;

    try {
      final familyProvider =
          Provider.of<FamilyProvider>(context, listen: false);

      LoadingDialog.show(
        context,
        message: AppLocalizations.of(context).loading,
      );

      await familyProvider.loadFamilyContacts();

      // Check if still mounted before proceeding
      if (!mounted) return;

      LoadingDialog.hide(context);

      // Show error if any
      if (familyProvider.error != null) {
        // Ignoramos el error específico de "relation not exists" ya que es esperado
        if (!familyProvider.error!.contains(
            'relation "public.contactos_familiares" does not exist')) {
          _showMessage(familyProvider.error!, isError: true);
        }
        familyProvider.clearError();
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        _showMessage("Error: ${e.toString()}", isError: true);
      }
    }
  }

// Actualizar en _addContact
  void _addContact(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final familyProvider =
          Provider.of<FamilyProvider>(context, listen: false);

      final result = await familyProvider.addFamilyContact(
        context, // Añadir el parámetro context como primer argumento
        _contactNameController.text.trim(),
        _selectedRelation,
        _contactPhoneController.text.trim(),
        _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
      );

      if (result != null) {
        _showMessage(l10n.familyContactAddedSuccessfully, isError: false);
        _clearForm();
      } else if (familyProvider.error != null) {
        _showMessage('${l10n.errorAddingContact}: ${familyProvider.error}',
            isError: true);
        familyProvider.clearError();
      }
    } catch (e) {
      _showMessage('${l10n.errorAddingContact}: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Actualizar en _editContact
  void _editContact(ContactoFamiliar contact, AppLocalizations l10n) async {
    // Navigate to edit contact view
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFamilyContactView(contact: contact),
      ),
    );

    // If the edit was successful, reload the contacts
    if (result == true) {
      _loadFamilyContacts();
    }
  }

// Actualizar en _deleteContact
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
            onPressed: () async {
              Navigator.pop(context);

              final familyProvider =
                  Provider.of<FamilyProvider>(context, listen: false);
              final success =
                  await familyProvider.deleteFamilyContact(context, contact.id);

              if (success) {
                _showMessage(l10n.contactDeleted, isError: false);
              } else if (familyProvider.error != null) {
                _showMessage(familyProvider.error!, isError: true);
                familyProvider.clearError();
              }
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

  // Añadir este método a la clase _FamilyInformationViewState
  void _clearForm() {
    setState(() {
      _contactNameController.clear();
      _contactPhoneController.clear();
      _contactEmailController.clear();
      _selectedRelation =
          TipoParentesco.padre; // Restablecer al valor predeterminado
    });

    FocusScope.of(context).unfocus();
  }

  // Actualizar el método _showMessage para usar CustomSnackBar en lugar de SnackBar directo
  void _showMessage(String message, {bool isError = false}) {
    // Utilizamos la clase CustomSnackBar que proporciona una interfaz más consistente
    CustomSnackBar.show(
      context: context,
      message: message,
      isError:
          isError, // Indicamos si es un error para mostrar el color adecuado
    );
  }
}
