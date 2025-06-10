import 'package:alertaescolar/components/custom_input_field.dart';
import 'package:alertaescolar/components/nav_header.dart';
import 'package:alertaescolar/components/solid_button.dart';
import 'package:alertaescolar/components/tips_cards/instructions_card.dart';
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
                    _buildQRScanOption(context, l10n, screenSize),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildDivider(context, l10n, screenSize),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildManualInput(context, l10n, screenSize),
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

  Widget _buildQRScanOption(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _scanQRCode(l10n),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Column(
              children: [
                Container(
                  width: screenSize.width * 0.2,
                  height: screenSize.width * 0.2,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppTheme.accentPurple,
                    size: screenSize.width * 0.1,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                Text(
                  l10n.scanQRCode,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  l10n.useCameraToScanQR,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize)),
          child: Text(
            l10n.or,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInput(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.manualEntry,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              l10n.enterStudentKeyCode,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            CustomInputField(
              label: l10n.keyCode,
              controller: _keyController,
              icon: Icons.key_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterKeyCode;
                }
                if (value.trim().length < 6) {
                  return l10n.keyCodeMinLength;
                }
                return null;
              },
              screenSize: screenSize,
            ),
          ],
        ),
      ),
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
