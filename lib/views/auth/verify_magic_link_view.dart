import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

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
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  late TextEditingController _pinController;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isResending = false;
  String _currentPin = '';

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();

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
    for (var controller in _controllers) {
      controller.dispose();
    }

    _fadeController.dispose();
    super.dispose();
  }

  void _onPinChanged(String pin) {
    setState(() {
      _currentPin = pin;
    });
  }

  void _verifyCode(String code) {
    Navigator.pushReplacementNamed(
      context,
      '/finish_setting_up',
      arguments: {'email': widget.email, 'code': code},
    );
  }

  Future<void> _resendCode() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    final l10n = AppLocalizations.of(context);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isResending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.codeResentSuccessfully),
          backgroundColor: AppTheme.accentBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size),
            ),
          ),
          margin: EdgeInsets.all(
            AppTheme.getMediumPadding(MediaQuery.of(context).size),
          ),
        ),
      );
    }
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
                            MediaQuery.of(context).size)),
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
        controller: _pinController,
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
          activeFillColor: AppTheme.getCardColor(context),
          inactiveFillColor: AppTheme.getCardColor(context),
          selectedFillColor: AppTheme.getCardColor(context),
          activeColor: AppTheme.accentPurple,
          inactiveColor: AppTheme.getBorderColor(context),
          selectedColor: AppTheme.accentPurple,
          borderWidth: 2,
        ),
        enableActiveFill: true,
        onCompleted: (pin) {
          _verifyCode(pin);
        },
        onChanged: _onPinChanged,
        animationType: AnimationType.fade,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        autoFocus: true,
        useHapticFeedback: true,
      ),
    );
  }

  Widget _buildResendSection(Size size, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _isResending ? null : _resendCode,
          child: _isResending
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentPurple,
                    ),
                  ),
                )
              : Text(
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
