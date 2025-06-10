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
              _buildStickyHeader(context, l10n, screenSize),
              SliverToBoxAdapter(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: AppTheme.getMediumPadding(screenSize),
                    right: AppTheme.getMediumPadding(screenSize),
                    bottom: AppTheme.getMediumPadding(screenSize)),
                child: Column(
                  children: [
                    SizedBox(height: AppTheme.getLargePadding(screenSize)),
                    _buildInstructions(context, l10n, screenSize),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildQRScanOption(context, l10n, screenSize),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildDivider(context, l10n, screenSize),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildManualInput(context, l10n, screenSize),
                    SizedBox(height: AppTheme.getLargePadding(screenSize)),
                    _buildLinkButton(context, l10n, screenSize),
                  ],
                ),
              ))
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize)),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: screenSize.width * 0.1,
                        height: screenSize.width * 0.1,
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.accentPurple,
                            size: screenSize.width * 0.05,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Expanded(
                        child: Text(
                          l10n.addStudent,
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.accentBlue,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.instructions,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.linkStudentInstructions,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
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
            TextFormField(
              controller: _keyController,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              decoration: InputDecoration(
                labelText: l10n.keyCode,
                labelStyle: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                hintText: l10n.keyCodeExample,
                hintStyle: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                prefixIcon: Icon(
                  Icons.key_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.width * 0.06,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide:
                      BorderSide(color: AppTheme.getBorderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide:
                      BorderSide(color: AppTheme.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide:
                      BorderSide(color: AppTheme.accentPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
                ),
                filled: true,
                fillColor: AppTheme.getInputFillColor(context),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterKeyCode;
                }
                if (value.trim().length < 6) {
                  return l10n.keyCodeMinLength;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _linkStudent(l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentPurple,
          foregroundColor: AppTheme.onPrimaryColor,
          disabledBackgroundColor: AppTheme.getBorderColor(context),
          padding: EdgeInsets.symmetric(
              vertical: AppTheme.getSmallPadding(screenSize)),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          elevation: 0,
        ),
        icon: _isLoading
            ? SizedBox(
                width: screenSize.width * 0.05,
                height: screenSize.width * 0.05,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.onPrimaryColor,
                ),
              )
            : Icon(
                Icons.link_rounded,
                color: AppTheme.onPrimaryColor,
                size: screenSize.width * 0.06,
              ),
        label: Text(
          _isLoading ? l10n.linking : l10n.linkStudent,
          style: AppTheme.getBodyLarge(screenSize).copyWith(
            color: AppTheme.onPrimaryColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
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
