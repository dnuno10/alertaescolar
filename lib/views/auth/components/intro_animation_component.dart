import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;

  late List<String> keyPhrases;
  int currentPhraseIndex = 0;

  @override
  void initState() {
    super.initState();

    // Floating animation for elegant movement
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _floatingController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);

    // Select key phrases for elegant display
    keyPhrases = [
      l10n.qrAttendanceFeature,
      l10n.realTimeNotificationsFeature,
      l10n.securityFeature,
      l10n.alertaEscolarDescription,
      l10n.introWelcomeMessage,
    ];
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return Container(
      height: size.height * 0.5,
      width: double.infinity,
      child: Stack(
        children: [
          // Elegant background with floating elements
          _buildElegantBackground(size, primaryColor),

          // Main content with sophisticated animations
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Classical quote with typewriter inside
                  _buildClassicalQuoteWithTypewriter(
                      size, primaryColor, secondaryColor),

                  SizedBox(height: size.height * 0.06),

                  // Animated feature showcase
                  _buildAnimatedFeatures(size, primaryColor, secondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantBackground(Size size, Color primaryColor) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating geometric elements
            ...List.generate(8, (index) {
              final angle = (index * pi * 2) / 8;
              final radius = size.width * 0.3;
              final x = size.width * 0.5 + cos(angle) * radius;
              final y = size.height * 0.25 + sin(angle) * radius * 0.5;

              return Positioned(
                left: x + _floatingAnimation.value * (index % 2 == 0 ? 1 : -1),
                top: y + _floatingAnimation.value * 0.5,
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.2 - (index * 0.02)),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildClassicalQuoteWithTypewriter(
      Size size, Color primaryColor, Color secondaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: Column(
        children: [
          // Opening quote
          Icon(
            Icons.format_quote,
            size: size.height * 0.025,
            color: primaryColor.withOpacity(0.6),
          ),

          SizedBox(height: size.height * 0.015),

          // Typewriter text inside quote with shimmer
          Container(
            height: size.height * 0.08, // Fixed height to prevent jumping
            child: Center(
              child: Shimmer.fromColors(
                baseColor: primaryColor,
                highlightColor: primaryColor.withOpacity(0.5),
                period: const Duration(seconds: 3),
                child: AnimatedTextKit(
                  animatedTexts: keyPhrases.map((phrase) {
                    return TypewriterAnimatedText(
                      phrase,
                      textAlign: TextAlign.center,
                      textStyle: AppTheme.getH2(size).copyWith(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: primaryColor,
                        height: 1.3,
                        letterSpacing: 0.5,
                      ),
                      speed: const Duration(milliseconds: 80),
                    );
                  }).toList(),
                  repeatForever: true, // Never-ending repetition
                  pause: const Duration(milliseconds: 1500),
                  displayFullTextOnTap: false,
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.015),

          // Closing quote
          Transform.scale(
            scaleX: -1,
            child: Icon(
              Icons.format_quote,
              size: size.height * 0.025,
              color: primaryColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFeatures(
      Size size, Color primaryColor, Color secondaryColor) {
    final l10n = AppLocalizations.of(context);
    final features = [
      {
        'text': l10n.qrAttendanceFeature,
        'icon': Icons.qr_code_scanner_rounded,
      },
      {
        'text': l10n.realTimeNotificationsFeature,
        'icon': Icons.notifications_active_rounded,
      },
      {
        'text': l10n.securityFeature,
        'icon': Icons.security_rounded,
      },
    ];

    return AnimationLimiter(
      child: Column(
        children: [
          // Elegant divider line with animation
          AnimationConfiguration.synchronized(
            duration: const Duration(milliseconds: 800),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  width: size.width * 0.3,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        primaryColor.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.025),

          // Feature cards in a more elegant layout
          Wrap(
            spacing: size.width * 0.04,
            runSpacing: size.height * 0.02,
            alignment: WrapAlignment.center,
            children: List.generate(features.length, (index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 1200),
                child: SlideAnimation(
                  verticalOffset: 40.0,
                  curve: Curves.elasticOut,
                  child: FadeInAnimation(
                    child: ScaleAnimation(
                      scale: 0.8,
                      child: _buildElegantFeatureCard(
                        size,
                        primaryColor,
                        secondaryColor,
                        features[index]['text'] as String,
                        features[index]['icon'] as IconData,
                        index,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantFeatureCard(
    Size size,
    Color primaryColor,
    Color secondaryColor,
    String text,
    IconData icon,
    int index,
  ) {
    return Container(
      width: size.width * 0.26,
      height: size.height * 0.1,
      child: Stack(
        children: [
          // Background card with elegant styling
          Container(
            margin: EdgeInsets.only(top: size.height * 0.015),
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.height * 0.02),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.08),
                  primaryColor.withOpacity(0.03),
                ],
              ),
              border: Border.all(
                color: primaryColor.withOpacity(0.15),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.008),
                // Feature text with elegant typography
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTheme.getCaptionSmall(size).copyWith(
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                      height: 1.2,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Floating icon with elegant positioning
          Positioned(
            top: 0,
            left: size.width * 0.09,
            child: Container(
              width: size.height * 0.03,
              height: size.height * 0.03,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Theme.of(context).scaffoldBackgroundColor,
                size: size.height * 0.015,
              ),
            ),
          ),

          // Subtle accent dot
          Positioned(
            bottom: size.height * 0.008,
            right: size.width * 0.02,
            child: Container(
              width: size.height * 0.008,
              height: size.height * 0.008,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
