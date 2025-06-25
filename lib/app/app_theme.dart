import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Modern Color Palette - Specified Design System
  static const Color primaryColor =
      Color(0xFF000000); // CTA buttons - pure black
  static const Color primaryColorDark = Color(0xFF1A1A1A);
  static const Color secondaryColor = Color(0xFF58CC02); // Keep existing green

  // Modern Accent Colors - As Specified
  static const Color accentPurple = Color(0xFF9B5DE5); // Purple accent
  static const Color accentYellow =
      Color(0xFFFDCB5A); // Yellow accent (updated)
  static const Color accentBlue = Color(0xFF3A86FF); // Blue accent
  static const Color accentOrange = Color(0xFFFF6B35); // Orange accent
  static const Color accentGold =
      Color(0xFFFDCB5A); // Gold accent (alias to yellow)

  // Status Colors
  static const Color successColor = Color(0xFF58CC02);
  static const Color warningColor =
      Color(0xFFFDCB5A); // Updated to match accent yellow
  static const Color errorColor = Color(0xFFFF4757);
  static const Color infoColor =
      Color(0xFF3A86FF); // Updated to match accent blue

  // 🌈 Background Colors - Modern & Clean
  static const Color backgroundLight =
      Color(0xFFF6F7FB); // Specified background
  static const Color backgroundDark = Color(0xFF1C1C1E); // Dark background
  static const Color surfaceLight = Color(0xFFFFFFFF); // Cards - pure white
  static const Color surfaceDark = Color(0xFF2C2C2E); // Dark surface color
  static const Color cardLight = Color(0xFFFFFFFF); // Pure white cards
  static const Color cardDark = Color(0xFF2C2C2E); // Dark card color

  // 📝 Text Colors - Specified High Contrast
  static const Color textPrimaryLight =
      Color(0xFF1C1C1E); // Primary text - specified
  static const Color textSecondaryLight =
      Color(0xFF7A7A7A); // Secondary text - specified
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFAEAEB2);

  // 🔲 Border Colors - Subtle & Clean
  static const Color borderLight = Color(0xFFE5E5E7); // Subtle border color
  static const Color borderDark = Color(0xFF3A3A3C); // Dark divider color

  // 🎯 Icon Container Colors
  static const Color iconContainerPurple = Color(0xFF9B5DE5);
  static const Color iconContainerBlue = Color(0xFF3A86FF);

  // 🔘 Additional UI Colors - Subtle shadows as specified
  static const Color shadowLight =
      Color(0x0A000000); // 4% black shadow (rgba(0,0,0,0.04))
  static const Color shadowDark = Color(0x4D000000); // 30% black shadow

  // 🔧 Missing Color Properties for Attendance View
  static const Color backgroundColor = backgroundLight;
  static const Color surfaceColor = surfaceLight;
  static const Color onPrimaryColor =
      Color(0xFFFFFFFF); // White text on primary
  static const Color onPrimarySecondaryColor =
      Color(0xFFB3B3B3); // Light gray on primary
  static const Color primaryLightColor = Color(0x1A000000); // 10% black opacity

  static const Color iconColor = textPrimaryLight;
  static const Color inputFillColor =
      Color(0xFFF8F9FA); // Light input background
  static const Color inputFillColorDark =
      Color(0xFF3A3A3C); // Dark input background
  static const Color neutralLightColor =
      Color(0xFFF5F5F5); // Neutral background
  static const Color neutralLightColorDark =
      Color(0xFF4A4A4A); // Dark neutral background
  static const Color onErrorColor =
      Color(0xFFFFFFFF); // White text on error background
  static const Color shadowColor = shadowLight;

  // 📏 Design Constants - Specified Border Radius
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 20.0; // 20-24px as specified
  static const double borderRadiusLarge = 24.0; // 20-24px as specified
  static const double paddingSmall = 12.0;
  static const double paddingMedium = 20.0;
  static const double paddingLarge = 32.0;

  // Static getters for convenience (theme-aware)
  static Color get textPrimary => textPrimaryLight;
  static Color get textSecondary => textSecondaryLight;
  static Color get borderColor => borderLight;
  static Color get accentColor => secondaryColor;

  // Static getters for icon colors (theme-aware)
  static Color get iconPrimary => textPrimaryLight;
  static Color get iconSecondary => textSecondaryLight;
  static Color get iconPrimaryDark => textPrimaryDark;
  static Color get iconSecondaryDark => textSecondaryDark;

  // 🎨 Theme-aware color getters for attendance view
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : borderLight;
  }

  static Color getShadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? shadowDark
        : shadowLight;
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? inputFillColorDark
        : inputFillColor;
  }

  static Color getNeutralLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? neutralLightColorDark
        : neutralLightColor;
  }

  static Color getOnPrimaryColor(BuildContext context) {
    return onPrimaryColor; // Always white
  }

  static Color getOnPrimarySecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8A8A8A) // Darker gray for dark theme
        : onPrimarySecondaryColor;
  }

  static Color getPrimaryLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0x1AFFFFFF) // 10% white opacity for dark theme
        : primaryLightColor;
  }

  static Color getOnErrorColor(BuildContext context) {
    return onErrorColor; // Always white
  }

  static Color getIconSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[500]!
        : textSecondaryLight;
  }

  // Additional UI color getters
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : borderLight;
  }

  static Color getContainerBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFF6F7FB);
  }

  static Color getOverlayColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.1);
  }

  static Color getSecondaryBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : Colors.white;
  }

  // 🎨 Typography Styles - Dynamic Poppins Font with Responsive Sizing
  // h1: Dynamic sizing based on screen height (largest)
  static TextStyle getH1(Size screenSize) => GoogleFonts.raleway(
        fontSize: screenSize.height * 0.03, // ~32px on 800px screen
        fontWeight: FontWeight.bold, // 700
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      );

  // h2: Dynamic sizing (semi-bold headers)
  static TextStyle getH2(Size screenSize) => GoogleFonts.raleway(
        fontSize: screenSize.height * 0.025, // ~24px on 800px screen
        fontWeight: FontWeight.w600, // semi-bold
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      );

  // body: Dynamic sizing (medium text) - Reference: 0.017-0.02
  static TextStyle getBodyLarge(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.019, // ~18px on 800px screen
        fontWeight: FontWeight.w400, // regular
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle getBodyMedium(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.018, // ~16px on 800px screen
        fontWeight: FontWeight.w400, // regular
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // captions: Dynamic sizing (smallest text)
  static TextStyle getCaption(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.018, // ~14px on 800px screen
        fontWeight: FontWeight.w300, // light
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle getCaptionSmall(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.016, // ~13px on 800px screen
        fontWeight: FontWeight.w300, // light
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // Additional typography variants with dynamic sizing
  static TextStyle getSubtitle1(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.02, // ~16px on 800px screen
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.4,
      );

  static TextStyle getSubtitle2(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.017, // ~14px on 800px screen
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle getButton(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.019, // ~14px on 800px screen
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.4,
      );

  // AppBar title with dynamic sizing
  static TextStyle getAppBarTitle(Size screenSize) => GoogleFonts.poppins(
        fontSize: screenSize.height * 0.022, // ~18px on 800px screen
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.4,
      );

  // Dark theme variants
  static TextStyle getH1Dark(Size screenSize) =>
      getH1(screenSize).copyWith(color: textPrimaryDark);
  static TextStyle getH2Dark(Size screenSize) =>
      getH2(screenSize).copyWith(color: textPrimaryDark);
  static TextStyle getBodyLargeDark(Size screenSize) =>
      getBodyLarge(screenSize).copyWith(color: textPrimaryDark);
  static TextStyle getBodyMediumDark(Size screenSize) =>
      getBodyMedium(screenSize).copyWith(color: textPrimaryDark);
  static TextStyle getCaptionDark(Size screenSize) =>
      getCaption(screenSize).copyWith(color: textSecondaryDark);
  static TextStyle getCaptionSmallDark(Size screenSize) =>
      getCaptionSmall(screenSize).copyWith(color: textSecondaryDark);

  // Legacy static getters (deprecated - use dynamic versions)
  @deprecated
  static TextStyle get h1 => GoogleFonts.podkova(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      );

  @deprecated
  static TextStyle get h2 => GoogleFonts.podkova(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      );

  @deprecated
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  @deprecated
  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  @deprecated
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  @deprecated
  static TextStyle get captionSmall => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  @deprecated
  static TextStyle get subtitle1 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.4,
      );

  @deprecated
  static TextStyle get subtitle2 => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      );

  @deprecated
  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.4,
      );

  // Dynamic border radius based on screen size
  static double getSmallRadius(Size screenSize) =>
      screenSize.width * 0.03; // ~12px on 400px width
  static double getMediumRadius(Size screenSize) =>
      screenSize.width * 0.05; // ~20px on 400px width
  static double getLargeRadius(Size screenSize) =>
      screenSize.width * 0.06; // ~24px on 400px width

  // Dynamic padding based on screen size
  static double getSmallPadding(Size screenSize) =>
      screenSize.width * 0.03; // ~12px on 400px width
  static double getMediumPadding(Size screenSize) =>
      screenSize.width * 0.05; // ~20px on 400px width
  static double getLargePadding(Size screenSize) =>
      screenSize.width * 0.08; // ~32px on 400px width

  // Tema claro - Updated with Dynamic Typography
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: surfaceLight,
      background: backgroundLight,
    ).copyWith(
      secondary: secondaryColor,
      error: errorColor,
    ),

    // Modern Typography with Poppins - Dynamic Sizing
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      // Using medium screen size as base (800x600)
      displayLarge: GoogleFonts.poppins(
        fontSize: 32, // Will be overridden by dynamic methods
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.3,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
    ),

    // AppBar with dynamic styling
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18, // Base size - will be overridden
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      iconTheme: const IconThemeData(
        color: textPrimaryLight,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: textPrimaryLight,
        size: 24,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    // Modern Cards with dynamic border radius
    cardTheme: CardTheme(
      elevation: 0,
      color: cardLight,
      surfaceTintColor: Colors.transparent,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            borderRadiusLarge), // Will use dynamic version
        side: BorderSide(
          color: borderLight,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Modern Buttons with dynamic border radius
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadiusMedium), // Will use dynamic version
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 16), // Will use dynamic version
        textStyle: GoogleFonts.poppins(
          fontSize: 14, // Base size - will be overridden
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadiusMedium), // Will use dynamic version
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 16), // Will use dynamic version
        textStyle: GoogleFonts.poppins(
          fontSize: 14, // Base size - will be overridden
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadiusMedium), // Will use dynamic version
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 16), // Will use dynamic version
        textStyle: GoogleFonts.poppins(
          fontSize: 14, // Base size - will be overridden
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall), // 12px
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.4,
        ),
      ),
    ),

    // Modern Input Fields with dynamic border radius
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadiusMedium), // Will use dynamic version
        borderSide: BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadiusMedium), // Will use dynamic version
        borderSide: BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadiusMedium), // Will use dynamic version
        borderSide: BorderSide(color: accentPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadiusMedium), // Will use dynamic version
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadiusMedium), // Will use dynamic version
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 16), // Will use dynamic version
      labelStyle: GoogleFonts.poppins(
        fontSize: 14, // Base size - will be overridden
        fontWeight: FontWeight.w500,
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14, // Base size - will be overridden
        fontWeight: FontWeight.w400,
        color: textSecondaryLight,
        letterSpacing: 0.1,
        height: 1.4,
      ),
    ),

    // Modern Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: surfaceLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryLight,
      selectedIconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      unselectedIconTheme: const IconThemeData(
        color: textSecondaryLight,
        size: 24,
      ),
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      showUnselectedLabels: true,
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // List Tiles
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      iconColor: textPrimaryLight,
      textColor: textPrimaryLight,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
      subtitleTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryLight,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      deleteIconColor: textSecondaryLight,
      disabledColor: Colors.grey.shade300,
      selectedColor: primaryColor.withOpacity(0.2),
      secondarySelectedColor: secondaryColor.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      brightness: Brightness.light,
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[
      const AppThemeExtension(
        attendancePresent: successColor,
        attendanceAbsent: errorColor,
        attendanceLate: warningColor,
        successContainer: Color(0xFFE8F5E8),
        warningContainer: Color(0xFFFEF7E0),
        errorContainer: Color(0xFFFEE2E2),
        infoContainer: Color(0xFFE0F2FE),
      ),
    ],
  );

  // Tema oscuro - Updated with Dynamic Typography
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: surfaceDark,
      background: backgroundDark,
    ).copyWith(
      secondary: secondaryColor,
      error: errorColor,
    ),

    // Modern Typography for Dark Theme with Poppins - Dynamic Sizing
    textTheme:
        GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textPrimaryDark,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryDark,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: textSecondaryDark,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      // ...existing code for other text styles...
    ),

    // AppBar for Dark Theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      iconTheme: const IconThemeData(
        color: textPrimaryDark,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: textPrimaryDark,
        size: 24,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Cards for Dark Theme
    cardTheme: CardTheme(
      elevation: 0,
      color: cardDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Buttons for Dark Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade700,
        disabledForegroundColor: Colors.grey.shade500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade700,
        disabledForegroundColor: Colors.grey.shade500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.4,
        ),
      ),
    ),

    // Input Fields for Dark Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondaryDark,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
        letterSpacing: 0.1,
        height: 1.4,
      ),
    ),

    // Bottom Navigation for Dark Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: surfaceDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryDark,
      selectedIconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      unselectedIconTheme: const IconThemeData(
        color: textSecondaryDark,
        size: 24,
      ),
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      showUnselectedLabels: true,
    ),

    // Floating Action Button for Dark Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // List Tiles for Dark Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      iconColor: textPrimaryDark,
      textColor: textPrimaryDark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      subtitleTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
      ),
    ),

    // Chip Theme for Dark Theme
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade800,
      deleteIconColor: textSecondaryDark,
      disabledColor: Colors.grey.shade700,
      selectedColor: primaryColor.withOpacity(0.3),
      secondarySelectedColor: secondaryColor.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      brightness: Brightness.dark,
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[
      const AppThemeExtension(
        attendancePresent: successColor,
        attendanceAbsent: errorColor,
        attendanceLate: warningColor,
        successContainer: Color(0xFF064E3B),
        warningContainer: Color(0xFF92400E),
        errorContainer: Color(0xFF991B1B),
        infoContainer: Color(0xFF164E63),
      ),
    ],
  );

  // Colores personalizados para estados de asistencia
  static Color getAttendanceColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'presente':
        return successColor;
      case 'tarde':
        return warningColor;
      case 'ausente':
        return errorColor;
      case 'permisoespecial':
        return infoColor;
      default:
        return Colors.grey;
    }
  }

  // Iconos para tipos de notificación
  static IconData getNotificationIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return Icons.login;
      case 'salida':
        return Icons.logout;
      case 'retraso':
        return Icons.schedule;
      case 'ausencia':
        return Icons.person_off;
      case 'permisoespecial':
        return Icons.verified_user;
      case 'alerta':
        return Icons.warning;
      case 'comunicado':
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }

  // Helper para convertir un string hex a Color
  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// Custom theme extension for additional colors
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.attendancePresent,
    required this.attendanceAbsent,
    required this.attendanceLate,
    required this.successContainer,
    required this.warningContainer,
    required this.errorContainer,
    required this.infoContainer,
  });

  final Color attendancePresent;
  final Color attendanceAbsent;
  final Color attendanceLate;
  final Color successContainer;
  final Color warningContainer;
  final Color errorContainer;
  final Color infoContainer;

  @override
  AppThemeExtension copyWith({
    Color? attendancePresent,
    Color? attendanceAbsent,
    Color? attendanceLate,
    Color? successContainer,
    Color? warningContainer,
    Color? errorContainer,
    Color? infoContainer,
  }) {
    return AppThemeExtension(
      attendancePresent: attendancePresent ?? this.attendancePresent,
      attendanceAbsent: attendanceAbsent ?? this.attendanceAbsent,
      attendanceLate: attendanceLate ?? this.attendanceLate,
      successContainer: successContainer ?? this.successContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      errorContainer: errorContainer ?? this.errorContainer,
      infoContainer: infoContainer ?? this.infoContainer,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      attendancePresent:
          Color.lerp(attendancePresent, other.attendancePresent, t)!,
      attendanceAbsent:
          Color.lerp(attendanceAbsent, other.attendanceAbsent, t)!,
      attendanceLate: Color.lerp(attendanceLate, other.attendanceLate, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}
