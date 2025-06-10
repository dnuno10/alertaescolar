import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/user_provider.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';
import '../../components/loading_indicator.dart';

class PersonalDataView extends StatefulWidget {
  const PersonalDataView({super.key});

  @override
  State<PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends State<PersonalDataView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.nombre ?? '');
    _lastNameController = TextEditingController(text: user?.apellido ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.telefono ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
          appBar: AppBar(
            title: Text(
              l10n.personalData,
              style: AppTheme.getH2(screenSize).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentPurple,
                    AppTheme.accentBlue,
                  ],
                ),
              ),
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
              size: screenSize.width * 0.06,
            ),
            actions: [
              if (!_isEditing)
                Container(
                  margin: EdgeInsets.only(
                      right: AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: screenSize.width * 0.06,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
                ),
            ],
          ),
          body: _isLoading
              ? const LoadingIndicator()
              : SingleChildScrollView(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar section with modern styling
                        Center(
                          child: Stack(
                            children: [
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  final user = userProvider.currentUser;
                                  return Container(
                                    padding: EdgeInsets.all(
                                        AppTheme.getSmallPadding(screenSize) *
                                            0.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.accentPurple
                                              .withValues(alpha: 0.1),
                                          AppTheme.accentBlue
                                              .withValues(alpha: 0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              AppTheme.getShadowColor(context),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.width * 0.3,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.accentPurple,
                                            AppTheme.accentBlue,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: user?.fotoUrl != null
                                          ? ClipOval(
                                              child: Image.network(
                                                user!.fotoUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: (user?.nombre != null &&
                                                      user!.nombre.isNotEmpty)
                                                  ? Text(
                                                      user.nombre[0]
                                                          .toUpperCase(),
                                                      style: AppTheme.getH1(
                                                              screenSize)
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.person_rounded,
                                                      size: screenSize.width *
                                                          0.15,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.accentPurple,
                                          AppTheme.accentBlue,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentPurple
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: screenSize.width * 0.05,
                                      ),
                                      onPressed: () => _changePhoto(l10n),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Form fields with modern styling
                        _buildSectionTitle(
                            l10n.personalInformation, context, screenSize),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        _buildTextField(
                          controller: _nameController,
                          label: l10n.firstName,
                          icon: Icons.person_outline,
                          l10n: l10n,
                          screenSize: screenSize,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.firstNameRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        _buildTextField(
                          controller: _lastNameController,
                          label: l10n.lastName,
                          icon: Icons.person_outline,
                          l10n: l10n,
                          screenSize: screenSize,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.lastNameRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        _buildTextField(
                          controller: _emailController,
                          label: l10n.email,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          l10n: l10n,
                          screenSize: screenSize,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.emailRequired;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return l10n.enterValidEmail;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        _buildTextField(
                          controller: _phoneController,
                          label: l10n.phone,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          l10n: l10n,
                          screenSize: screenSize,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.phoneRequired;
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Account information card with modern styling
                        _buildSectionTitle(
                            l10n.accountInformation, context, screenSize),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentYellow.withValues(alpha: 0.08),
                                AppTheme.accentBlue.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getMediumRadius(screenSize)),
                            border: Border.all(
                              color:
                                  AppTheme.accentYellow.withValues(alpha: 0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.getShadowColor(context),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                                AppTheme.getMediumPadding(screenSize)),
                            child: Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                final user = userProvider.currentUser;
                                return Column(
                                  children: [
                                    _buildInfoRow(
                                      l10n.userType,
                                      user?.tipo.name ?? l10n.notSpecified,
                                      Icons.badge_outlined,
                                      screenSize,
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Divider(
                                      color: AppTheme.getBorderColor(context),
                                      height: 1,
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                            screenSize)),
                                    _buildInfoRow(
                                      l10n.registrationDate,
                                      user?.fechaRegistro != null
                                          ? _formatDate(user!.fechaRegistro)
                                          : l10n.notAvailable,
                                      Icons.calendar_today_outlined,
                                      screenSize,
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Divider(
                                      color: AppTheme.getBorderColor(context),
                                      height: 1,
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                            screenSize)),
                                    _buildInfoRow(
                                      l10n.associatedStudents,
                                      l10n.studentsCount(
                                          user?.alumnosIds?.length ?? 0),
                                      Icons.school_outlined,
                                      screenSize,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Modern action buttons
                        if (_isEditing) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    border: Border.all(
                                      color: AppTheme.getBorderColor(context),
                                      width: 1,
                                    ),
                                  ),
                                  child: OutlinedButton(
                                    onPressed: _cancelEditing,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          AppTheme.getTextSecondaryColor(
                                              context),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.getMediumRadius(
                                                screenSize)),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: AppTheme.getSmallPadding(
                                              screenSize)),
                                    ),
                                    child: Text(
                                      l10n.cancel,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize)),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentPurple,
                                        AppTheme.accentBlue,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentPurple
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: FilledButton(
                                    onPressed: () => _saveChanges(l10n),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.getMediumRadius(
                                                screenSize)),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: AppTheme.getSmallPadding(
                                              screenSize)),
                                    ),
                                    child: Text(
                                      l10n.save,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
      String title, BuildContext context, Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.5,
        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: screenSize.height * 0.025,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentPurple,
                  AppTheme.accentBlue,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.75),
          Text(
            title,
            style: AppTheme.getH2(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppLocalizations l10n,
    required Size screenSize,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: _isEditing
            ? [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: keyboardType,
        validator: validator,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.1),
                  AppTheme.accentBlue.withValues(alpha: 0.05),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.05,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            borderSide: BorderSide(color: AppTheme.accentPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
          ),
          filled: true,
          fillColor: _isEditing
              ? AppTheme.getCardColor(context)
              : AppTheme.getInputFillColor(context),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTheme.getMediumPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, Size screenSize) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentYellow.withValues(alpha: 0.1),
                AppTheme.accentBlue.withValues(alpha: 0.05),
              ],
            ),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Icon(
            icon,
            size: screenSize.width * 0.05,
            color: AppTheme.accentYellow,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: AppTheme.getSmallPadding(screenSize) * 0.25),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.5),
                  border: Border.all(
                    color: AppTheme.accentYellow.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  value,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentYellow.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _changePhoto(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(
            AppTheme.getMediumPadding(MediaQuery.of(context).size)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppTheme.getIconColor(context),
              ),
              title: Text(
                l10n.takePhoto,
                style: AppTheme.getBodyMedium(MediaQuery.of(context).size)
                    .copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showMessage(l10n.cameraFeatureComingSoon);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppTheme.getIconColor(context),
              ),
              title: Text(
                l10n.selectFromGallery,
                style: AppTheme.getBodyMedium(MediaQuery.of(context).size)
                    .copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showMessage(l10n.galleryFeatureComingSoon);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
              ),
              title: Text(
                l10n.deletePhoto,
                style: AppTheme.getBodyMedium(MediaQuery.of(context).size)
                    .copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showMessage(l10n.photoDeleted);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cancelEditing() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    setState(() {
      _isEditing = false;
      _nameController.text = user?.nombre ?? '';
      _lastNameController.text = user?.apellido ?? '';
      _emailController.text = user?.email ?? '';
      _phoneController.text = user?.telefono ?? '';
    });
  }

  Future<void> _saveChanges(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          nombre: _nameController.text.trim(),
          apellido: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          telefono: _phoneController.text.trim(),
        );

        await userProvider.updateUser(updatedUser);

        setState(() {
          _isEditing = false;
        });

        _showMessage(l10n.dataUpdatedSuccessfully);
      }
    } catch (e) {
      _showMessage('${l10n.errorUpdatingData}: $e');
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
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
