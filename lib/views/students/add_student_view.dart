import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/tips_cards/instructions_card.dart';
import 'package:alertaescolar/components/students/qr_scan_option_card.dart';
import 'package:alertaescolar/components/students/option_divider.dart';
import 'package:alertaescolar/components/students/manual_input_card.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

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
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.addStudent),
              SliverToBoxAdapter(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: AppTheme.getMediumPadding(screenSize),
                    right: AppTheme.getMediumPadding(screenSize),
                    bottom: AppTheme.getMediumPadding(screenSize)),
                child: Column(
                  children: [
                    SizedBox(height: AppTheme.getLargePadding(screenSize)),
                    InstructionsCard(
                      l10n: l10n,
                      screenSize: screenSize,
                    ),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    QRScanOptionCard(
                      onTap: () => _scanQRCode(l10n),
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
                        icon: Icons.link_rounded,
                        onPressed: () {
                          _isLoading ? null : () => _linkStudent(l10n);
                        },
                        label: _isLoading ? l10n.linking : l10n.linkStudent,
                        screenSize: screenSize),
                  ],
                ),
              ))
            ],
          ),
        );
      },
    );
  }

  void _scanQRCode(AppLocalizations l10n) {
    // TODO: Implement QR scanner using camera plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.qrScanFunctionalityComingSoon,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
  }

  void _linkStudent(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);

      // TODO: Replace with actual API call to link student by key
      final newStudent = Alumno(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: '${l10n.student} ${_keyController.text.substring(0, 3)}',
        grado: l10n.toConfirm,
        llave: _keyController.text.trim(),
        activo: true,
        turno: Turno.matutino, // Default to matutino shift
      );

      await studentProvider.addStudent(newStudent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.studentLinkedSuccessfully,
              style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                color: AppTheme.onPrimaryColor,
              ),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(MediaQuery.of(context).size)),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.errorLinkingStudent}: $e',
              style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                color: AppTheme.onPrimaryColor,
              ),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(MediaQuery.of(context).size)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
