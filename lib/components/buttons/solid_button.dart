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

    Widget labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.getBodyMedium(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: onColor,
        letterSpacing: 0.1,
      ),
    );

    if (isLoading) {
      // Loader simple inline; sustitúyelo por tu widget de loading si quieres
      labelWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(onColor),
            ),
          ),
          const SizedBox(width: 8),
          labelWidget,
        ],
      );
    }

    final Widget buttonChild = icon != null
        ? ElevatedButton.icon(
            onPressed: _wrapHaptics(onPressed),
            icon: Icon(icon, size: screenSize.width * 0.045, color: onColor),
            label: labelWidget,
            style: style,
          )
        : ElevatedButton(
            onPressed: _wrapHaptics(onPressed),
            style: style,
            child: labelWidget,
          );

    final Widget semantic = Semantics(
      button: true,
      label: semanticsLabel ?? label,
      enabled: onPressed != null,
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
    // heurística simple: si el fondo es oscuro, usa onPrimary de theme si contrasta,
    // si es claro, usa colorScheme.onSurface o Colors.black.
    final brightness = ThemeData.estimateBrightnessForColor(bg);
    if (brightness == Brightness.dark) {
      return theme.colorScheme.onPrimary;
    } else {
      // texto oscuro para fondo claro
      return theme.colorScheme.onSurface; // o Colors.black87
    }
  }
}
