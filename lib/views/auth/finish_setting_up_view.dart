import 'package:alertaescolar/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';
import '../../components/textfield/custom_input_field.dart';
import '../../managers/auth/FinishSettingUp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/custom_snack_bar.dart';
import '../../models/usuario.dart';

class FinishSettingUpView extends StatefulWidget {
  const FinishSettingUpView({super.key});

  @override
  State<FinishSettingUpView> createState() => _FinishSettingUpViewState();
}

class _FinishSettingUpViewState extends State<FinishSettingUpView>
    with TickerProviderStateMixin {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late FocusNode _firstNameNode;
  late FocusNode _lastNameNode;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  TipoUsuario _selectedUserType = TipoUsuario.padre;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _firstNameNode = FocusNode();
    _lastNameNode = FocusNode();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: SafeArea(
            child: Column(
              children: [
                // Header section
                _buildHeader(size, l10n),
                // Expanded content
                Expanded(
                  child: _buildSetupForm(size, l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.intro,
                (route) => false,
              );
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.getTextPrimaryColor(context),
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.getCardColor(context),
              elevation: 0,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(size)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.welcomeToAlertaEscolar,
                  style: AppTheme.getCaption(size).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.setting,
                  style: AppTheme.getH2(size).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupForm(Size size, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.getLargeRadius(size) * 1.5),
          topRight: Radius.circular(AppTheme.getLargeRadius(size) * 1.5),
        ),
        boxShadow: const [],
      ),
      child: Column(
        children: [
          // Header pill
          Container(
            width: size.width * 0.15,
            height: 4,
            margin: EdgeInsets.only(
              top: AppTheme.getMediumPadding(size),
              bottom: AppTheme.getLargePadding(size),
            ),
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(size),
              ),
              child: Column(
                children: [
                  // First Name field
                  CustomInputField(
                    controller: _firstNameController,
                    label: l10n.firstName,
                    screenSize: size,
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    focusNode: _firstNameNode,
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Last Name field
                  CustomInputField(
                    controller: _lastNameController,
                    label: l10n.lastName,
                    screenSize: size,
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    focusNode: _lastNameNode,
                  ),

                  SizedBox(height: AppTheme.getLargePadding(size)),

                  // User Type Selection
                  _buildUserTypeSelection(size, l10n),

                  SizedBox(height: AppTheme.getLargePadding(size)),

                  // Continue button
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _firstNameController,
                      _lastNameController,
                    ]),
                    builder: (context, child) {
                      return SolidButton(
                        label: l10n.continueText,
                        backgroundColor: _isFormValid
                            ? AppTheme.accentPurple
                            // ignore: deprecated_member_use
                            : AppTheme.accentPurple.withOpacity(0.6),
                        screenSize: size,
                        width: size.width * 0.9,
                        onPressed: _isFormValid
                            ? () {
                                HapticFeedback.mediumImpact();
                                _finishSetup();
                              }
                            : null,
                      );
                    },
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Return to start link
                  _buildReturnToStartSection(size, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelection(Size size, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppTheme.accentPurple.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppTheme.accentPurple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.family_restroom,
                color: AppTheme.accentPurple,
                size: MediaQuery.of(context).size.height * 0.03,
              ),
              SizedBox(width: AppTheme.getSmallPadding(size)),
              Text(
                l10n.relationshipType,
                style: AppTheme.getBodyLarge(size).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(size)),

          Text(
            l10n.selectYourRelationshipWithStudent,
            style: AppTheme.getCaption(size).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(size)),

          // User type options in a grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: AppTheme.getMediumPadding(size) * 0.8,
            crossAxisSpacing: AppTheme.getMediumPadding(size) * 0.8,
            children: [
              _buildUserTypeOption(
                size,
                TipoUsuario.padre,
                l10n.father,
                Icons.man,
              ),
              _buildUserTypeOption(
                size,
                TipoUsuario.madre,
                l10n.mother,
                Icons.woman,
              ),
              _buildUserTypeOption(
                size,
                TipoUsuario.tutor,
                l10n.tutor,
                Icons.school,
              ),
              _buildUserTypeOption(
                size,
                TipoUsuario.familiar,
                l10n.relative,
                Icons.people,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeOption(
      Size size, TipoUsuario userType, String label, IconData icon) {
    final isSelected = _selectedUserType == userType;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            // ignore: deprecated_member_use
            ? AppTheme.accentPurple.withOpacity(0.15)
            : AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(
          color: isSelected
              ? AppTheme.accentPurple
              : AppTheme.getBorderColor(context),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _selectedUserType = userType;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getMediumPadding(size) * 0.8,
              vertical: AppTheme.getSmallPadding(size) * 0.8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.accentPurple
                        : AppTheme.accentPurple,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(size) * 0.7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: AppTheme.getBodyMedium(size).copyWith(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.getTextPrimaryColor(context),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnToStartSection(Size size, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.needHelp,
          style: AppTheme.getBodyMedium(size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Supabase.instance.client.auth.signOut();
            Navigator.pushReplacementNamed(context, '/intro');
          },
          child: Text(
            l10n.returnToStart,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: AppTheme.accentPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _finishSetup() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final l10n = AppLocalizations.of(context);

    if (firstName.isEmpty || lastName.isEmpty) {
      _showErrorSnackBar(l10n.pleaseEnterFullName);
      return;
    }

    try {
      // Get current user from Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showErrorSnackBar(l10n.errorSettingUpAccount);
        return;
      }

      // Use the FinishSettingUp manager
      final finishSettingUp = FinishSettingUp(
        context: context,
        idUser: user.id,
        email: user.email ?? '',
        nombre: firstName,
        apellido: lastName,
        tipo: _selectedUserType, // Pass the selected user type
      );

      await finishSettingUp.settingUpAccount();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(l10n.errorSettingUpAccount);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    CustomSnackBar.show(
      context: context,
      message: message,
      isError: true,
    );
  }
}
