import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // =========================
  // BRAND & SEMÁNTICA (COLORES)
  // =========================
  // Paleta principal: morado institucional, blanco óptico y bordes ligeros.
  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color primaryColorDark = Color(0xFFA78BFA);
  static const Color secondaryColor = Color(0xFF58CC02); // Verde institucional

  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentYellow = Color(0xFFEAB308);
  static const Color accentBlue = Color(0xFF7C3AED);
  static const Color accentOrange = Color(0xFF4361EE);
  static const Color accentGold = accentYellow;

  // Estados
  static const Color successColor = Color(0xFF58CC02);
  static const Color warningColor = Color(0xFFEAB308);
  static const Color errorColor = Color(0xFFFF5757);
  static const Color infoColor = Color(0xFF4C9DFF);

  // Fondos
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

// MÁS OSCURO (midnight navy)
  static const Color backgroundDark = Color.fromARGB(255, 1, 7, 23); // navy-960
  static const Color surfaceDark = Color.fromARGB(255, 6, 16, 34); // navy-940
  static const Color cardDark = Color.fromARGB(255, 12, 19, 36); // navy-920

  // Texto
  static const Color textPrimaryLight = Color(0xFF121316);
  static const Color textSecondaryLight = Color(0xFF81848B);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB7BBC2);

  // Bordes
  static const Color borderLight = Color(0xFFE8EAF0);
  // Bordes y fills acordes al nuevo tono
  static const Color borderDark =
      Color.fromARGB(255, 13, 21, 38); // borde azulado
  static const Color inputFillColorDark =
      Color.fromARGB(255, 11, 24, 54); // fill más profundo

  // Contenedores de íconos
  static const Color iconContainerPurple = accentPurple;
  static const Color iconContainerBlue = accentBlue;

  // Sombras (referencias existentes – se mantienen pero NO se usan)
  static const Color shadowLight = Color(0x00000000);
  static const Color shadowDark = Color(0x00000000);

  // Propiedades usadas por vistas de asistencia (mantengo nombres)
  static const Color backgroundColor = backgroundLight;
  static const Color surfaceColor = surfaceLight;
  static const Color onPrimaryColor = Color(0xFFFFFFFF);
  static const Color onPrimarySecondaryColor = Color(0xFFB3B3B3);
  static const Color primaryLightColor = Color(0x147C3AED);

  static const Color iconColor = textPrimaryLight;
  static const Color inputFillColor = Color(0xFFF2F3F6);
  static const Color neutralLightColor = Color(0xFFF4F5F7);
  static const Color neutralLightColorDark = Color(0xFF2A2D33);
  static const Color onErrorColor = Color(0xFFFFFFFF);
  static const Color shadowColor = shadowLight;

  // ==================================================
  // (DEPRECATED) CONSTANTES DE ESPACIADO/RADIO – SE MANTIENEN
  // ==================================================
  // ignore: provide_deprecation_message
  @deprecated
  static const double borderRadiusSmall = 12.0;
  // ignore: provide_deprecation_message
  @deprecated
  static const double borderRadiusMedium = 20.0;
  // ignore: provide_deprecation_message
  @deprecated
  static const double borderRadiusLarge = 24.0;
  // ignore: provide_deprecation_message
  @deprecated
  static const double paddingSmall = 12.0;
  // ignore: provide_deprecation_message
  @deprecated
  static const double paddingMedium = 20.0;
  // ignore: provide_deprecation_message
  @deprecated
  static const double paddingLarge = 32.0;

  // =========================================
  // HELPERS DE ESCALA (100% MediaQuery-based)
  // =========================================
  // Base: iPhone 12/13 = 390x844 (ancho guía 390)
  static double _scaleW(Size s) => (s.width / 390.0).clamp(0.85, 1.35);
  static double _scaleH(Size s) => (s.height / 844.0).clamp(0.85, 1.35);

  /// Escala general (promedio ponderado a ancho)
  static double scale(Size s, double value) {
    final k = _scaleW(s) * 0.75 + _scaleH(s) * 0.25;
    return value * k;
  }

  /// Tamaños de texto estables para evitar saltos visuales por viewport.
  static double ts(Size s, double px) => px;

  /// Radios responsivos
  static double r(Size s, double px) => scale(s, px);

  /// Padding/Gutters responsivos
  static double p(Size s, double px) => scale(s, px);

  /// Unidades de grilla (para alturas ancladas)
  static double gu(Size s) => scale(s, 8); // grid unit

  // =========================
  // GETTERS TEMA-AWARE
  // =========================
  static Color get textPrimary => textPrimaryLight;
  static Color get textSecondary => textSecondaryLight;
  static Color get borderColor => borderLight;
  static Color get accentColor => secondaryColor;

  static Color get iconPrimary => textPrimaryLight;
  static Color get iconSecondary => textSecondaryLight;
  static Color get iconPrimaryDark => textPrimaryDark;
  static Color get iconSecondaryDark => textSecondaryDark;

  static Color getBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? backgroundDark
          : backgroundLight;

  static Color getSurfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surfaceLight;

  static Color getCardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;

  static Color getTextPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimaryLight;

  static Color getTextSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondaryDark
          : textSecondaryLight;

  static Color getBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? borderDark
          : borderLight;

  static Color getShadowColor(BuildContext context) => Colors.transparent;

  static Color getIconColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimaryLight;

  static Color getInputFillColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? inputFillColorDark
          : inputFillColor;

  static Color getNeutralLightColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? neutralLightColorDark
          : neutralLightColor;

  static Color getOnPrimaryColor(BuildContext context) => onPrimaryColor;

  static Color getOnPrimarySecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF8A8A8A)
          : onPrimarySecondaryColor;

  static Color getPrimaryLightColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0x14FFFFFF)
          : primaryLightColor;

  static Color getOnErrorColor(BuildContext context) => onErrorColor;

  static Color getIconSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[500]!
          : textSecondaryLight;

  static Color getDividerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? borderDark
          : borderLight;

  static Color getContainerBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF202227)
          : Colors.white;

  static Color getOverlayColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          // ignore: deprecated_member_use
          ? Colors.black.withOpacity(0.45)
          // ignore: deprecated_member_use
          : Colors.black.withOpacity(0.08);

  static Color getSecondaryBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1C20)
          : Colors.white;

  // =========================
  // TIPOGRAFÍA DINÁMICA
  // =========================
  // Headers más expresivos; números con Space Grotesk (balances/montos)
  static TextStyle getH1(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 30),
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        height: 1.2,
        color: textPrimaryLight,
      );

  static TextStyle getH2(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 24),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.25,
        color: textPrimaryLight,
      );

  static TextStyle getBodyLarge(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 17),
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: textPrimaryLight,
      );

  static TextStyle getBodyMedium(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 15.5),
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: textPrimaryLight,
      );

  static TextStyle getCaption(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 13.5),
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: textSecondaryLight,
      );

  static TextStyle getCaptionSmall(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 12.5),
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: textSecondaryLight,
      );

  static TextStyle getSubtitle1(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 16),
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: textPrimaryLight,
      );

  static TextStyle getSubtitle2(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 14),
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: textPrimaryLight,
      );

  static TextStyle getButton(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 15),
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        height: 1.2,
        color: onPrimaryColor,
      );

  static TextStyle getAppBarTitle(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 18),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.25,
        color: textPrimaryLight,
      );

  // Variantes dark
  static TextStyle getH1Dark(Size s) =>
      getH1(s).copyWith(color: textPrimaryDark);
  static TextStyle getH2Dark(Size s) =>
      getH2(s).copyWith(color: textPrimaryDark);
  static TextStyle getBodyLargeDark(Size s) =>
      getBodyLarge(s).copyWith(color: textPrimaryDark);
  static TextStyle getBodyMediumDark(Size s) =>
      getBodyMedium(s).copyWith(color: textPrimaryDark);
  static TextStyle getCaptionDark(Size s) =>
      getCaption(s).copyWith(color: textSecondaryDark);
  static TextStyle getCaptionSmallDark(Size s) =>
      getCaptionSmall(s).copyWith(color: textSecondaryDark);

  // (LEGACY) estáticos – se conservan
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get h1 => GoogleFonts.inter(
      fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get h2 => GoogleFonts.inter(
      fontSize: 24, fontWeight: FontWeight.w600, color: textPrimaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get bodyLarge => GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w400, color: textPrimaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get bodyMedium => GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w400, color: textPrimaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get caption => GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w300, color: textSecondaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get captionSmall => GoogleFonts.inter(
      fontSize: 13, fontWeight: FontWeight.w300, color: textSecondaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get subtitle1 => GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w500, color: textPrimaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get subtitle2 => GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryLight);
  // ignore: provide_deprecation_message
  @deprecated
  static TextStyle get button =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600);

  // =========================
  // RADIOS / PADDINGS DINÁMICOS
  // =========================
  static double getSmallRadius(Size s) => r(s, 12);
  static double getMediumRadius(Size s) => r(s, 20);
  static double getLargeRadius(Size s) => r(s, 26);

  static double getSmallPadding(Size s) => p(s, 12);
  static double getMediumPadding(Size s) => p(s, 20);
  static double getLargePadding(Size s) => p(s, 32);

  // =========================
  // NUMERAL STYLE para montos
  // =========================
  static TextStyle numericXL(Size s) => GoogleFonts.inter(
        fontSize: ts(s, 34),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.1,
        color: getTextPrimaryColorFromSize(s, isDark: false),
      );

  static Color getTextPrimaryColorFromSize(Size s, {required bool isDark}) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  // =========================
  // THEME DATA — LIGHT
  // =========================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.inter().fontFamily,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    shadowColor: Colors.transparent,
    scaffoldBackgroundColor: backgroundLight,
    canvasColor: backgroundLight,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      // ignore: deprecated_member_use
      background: backgroundLight,
      surface: surfaceLight,
    ).copyWith(
      primary: accentBlue,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      error: errorColor,
      outline: borderLight,
      surfaceTint: Colors.transparent,
    ),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.1,
          color: textPrimaryLight),
      displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
          color: textPrimaryLight),
      displaySmall: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w700, color: textPrimaryLight),
      headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimaryLight),
      headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimaryLight),
      headlineSmall: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimaryLight),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16.5, fontWeight: FontWeight.w500, color: textPrimaryLight),
      bodyMedium: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w500, color: textPrimaryLight),
      bodySmall: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: textSecondaryLight),
      titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w700, color: textPrimaryLight),
      titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w700, color: textPrimaryLight),
      titleSmall: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: textSecondaryLight),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w800, color: textPrimaryLight),
      labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: textPrimaryLight),
      labelSmall: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: textSecondaryLight),
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimaryLight),
      iconTheme: const IconThemeData(color: textPrimaryLight, size: 24),
      actionsIconTheme: const IconThemeData(color: textPrimaryLight, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: borderLight.withOpacity(0.65),
      space: 1,
      thickness: 0.6,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        highlightColor: Colors.transparent,
      ),
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w700, color: textSecondaryLight),
      hintStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: textSecondaryLight),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: surfaceLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryLight,
      selectedIconTheme: const IconThemeData(size: 24, color: primaryColor),
      unselectedIconTheme:
          const IconThemeData(size: 24, color: textSecondaryLight),
      selectedLabelStyle:
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
      unselectedLabelStyle:
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
      showUnselectedLabels: true,
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    // ListTile
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      iconColor: textPrimaryLight,
      textColor: textPrimaryLight,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w700, color: textPrimaryLight),
      subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: textSecondaryLight),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF1F2F6),
      deleteIconColor: textSecondaryLight,
      disabledColor: const Color(0xFFE8EAEE),
      // ignore: deprecated_member_use
      selectedColor: primaryColor.withOpacity(0.10),
      // ignore: deprecated_member_use
      secondarySelectedColor: secondaryColor.withOpacity(0.14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: textPrimaryLight),
      secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
      brightness: Brightness.light,
    ),

    // Extensiones
    extensions: <ThemeExtension<dynamic>>[
      const AppThemeExtension(
        attendancePresent: successColor,
        attendanceAbsent: errorColor,
        attendanceLate: warningColor,
        successContainer: Color(0xFFEAF7E8),
        warningContainer: Color(0xFFFFF6E3),
        errorContainer: Color(0xFFFEE7E7),
        infoContainer: Color(0xFFE6F1FF),
      ),
    ],
  );

  // =========================
  // THEME DATA — DARK
  // =========================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.inter().fontFamily,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    shadowColor: Colors.transparent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      // ignore: deprecated_member_use
      background: backgroundDark,
      surface: surfaceDark,
    ).copyWith(
      // mantenemos tus semánticas
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      error: errorColor,
      outline: borderDark,
      surfaceTint: Colors.transparent,
    ),
    // Tipografías: igual que ya tienes
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        /* ...lo tuyo... */),

    // AppBar: azul marino
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: surfaceDark, // 0xFF0F1629
      foregroundColor: textPrimaryDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimaryDark),
      iconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
      actionsIconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: borderDark.withOpacity(0.8),
      space: 1,
      thickness: 0.6,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        highlightColor: Colors.transparent,
      ),
    ),

    // Botones: azul en dark
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),

    // Inputs: foco azul y fill marino
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFillColorDark, // 0xFF121A2F
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w700, color: textSecondaryDark),
      hintStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: textSecondaryDark),
    ),

    // BottomNav: base navy + selección azul
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: surfaceDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryDark,
      selectedIconTheme: const IconThemeData(size: 24, color: primaryColor),
      unselectedIconTheme:
          const IconThemeData(size: 24, color: textSecondaryDark),
      selectedLabelStyle:
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
      unselectedLabelStyle:
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
      showUnselectedLabels: true,
    ),

    // FAB: azul
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    // ListTile: fondos/contornos navy
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      iconColor: textPrimaryDark,
      textColor: textPrimaryDark,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w700, color: textPrimaryDark),
      subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: textSecondaryDark),
    ),

    // Chips: navy + selección azul
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1A233A),
      deleteIconColor: textSecondaryDark,
      disabledColor: const Color(0xFF192236),
      // ignore: deprecated_member_use
      selectedColor: primaryColor.withOpacity(0.22),
      // ignore: deprecated_member_use
      secondarySelectedColor: secondaryColor.withOpacity(0.22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: textPrimaryDark),
      secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
      brightness: Brightness.dark,
    ),

    // Extensión: contenedores ligeramente azulados
    extensions: <ThemeExtension<dynamic>>[
      const AppThemeExtension(
        attendancePresent: successColor,
        attendanceAbsent: errorColor,
        attendanceLate: warningColor,
        successContainer: Color(0xFF0E2A18), // verde en navy
        warningContainer: Color(0xFF2E2612),
        errorContainer: Color(0xFF2B1416),
        infoContainer: Color(0xFF0F2241), // azul info
      ),
    ],
  );

  // =========================
  // UTILIDADES DE ESTADO/ICONOS
  // =========================
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

  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// =========================
// EXTENSIÓN PERSONALIZADA
// =========================
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
    if (other is! AppThemeExtension) return this;
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
