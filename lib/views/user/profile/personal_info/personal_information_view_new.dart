import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/profile/personal_info_section_title.dart';
import 'package:alertaescolar/components/profile/personal_info_form_card.dart';
import 'package:alertaescolar/components/profile/current_name_display_card.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../managers/user_provider.dart';
import '../../../../app/app_theme.dart';

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
                      PersonalInfoSectionTitle(
                        title: l10n.editInformation,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      PersonalInfoFormCard(
                        formKey: _formKey,
                        nameController: _nameController,
                        lastNameController: _lastNameController,
                        isLoading: _isLoading,
                        onReset: () => _resetForm(l10n),
                        onSave: () => _saveChanges(l10n),
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Display current full name with simple styling
                      CurrentNameDisplayCard(screenSize: screenSize),

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

  Future<void> _saveChanges(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Llamamos directamente al nuevo método específico
      await userProvider.updatePersonalInfo(_nameController.text.trim(),
          _lastNameController.text.trim(), context);
    } catch (e) {
      _showMessage('${l10n.errorUpdatingInformation}: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm(AppLocalizations l10n) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    setState(() {
      _nameController.text = user?.nombre ?? '';
      _lastNameController.text = user?.apellido ?? '';
    });
    _showMessage(l10n.formReset);
  }

  void _showMessage(String message, {bool isError = false}) {
    CustomSnackBar.show(
      context: context,
      message: message,
      isError: isError,
      duration: const Duration(seconds: 3),
    );
  }
}
