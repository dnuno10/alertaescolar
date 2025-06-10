import 'package:alertaescolar/components/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/user_provider.dart';
import '../../app/app_theme.dart';

class PersonalInformationView extends StatefulWidget {
  const PersonalInformationView({super.key});

  @override
  State<PersonalInformationView> createState() =>
      _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.nombre ?? '');
    _lastNameController = TextEditingController(text: user?.apellido ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
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
              NavHeader(title: l10n.personalInformation),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Edit Form Section
                      _buildSectionTitle(
                          l10n.editInformation, context, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildFormCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Display current full name with simple styling
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getShadowColor(context),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: screenSize.width * 0.1,
                              height: screenSize.width * 0.1,
                              decoration: BoxDecoration(
                                color: AppTheme.accentYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(screenSize)),
                              ),
                              child: Icon(
                                Icons.badge_outlined,
                                color: AppTheme.accentYellow,
                                size: screenSize.width * 0.05,
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getSmallPadding(screenSize)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.currentFullName,
                                    style: AppTheme.getCaptionSmall(screenSize)
                                        .copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                  ),
                                  Consumer<UserProvider>(
                                    builder: (context, userProvider, child) {
                                      final user = userProvider.currentUser;
                                      return Container(
                                        margin: EdgeInsets.only(
                                            top: AppTheme.getSmallPadding(
                                                    screenSize) *
                                                0.25),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppTheme.getSmallPadding(
                                                  screenSize) *
                                              0.75,
                                          vertical: AppTheme.getSmallPadding(
                                                  screenSize) *
                                              0.25,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentYellow
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.getSmallRadius(
                                                      screenSize) *
                                                  0.5),
                                        ),
                                        child: Text(
                                          user?.nombreCompleto ??
                                              l10n.notAvailable,
                                          style: AppTheme.getCaptionSmall(
                                                  screenSize)
                                              .copyWith(
                                            color: AppTheme.accentYellow,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
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

  Widget _buildSectionTitle(
      String title, BuildContext context, Size screenSize) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations l10n, Size screenSize) {
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
              controller: _nameController,
              label: l10n.firstName,
              screenSize: screenSize,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.firstNameRequired;
                }
                if (value.trim().length < 2) {
                  return l10n.firstNameMinLength;
                }
                return null;
              },
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Last Name Field
            _buildTextField(
              controller: _lastNameController,
              label: l10n.lastNames,
              screenSize: screenSize,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.lastNamesRequired;
                }
                if (value.trim().length < 2) {
                  return l10n.lastNamesMinLength;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize)),

            // Action Buttons
            _buildActionButtons(l10n, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Size screenSize,
    String? Function(String?)? validator,
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
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            hintText: 'Ingresa tu $label',
            hintStyle: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
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

  Widget _buildActionButtons(AppLocalizations l10n, Size screenSize) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => _resetForm(l10n),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize)),
              side: BorderSide(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.reset,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _saveChanges(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    height: screenSize.height * 0.025,
                    width: screenSize.height * 0.025,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n.saveChanges,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _resetForm(AppLocalizations l10n) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    setState(() {
      _nameController.text = user?.nombre ?? '';
      _lastNameController.text = user?.apellido ?? '';
    });
    _showMessage(l10n.formReset);
  }

  Future<void> _saveChanges(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          nombre: _nameController.text.trim(),
          apellido: _lastNameController.text.trim(),
        );

        await userProvider.updateUser(updatedUser);
        _showMessage(l10n.personalInformationUpdatedSuccessfully);
      }
    } catch (e) {
      _showMessage('${l10n.errorUpdatingInformation}: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
