import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../components/textfield/custom_input_field.dart';

class SignUpBodyComponent extends StatefulWidget {
  const SignUpBodyComponent({super.key});

  @override
  State<SignUpBodyComponent> createState() => _SignUpBodyComponentState();
}

class _SignUpBodyComponentState extends State<SignUpBodyComponent> {
  // Controlador y FocusNode para el campo de texto del correo electrónico
  late TextEditingController _emailController;
  late FocusNode _emailNode;

  @override
  void initState() {
    _emailController = TextEditingController();
    _emailNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  /// Validar si el correo electrónico tiene un formato válido
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2F3E46);
    final Size size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Barra superior
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios, color: textColor),
                  iconSize: size.height * 0.035,
                ),
                Text(
                  "Alerta Escolar",
                  style: AppTheme.getH2(size).copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: size.height * 0.035 + 16),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.07),

          // Título
          Text(
            l10n.createAccount,
            style: AppTheme.getH2(size).copyWith(
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),

          // Campo de texto para correo electrónico
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.030),
            child: CustomInputField(
              label: l10n.email,
              controller: _emailController,
              focusNode: _emailNode,
              keyboardType: TextInputType.emailAddress,
              screenSize: size,
            ),
          ),

          // Botón para continuar
          SolidButton(
            label: l10n.continue_,
            backgroundColor: Theme.of(context).colorScheme.primary,
            screenSize: size,
            width: size.width * 0.9,
            onPressed: () {
              final email = _emailController.text.trim();

              // Validar correo electrónico antes de continuar
              if (!_isEmailValid(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.enterValidEmail),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              //we verify if the email is not taken
              _checkAndRegisterEmail();
            },
          ),

          // Texto para iniciar sesión
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.alreadyHaveAccount,
                style: AppTheme.getBodyMedium(size).copyWith(
                  fontWeight: FontWeight.w400,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  child: Text(
                    l10n.signIn,
                    style: AppTheme.getBodyMedium(size).copyWith(
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Divider para alternar con otros métodos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.41,
                height: 2,
                color: textColor,
              ),
              Text(
                l10n.or,
                style: AppTheme.getBodyMedium(size).copyWith(
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
              Container(
                width: size.width * 0.41,
                height: 2,
                color: textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndRegisterEmail() async {
    final email = _emailController.text.trim();
    final l10n = AppLocalizations.of(context);

    try {
      // Placeholder for email verification logic
      // For now, we'll navigate to magic link verification
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/verify_magic_link',
          arguments: email,
        );
      }
    } catch (e) {
      // unexpected exception
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.signUpErrorMessage),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
