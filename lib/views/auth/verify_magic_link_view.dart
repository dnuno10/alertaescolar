import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class VerifyMagicLinkView extends StatefulWidget {
  final String email;
  const VerifyMagicLinkView({
    super.key,
    required this.email,
  });

  @override
  State<VerifyMagicLinkView> createState() => _VerifyMagicLinkViewState();
}

class _VerifyMagicLinkViewState extends State<VerifyMagicLinkView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // If all fields are filled, proceed automatically
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      Navigator.pushReplacementNamed(
        context,
        '/finish_setting_up',
        arguments: {'email': widget.email, 'code': code},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2F3E46);
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.05),

                  /// Título e instrucciones
                  _title(size, primaryColor, l10n),
                  SizedBox(height: size.height * 0.025),
                  _desc(size, textColor, primaryColor, l10n),

                  SizedBox(height: size.height * 0.04),

                  /// Campo para el código (PinCodeFields)
                  _codeField(size, textColor, primaryColor, isDark),

                  /// Botones extra: abrir correo y reenviar
                  SizedBox(height: size.height * 0.04),
                  _sendMailButton(size, textColor, primaryColor, l10n),
                  SizedBox(height: size.height * 0.02),
                  _returnHome(size, textColor, l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets de UI
  // ---------------------------------------------------------------------------

  Widget _title(Size size, Color primaryColor, AppLocalizations l10n) {
    return Text(
      l10n.verifyCode,
      style: AppTheme.getH1(size).copyWith(
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _desc(
      Size size, Color textColor, Color primaryColor, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: l10n.codeSentTo,
              style: AppTheme.getBodyMedium(size).copyWith(
                fontWeight: FontWeight.w400,
                color: textColor.withOpacity(0.8),
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
            TextSpan(
              text: widget.email,
              style: AppTheme.getBodyMedium(size).copyWith(
                fontWeight: FontWeight.w600,
                color: primaryColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeField(
      Size size, Color textColor, Color primaryColor, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: size.height * 0.02,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * 0.04),
        color: isDark
            ? primaryColor.withOpacity(0.1)
            : primaryColor.withOpacity(0.05),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.width * 0.02),
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                color: textColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTheme.getH2(size).copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => _onCodeChanged(value, index),
            ),
          );
        }),
      ),
    );
  }

  Widget _sendMailButton(
      Size size, Color textColor, Color primaryColor, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size.height * 0.01),
        splashColor: primaryColor.withOpacity(0.1),
        onTap: () {
          Navigator.pushReplacementNamed(
            context,
            '/verify_magic_link',
            arguments: widget.email,
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.015,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                size: size.height * 0.024,
                color: primaryColor,
              ),
              SizedBox(width: size.width * 0.025),
              Text(
                l10n.resendCode,
                style: AppTheme.getBodyMedium(size).copyWith(
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _returnHome(Size size, Color textColor, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size.height * 0.01),
        splashColor: textColor.withOpacity(0.1),
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
          ),
          child: Text(
            'Cambiar correo',
            style: AppTheme.getBodyMedium(size).copyWith(
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.7),
              letterSpacing: 0.2,
              decoration: TextDecoration.underline,
              decorationColor: textColor.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
