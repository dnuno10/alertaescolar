import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../components/buttons/solid_button.dart';
import '../../components/textfield/custom_input_field.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FinishSettingUpView extends StatefulWidget {
  const FinishSettingUpView({super.key});

  @override
  State<FinishSettingUpView> createState() => _FinishSettingUpViewState();
}

class _FinishSettingUpViewState extends State<FinishSettingUpView>
    with SingleTickerProviderStateMixin {
  bool _showDescription = false;
  bool _showInputField = false;
  late FocusNode nodeName;
  late TextEditingController controllerName;
  bool _isTextFieldEmpty = true;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    nodeName = FocusNode();
    controllerName = TextEditingController();
    controllerName.addListener(_onTextChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    nodeName.dispose();
    controllerName.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldEmpty = controllerName.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2F3E46);
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Size size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    // Mantén el almacenamiento del idioma
    Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.05),

                  // Classical Title with Theme Primary Color
                  DefaultTextStyle(
                    style: AppTheme.getH1(size).copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      letterSpacing: 0.3,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          l10n.welcomeToAlertaEscolar,
                          speed: const Duration(milliseconds: 50),
                        ),
                      ],
                      totalRepeatCount: 1,
                      onFinished: () {
                        setState(() => _showDescription = true);
                      },
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // Description with Theme Text Color
                  if (_showDescription)
                    DefaultTextStyle(
                      style: AppTheme.getBodyMedium(size).copyWith(
                        fontWeight: FontWeight.w400,
                        color: textColor,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            l10n.pleaseCompleteYourProfile,
                            speed: const Duration(milliseconds: 30),
                          ),
                        ],
                        totalRepeatCount: 1,
                        onFinished: () {
                          setState(() => _showInputField = true);
                          _animationController.forward();
                        },
                      ),
                    ),

                  // Input Section
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _showInputField
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: EdgeInsets.only(top: size.height * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Question Text with Theme Colors
                                  Text(
                                    l10n.pleaseEnterFullName,
                                    style:
                                        AppTheme.getBodyMedium(size).copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),

                                  SizedBox(height: size.height * 0.025),

                                  // Text Field
                                  CustomInputField(
                                    label: l10n.fullName,
                                    controller: controllerName,
                                    focusNode: nodeName,
                                    screenSize: size,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),

                                  SizedBox(height: size.height * 0.03),

                                  // Continue Button using Theme Colors
                                  SolidButton(
                                    label: l10n.continueText,
                                    width: size.width,
                                    backgroundColor: _isTextFieldEmpty
                                        ? primaryColor.withOpacity(0.6)
                                        : primaryColor,
                                    screenSize: size,
                                    onPressed: () {
                                      if (_isTextFieldEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(l10n.pleaseEnterFullName),
                                            backgroundColor:
                                                AppTheme.errorColor,
                                          ),
                                        );
                                      } else {
                                        Navigator.pushReplacementNamed(
                                            context, '/');
                                      }
                                    },
                                  ),

                                  SizedBox(height: size.height * 0.02),

                                  // Return Home Button - Classical Style
                                  _buildReturnHome(
                                      context, size, textColor, l10n),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnHome(
      BuildContext context, Size size, Color textColor, AppLocalizations l10n) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size.height * 0.01),
          splashColor: textColor.withOpacity(0.1),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/intro');
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
            ),
            child: Text(
              'Regresar al inicio',
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
      ),
    );
  }
}
