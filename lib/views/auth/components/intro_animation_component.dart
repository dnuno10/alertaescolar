import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class IntroAnimationComponent extends StatefulWidget {
  const IntroAnimationComponent({super.key});

  @override
  State<IntroAnimationComponent> createState() =>
      _IntroAnimationComponentState();
}

class _IntroAnimationComponentState extends State<IntroAnimationComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<String> keyPhrases;
  int currentPhraseIndex = 0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);

    keyPhrases = [
      l10n.introWelcomeMessage,
      l10n.qrAttendanceFeature,
      l10n.realTimeNotificationsFeature,
      l10n.securityFeature,
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoSection(screenSize),
              SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
              _buildTextSection(screenSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(Size screenSize) {
    return Image.asset(
      'images/alertaescolar_logo.png',
      width: screenSize.height * 0.08,
      height: screenSize.height * 0.08,
      color: AppTheme.getTextPrimaryColor(context),
    );
  }

  Widget _buildTextSection(Size screenSize) {
    return SizedBox(
      width: screenSize.width * 0.85,
      child: Column(
        children: [
          // App name
          Text(
            'Alerta Escolar',
            style: TextStyle(
              fontSize: screenSize.height * 0.035,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          Container(
            height: screenSize.height * 0.12,
            alignment: Alignment.topCenter,
            child: DefaultTextStyle(
              style: AppTheme.getBodyLarge(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontSize: screenSize.height * 0.022,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              child: AnimatedTextKit(
                animatedTexts: keyPhrases.map((phrase) {
                  return TypewriterAnimatedText(
                    phrase,
                    textAlign: TextAlign.center,
                    speed: const Duration(milliseconds: 80),
                    curve: Curves.easeInOut,
                  );
                }).toList(),
                repeatForever: true,
                pause: const Duration(milliseconds: 2000),
                onNext: (index, isLast) {
                  if (!mounted) return;
                  setState(() => currentPhraseIndex = index);
                },
              ),
            ),
          ),

          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(keyPhrases.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: currentPhraseIndex == index ? 24 : 8,
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: currentPhraseIndex == index
                      ? AppTheme.accentPurple
                      : AppTheme.getBorderColor(context),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
