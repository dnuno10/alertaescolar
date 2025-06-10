import 'package:alertaescolar/components/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

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
  final _relationController = TextEditingController();

  String _selectedRelation = 'Padre/Madre';
  bool _isLoading = false;

  final List<String> _relationTypes = [
    'Padre/Madre',
    'Abuelo/Abuela',
    'Tutor/Tutora',
    'Tío/Tía',
    'Hermano/Hermana',
    'Otro familiar',
  ];

  // Mock data for existing family contacts
  final List<Map<String, String>> _familyContacts = [
    {
      'name': 'María González',
      'relation': 'Madre',
      'phone': '+52 555 123 4567',
      'email': 'maria.gonzalez@email.com',
    },
    {
      'name': 'Carlos González',
      'relation': 'Padre',
      'phone': '+52 555 987 6543',
      'email': 'carlos.gonzalez@email.com',
    },
  ];

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _relationController.dispose();
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
                      _buildSectionTitle(
                          l10n.familyContactsRegistered, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildFamilyContactsList(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Add New Contact Section
                      _buildSectionTitle(l10n.addNewContact, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildNewContactForm(l10n, screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Action Buttons
                      _buildActionButtons(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Information Notice
                      _buildInfoNotice(l10n, screenSize),
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

  Widget _buildSectionTitle(String title, Size screenSize) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildFamilyContactsList(AppLocalizations l10n, Size screenSize) {
    return Container(
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
      child: _familyContacts.isEmpty
          ? _buildEmptyState(l10n, screenSize)
          : Column(
              children: _familyContacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;
                return _buildContactTile(
                  contact: contact,
                  isLast: index == _familyContacts.length - 1,
                  l10n: l10n,
                  screenSize: screenSize,
                );
              }).toList(),
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        children: [
          Container(
            width: screenSize.width * 0.16,
            height: screenSize.width * 0.16,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            ),
            child: Icon(
              Icons.family_restroom_outlined,
              size: screenSize.width * 0.08,
              color: AppTheme.accentPurple,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.noFamilyContacts,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.addFamilyContactsEmergency,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required Map<String, String> contact,
    required bool isLast,
    required AppLocalizations l10n,
    required Size screenSize,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              _getRelationIcon(contact['relation'] ?? ''),
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.06,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact['name'] ?? '',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.02,
                        vertical: screenSize.height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.02),
                      ),
                      child: Text(
                        contact['relation'] ?? '',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.005),
                if (contact['phone']?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: screenSize.width * 0.01),
                      Text(
                        contact['phone'] ?? '',
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                if (contact['email']?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: screenSize.width * 0.01),
                      Expanded(
                        child: Text(
                          contact['email'] ?? '',
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editContact(contact, l10n);
              } else if (value == 'delete') {
                _deleteContact(contact, l10n, screenSize);
              }
            },
            color: AppTheme.getSurfaceColor(context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: screenSize.width * 0.045,
                      color: AppTheme.getIconColor(context),
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    Text(
                      l10n.edit,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: screenSize.width * 0.045,
                      color: AppTheme.errorColor,
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    Text(
                      l10n.delete,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.width * 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewContactForm(AppLocalizations l10n, Size screenSize) {
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
            _buildTextField(
              controller: _contactNameController,
              label: l10n.fullName,
              icon: Icons.person_outline,
              l10n: l10n,
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
            _buildRelationDropdown(l10n, screenSize),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Phone Field
            _buildTextField(
              controller: _contactPhoneController,
              label: l10n.phone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              l10n: l10n,
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
            _buildTextField(
              controller: _contactEmailController,
              label: l10n.emailOptional,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              l10n: l10n,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppLocalizations l10n,
    required Size screenSize,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            hintText: '${l10n.enter} $label',
            hintStyle: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            prefixIcon: Icon(
              icon,
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.05,
            ),
            filled: true,
            fillColor: AppTheme.getInputFillColor(context),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationDropdown(AppLocalizations l10n, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.relationship,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRelation,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              dropdownColor: AppTheme.getSurfaceColor(context),
              items: _relationTypes.map((String relation) {
                return DropdownMenuItem<String>(
                  value: relation,
                  child: Row(
                    children: [
                      Icon(
                        _getRelationIcon(relation),
                        size: screenSize.width * 0.04,
                        color: AppTheme.accentPurple,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        relation,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRelation = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n, Size screenSize) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _clearForm,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize)),
              side: BorderSide(
                color: AppTheme.accentPurple.withOpacity(0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.clear,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.accentPurple,
              ),
            ),
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _addContact(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? SizedBox(
                    height: screenSize.height * 0.025,
                    width: screenSize.height * 0.025,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.onPrimaryColor),
                    ),
                  )
                : Text(
                    l10n.addContact,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onPrimaryColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNotice(AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.accentPurple,
            size: screenSize.width * 0.06,
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.importantInformation,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentPurple,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  l10n.familyContactsUsedBySchool,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRelationIcon(String relation) {
    switch (relation.toLowerCase()) {
      case 'padre':
      case 'padre/madre':
        return Icons.person_outline;
      case 'madre':
        return Icons.person_outline;
      case 'abuelo':
      case 'abuela':
      case 'abuelo/abuela':
        return Icons.elderly_outlined;
      case 'tutor':
      case 'tutora':
      case 'tutor/tutora':
        return Icons.school_outlined;
      case 'tío':
      case 'tía':
      case 'tío/tía':
        return Icons.family_restroom_outlined;
      case 'hermano':
      case 'hermana':
      case 'hermano/hermana':
        return Icons.people_outline;
      default:
        return Icons.contact_phone_outlined;
    }
  }

  void _clearForm() {
    setState(() {
      _contactNameController.clear();
      _contactPhoneController.clear();
      _contactEmailController.clear();
      _selectedRelation = 'Padre/Madre';
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

      // Add contact to list (in real app, this would be saved to backend)
      setState(() {
        _familyContacts.add({
          'name': _contactNameController.text.trim(),
          'relation': _selectedRelation,
          'phone': _contactPhoneController.text.trim(),
          'email': _contactEmailController.text.trim(),
        });
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

  void _editContact(Map<String, String> contact, AppLocalizations l10n) {
    // Implementation for editing contact
    _showMessage(l10n.editContactFeatureComingSoon);
  }

  void _deleteContact(
      Map<String, String> contact, AppLocalizations l10n, Size screenSize) {
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
          '${l10n.confirmDeleteContact} ${contact['name']}?',
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
