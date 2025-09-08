import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/tips_cards/info_notice_card.dart';
import 'package:alertaescolar/components/profile/family_section_title.dart';
import 'package:alertaescolar/components/profile/family_contacts_list.dart';
import 'package:alertaescolar/components/profile/new_contact_form.dart';
import 'package:alertaescolar/components/buttons/action_buttons_row.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/managers/family_provider.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/views/user/profile/edit_family_contact_view.dart';
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

  // Focus encadenado para onSubmitted
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();

  TipoParentesco _selectedRelation = TipoParentesco.padre;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFamilyContacts());
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
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
                        familyContacts: familyProvider.contacts,
                        onEditContact: _editContact, // firma simplificada
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
                            setState(() => _selectedRelation = newValue);
                          }
                        },
                        screenSize: screenSize,
                        // Focus encadenado y UX mejorada
                        nameFocus: _nameFocus,
                        phoneFocus: _phoneFocus,
                        emailFocus: _emailFocus,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Action Buttons
                      ActionButtonsRow(
                        onClearPressed: _clearForm,
                        onAddPressed: () => _addContact(l10n),
                        isLoading: _isLoading,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Information Notice
                      InfoNoticeCard(l10n: l10n, screenSize: screenSize),
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

  Future<void> _loadFamilyContacts() async {
    // 1) Mostrar SIN await
    LoadingDialog.show(
      context,
      message: AppLocalizations.of(context).loading,
    );

    try {
      await context.read<FamilyProvider>().loadFamilyContacts();

      final error = context.read<FamilyProvider>().error;
      if (error != null && error.isNotEmpty) {
        _showMessage(error, isError: true);
        context.read<FamilyProvider>().clearError();
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}", isError: true);
    } finally {
      // 2) Ocultar SIEMPRE, sin depender de `mounted`
      LoadingDialog.hide(context);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addContact(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final familyProvider = context.read<FamilyProvider>();

      final result = await familyProvider.addFamilyContact(
        context,
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
        // Refresca lista para reflejar estado del servidor
        await familyProvider.loadFamilyContacts();
      } else if (familyProvider.error != null) {
        _showMessage('${l10n.errorAddingContact}: ${familyProvider.error}',
            isError: true);
        familyProvider.clearError();
      }
    } catch (e) {
      _showMessage('${l10n.errorAddingContact}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editContact(ContactoFamiliar contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFamilyContactView(contact: contact),
      ),
    );
    if (result == true && mounted) {
      await _loadFamilyContacts();
    }
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
            onPressed: () async {
              Navigator.pop(context);
              final familyProvider = context.read<FamilyProvider>();
              final success =
                  await familyProvider.deleteFamilyContact(context, contact.id);

              if (!mounted) return;

              if (success) {
                _showMessage(l10n.contactDeleted, isError: false);
                await familyProvider.loadFamilyContacts(); // sincroniza
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

  void _clearForm() {
    setState(() {
      _contactNameController.clear();
      _contactPhoneController.clear();
      _contactEmailController.clear();
      _selectedRelation = TipoParentesco.padre;
    });
    FocusScope.of(context).unfocus();
  }

  void _showMessage(String message, {bool isError = false}) {
    CustomSnackBar.show(
      context: context,
      message: message,
      isError: isError,
    );
  }
}
