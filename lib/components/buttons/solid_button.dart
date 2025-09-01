import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SolidButton extends StatelessWidget {
  final VoidCallback? onPressed; // permite disabled
  final String label;
  final IconData? icon;
  final Color? backgroundColor; // fondo opcional
  final Color? foregroundColor; // color de texto/ícono opcional
  final Size screenSize;
  final double? width;
  final bool enableHaptics;
  final String? semanticsLabel;
  final bool expand; // llena el ancho por defecto
  final bool isLoading; // estado de carga opcional

  // NUEVOS: control fino del loader
  final bool showLoaderInIconSlot; // muestra loader en el espacio del icono
  final double? loadingIndicatorSize; // tamaño del loader

  const SolidButton({
    super.key,
    required this.label,
    required this.screenSize,
    this.onPressed,
    this.width,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.enableHaptics = false,
    this.semanticsLabel,
    this.expand = true,
    this.isLoading = false,
    this.showLoaderInIconSlot = true,
    this.loadingIndicatorSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fondo efectivo
    final Color bg = backgroundColor ?? AppTheme.accentPurple;

    // Texto/ícono efectivo: si no te pasan uno, intenta respetar el theme
    final Color onColor =
        foregroundColor ?? _bestOnColor(bg, theme); // calcula contraste simple

    final BorderRadius radius =
        BorderRadius.circular(AppTheme.getSmallRadius(screenSize));

    final ButtonStyle style = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return bg.withOpacity(0.5);
        }
        return bg;
      }),
      foregroundColor: MaterialStateProperty.all(onColor),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return onColor.withOpacity(0.12);
        }
        if (states.contains(MaterialState.hovered) ||
            states.contains(MaterialState.focused)) {
          return onColor.withOpacity(0.08);
        }
        return null;
      }),
      minimumSize: MaterialStateProperty.all(Size(48, 48)),
      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(screenSize),
        horizontal: AppTheme.getMediumPadding(screenSize),
      )),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      elevation: MaterialStateProperty.all(0),
    );

    // Label sin loader inline (el loader va en el slot del icono)
    final Widget labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.getBodyMedium(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: onColor,
        letterSpacing: 0.1,
      ),
    );

    // onPressed se deshabilita automáticamente si está cargando
    final VoidCallback? effectiveOnPressed =
        isLoading ? null : _wrapHaptics(onPressed);

    // Icono efectivo: loader en el slot si isLoading
    final double spinnerSize = loadingIndicatorSize ?? 16;
    Widget? effectiveIcon;
    if (isLoading && showLoaderInIconSlot) {
      effectiveIcon = SizedBox(
        width: spinnerSize,
        height: spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(onColor),
        ),
      );
    } else if (icon != null) {
      effectiveIcon =
          Icon(icon, size: screenSize.width * 0.045, color: onColor);
    } else {
      effectiveIcon = null;
    }

    final Widget buttonChild = effectiveIcon != null
        ? ElevatedButton.icon(
            onPressed: effectiveOnPressed,
            icon: effectiveIcon,
            label: labelWidget,
            style: style,
          )
        : ElevatedButton(
            onPressed: effectiveOnPressed,
            style: style,
            child: labelWidget,
          );

    final Widget semantic = Semantics(
      button: true,
      label: semanticsLabel ?? label,
      enabled: effectiveOnPressed != null,
      child: buttonChild,
    );

    final double? resolvedWidth = width ?? (expand ? double.infinity : null);

    return SizedBox(
      width: resolvedWidth,
      child: ClipRRect(borderRadius: radius, child: semantic),
    );
  }

  VoidCallback? _wrapHaptics(VoidCallback? cb) {
    if (cb == null) return null;
    if (!enableHaptics) return cb;
    return () {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
      cb();
    };
  }

  Color _bestOnColor(Color bg, ThemeData theme) {
    final brightness = ThemeData.estimateBrightnessForColor(bg);
    if (brightness == Brightness.dark) {
      return theme.colorScheme.onPrimary;
    } else {
      return theme.colorScheme.onSurface;
    }
  }
}
