import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/students/qr_scan_option_card.dart';
import 'package:alertaescolar/components/students/option_divider.dart';
import 'package:alertaescolar/components/students/manual_input_card.dart';
import 'package:alertaescolar/views/user/students/qr_scanner_view.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';
import '../../../app/app_theme.dart';
import '../../../app/app_routes.dart';
import '../../../components/loading_dialog.dart';

class AddStudentView extends StatefulWidget {
  const AddStudentView({super.key});

  @override
  State<AddStudentView> createState() => _AddStudentViewState();
}

class _AddStudentViewState extends State<AddStudentView> {
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _keyController.dispose();
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
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context)
                .unfocus(), // cierra teclado al tocar fuera
            child: CustomScrollView(
              slivers: [
                NavHeader(title: l10n.addStudent),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: AppTheme.getMediumPadding(screenSize),
                      right: AppTheme.getMediumPadding(screenSize),
                      bottom: AppTheme.getMediumPadding(screenSize),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                        QRScanOptionCard(
                          onTap: () => _openQRScanner(l10n),
                          screenSize: screenSize,
                        ),
                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                        OptionDivider(screenSize: screenSize),
                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                        ManualInputCard(
                          formKey: _formKey,
                          keyController: _keyController,
                          screenSize: screenSize,
                        ),
                        SizedBox(height: AppTheme.getLargePadding(screenSize)),
                        SolidButton(
                          width: double.infinity,
                          icon: Icons.search_rounded,
                          onPressed: _isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  _validateKeyCode(l10n);
                                },
                          label: l10n.validateCode,
                          semanticsLabel: l10n.validateCode,
                          screenSize: screenSize,
                        ),
                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openQRScanner(AppLocalizations l10n) {
    if (_isLoading) return; // evita abrir el scanner durante carga
    FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onCodeScanned: (code) {
            if (!mounted || _isLoading)
              return; // blindaje doble por si llega tarde
            Navigator.of(context).pop();
            _keyController.text = code;
            FocusScope.of(context).unfocus();
            _validateKeyCode(l10n);
          },
          onClose: () => Navigator.of(context).pop(),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _validateKeyCode(AppLocalizations l10n) async {
    if (_isLoading) return; // evita dobles envíos
    if (!_formKey.currentState!.validate()) return;

    final keyCode = _keyController.text.trim();
    if (keyCode.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // Loader modal único (sin spinner inline en el botón)
    LoadingDialog.show(context, message: l10n.validatingCode);

    try {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final currentUser = userProvider.currentUser;
      if (currentUser == null) {
        throw Exception(l10n.userNotFound);
      }

      final validationResult =
          await studentProvider.validateStudentKeyCode(keyCode);

      if (!mounted) return;

      if (validationResult != null && validationResult['isValid'] == true) {
        // Checa si ya existe relación tutor-estudiante
        final alreadyHasStudent =
            await studentProvider.checkIfUserAlreadyHasStudent(
          studentId: validationResult['student']['id'],
          tutorId: currentUser.id,
        );

        LoadingDialog.hide(context);

        if (alreadyHasStudent) {
          _showErrorSnackBar(
              'Ya tienes este estudiante registrado en tu cuenta');
          return;
        }

        // Pequeño delay para asegurar que el diálogo cerró antes de navegar
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;

        Navigator.pushNamed(
          context,
          AppRoutes.studentConfirmation,
          arguments: validationResult,
        );
      } else {
        LoadingDialog.hide(context);
        final error = studentProvider.error ?? l10n.invalidStudentCode;
        _showErrorSnackBar(error);
      }
    } catch (e) {
      if (!mounted) return;
      LoadingDialog.hide(context);
      _showErrorSnackBar('${l10n.errorValidatingCode}: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(MediaQuery.of(context).size),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text(
          message,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(MediaQuery.of(context).size),
          ),
        ),
      ),
    );
  }
}
