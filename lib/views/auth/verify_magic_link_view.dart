import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/auth/VerifyMagicLink.dart'; // VerifyResult, VerifyNext
import '../../widgets/custom_snack_bar.dart';
import '../../managers/auth/SendingMagicLink.dart'; // SendingResult

class VerifyMagicLinkView extends StatefulWidget {
  final String email;
  const VerifyMagicLinkView({
    super.key,
    required this.email,
  });

  @override
  State<VerifyMagicLinkView> createState() => _VerifyMagicLinkViewState();
}

class _VerifyMagicLinkViewState extends State<VerifyMagicLinkView>
    with TickerProviderStateMixin {
  // ✅ Eliminamos TextEditingController para evitar el error al disponerlo
  // El PinCodeTextField manejará su estado interno.
  String _currentPin = '';
  bool _isVerifying = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

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
    // ❌ _pinController.dispose();  // Eliminado
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode(String code) async {
    if (_isVerifying) return; // evita dobles toques/llamadas
    _isVerifying = true;

    final l10n = AppLocalizations.of(context);

    if (code.isEmpty || code.length != 6) {
      _showErrorSnackBar(l10n.enterCompleteCode);
      _isVerifying = false;
      return;
    }

    LoadingDialog.show(context, message: l10n.verifyingCode);

    try {
      final verifyManager = VerifyMagicLink(
        context: context,
        email: widget.email,
        code: code,
      );
      final result = await verifyManager.verifyCode();

      if (!mounted) return;

      // Mostrar mensaje de éxito
      CustomSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );

      // Navegar según el siguiente paso recomendado
      switch (result.next) {
        case VerifyNext.finishSetup:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/finish_setting_up',
            (route) => false,
          );
          break;
        case VerifyNext.admin:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin',
            (route) => false,
          );
          break;
        case VerifyNext.home:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: l10n.invalidVerificationCode,
        isError: true,
      );
    } finally {
      if (mounted) LoadingDialog.hide(context);
      _isVerifying = false;
    }
  }

  Future<void> _resendCode() async {
    final l10n = AppLocalizations.of(context);
    LoadingDialog.show(context, message: l10n.resendingCode);

    try {
      final sendingManager = SendingMagicLink(
        context: context,
        email: widget.email,
      );

      // Unificado:
      final res = await sendingManager.requestMagicLink(isResend: true);

      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: res.message,
        isError: !res.success,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: l10n.errorResendingCode,
        isError: true,
      );
    } finally {
      if (mounted) LoadingDialog.hide(context);
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
                  child: _buildVerificationForm(size, l10n),
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
          Material(
            color: AppTheme.getCardColor(context),
            elevation: 2,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.getTextPrimaryColor(context),
                size: 20,
              ),
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(size)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.verification,
                  style: AppTheme.getCaption(size).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.verifyCode,
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

  Widget _buildVerificationForm(Size size, AppLocalizations l10n) {
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
              child: Column(
                children: [
                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getMediumPadding(
                        MediaQuery.of(context).size,
                      ),
                    ),
                    child: _buildDescription(size, l10n),
                  ),

                  SizedBox(height: AppTheme.getLargePadding(size)),

                  // PIN Code input
                  _buildPinCodeField(size),

                  SizedBox(height: AppTheme.getMediumPadding(size)),

                  // Resend code option
                  _buildResendSection(size, l10n),

                  SizedBox(height: AppTheme.getMediumPadding(size)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Size size, AppLocalizations l10n) {
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
            Icons.mark_email_read_outlined,
            color: AppTheme.accentPurple,
            size: size.height * 0.04,
          ),
          SizedBox(height: AppTheme.getSmallPadding(size)),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${l10n.codeSentTo} ",
                  style: AppTheme.getBodyMedium(size).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    height: 1.4,
                  ),
                ),
                TextSpan(
                  text: widget.email,
                  style: AppTheme.getBodyMedium(size).copyWith(
                    color: AppTheme.accentPurple,
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

  Widget _buildPinCodeField(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(size),
        vertical: AppTheme.getMediumPadding(size),
      ),
      child: PinCodeTextField(
        appContext: context,
        backgroundColor: Colors.transparent,
        length: 6,
        // ✅ Sin controller externo: evitamos el error de "used after being disposed"
        keyboardType: TextInputType.number,
        textStyle: AppTheme.getH2(size).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
          fontWeight: FontWeight.w600,
        ),
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
          fieldHeight: size.width * 0.14,
          fieldWidth: size.width * 0.12,
          activeFillColor: AppTheme.accentPurple.withOpacity(0.2),
          inactiveFillColor: AppTheme.accentPurple.withOpacity(0.05),
          selectedFillColor: AppTheme.accentPurple.withOpacity(0.2),
          activeColor: AppTheme.accentPurple,
          inactiveColor: AppTheme.accentPurple.withOpacity(0.2),
          selectedColor: AppTheme.accentPurple,
          borderWidth: 2,
        ),
        enableActiveFill: true,
        onChanged: (v) => _currentPin = v,
        onCompleted: (pin) => _verifyCode(pin),
        animationType: AnimationType.fade,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        autoFocus: true,
        useHapticFeedback: true,
        beforeTextPaste: (text) => true, // permitir pegar
      ),
    );
  }

  Widget _buildResendSection(Size size, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _resendCode();
          },
          child: Text(
            l10n.resendCode,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: AppTheme.accentPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
