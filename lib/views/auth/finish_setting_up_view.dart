import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';
import '../../components/textfield/custom_input_field.dart';
import '../../managers/auth/FinishSettingUp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/custom_snack_bar.dart';

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
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.getTextPrimaryColor(context),
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.getCardColor(context),
              elevation: 2,
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
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -8),
          ),
        ],
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
                  // Welcome description
                  _buildWelcomeDescription(size, l10n),

                  SizedBox(height: AppTheme.getLargePadding(size)),

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
                            : AppTheme.accentPurple.withOpacity(0.6),
                        screenSize: size,
                        width: size.width * 0.9,
                        onPressed: () {
                          _isFormValid ? _finishSetup : null;
                        },
                      );
                    },
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Return to start link
                  _buildReturnToStartSection(size, l10n),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Terms & Privacy at bottom
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getMediumPadding(size),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color:
                              AppTheme.getBorderColor(context).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/terms');
                          },
                          child: Text(
                            l10n.termsOfService,
                            style: AppTheme.getCaptionSmall(size).copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getSmallPadding(size),
                          ),
                          child: Container(
                            height: size.height * 0.015,
                            width: 1,
                            color: AppTheme.getTextSecondaryColor(context)
                                .withOpacity(0.3),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/privacy');
                          },
                          child: Text(
                            l10n.privacyPolicy,
                            style: AppTheme.getCaptionSmall(size).copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(size)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeDescription(Size size, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(size),
        vertical: AppTheme.getMediumPadding(size),
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(
          color: AppTheme.accentPurple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_outlined,
            color: AppTheme.accentPurple,
            size: size.height * 0.04,
          ),
          SizedBox(height: AppTheme.getSmallPadding(size)),
          Text(
            l10n.pleaseCompleteYourProfile,
            textAlign: TextAlign.center,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(size) * 0.5),
          Text(
            l10n.thisInformationWillBeUsedForYourProfile,
            textAlign: TextAlign.center,
            style: AppTheme.getCaptionSmall(size).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.3,
            ),
          ),
        ],
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

  void _finishSetup() {
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
      );

      finishSettingUp.settingUpAccount();
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
