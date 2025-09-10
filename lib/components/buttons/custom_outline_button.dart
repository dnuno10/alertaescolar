import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOutlineButton extends StatelessWidget {
  /// Callback opcional: si es null, el botón queda deshabilitado.
  final VoidCallback? onPressed;

  /// Texto del botón.
  final String label;

  /// Ícono opcional a la izquierda.
  final IconData? icon;

  /// Color base para borde y texto.
  final Color color;

  /// Tamaño de pantalla para escalar paddings/tipografías.
  final Size screenSize;

  /// (Deprecated-ish) Si true, llena el ancho disponible.
  /// Se mantiene por compatibilidad con usos previos.
  final bool isExpanded;

  /// Controla si vibra al presionar (cuando está habilitado).
  final bool enableHaptics;

  /// Etiqueta de accesibilidad (si no se pasa, usa [label]).
  final String? semanticsLabel;

  /// Ancho opcional. Si no se especifica y [isExpanded] es true, usa infinito.
  final double? width;

  const CustomOutlineButton({
    super.key,
    required this.label,
    required this.color,
    required this.screenSize,
    this.onPressed,
    this.icon,
    this.isExpanded = false,
    this.enableHaptics = false,
    this.semanticsLabel,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        BorderRadius.circular(AppTheme.getSmallRadius(screenSize));

    final Color effectiveTextColor =
        // ignore: deprecated_member_use
        onPressed == null ? color.withOpacity(0.6) : color;

    final ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(48, 48)),
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(screenSize),
        horizontal: AppTheme.getMediumPadding(screenSize),
      )),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      side: WidgetStateProperty.resolveWith((states) {
        final disabled = states.contains(WidgetState.disabled);
        return BorderSide(
          // ignore: deprecated_member_use
          color: disabled ? color.withOpacity(0.4) : color,
          width: 1,
        );
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        final disabled = states.contains(WidgetState.disabled);
        // ignore: deprecated_member_use
        return disabled ? color.withOpacity(0.6) : color;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          // ignore: deprecated_member_use
          return color.withOpacity(0.10);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          // ignore: deprecated_member_use
          return color.withOpacity(0.06);
        }
        return null;
      }),
      elevation: WidgetStateProperty.all(0),
    );

    final TextStyle textStyle = AppTheme.getBodyMedium(screenSize).copyWith(
      fontWeight: FontWeight.w600,
      color: effectiveTextColor,
      letterSpacing: 0.1,
    );

    Widget child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: screenSize.width * 0.045, color: effectiveTextColor),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle),
            ],
          )
        : Text(label,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle);

    final Widget button = OutlinedButton(
      onPressed: _wrapHaptics(onPressed),
      style: style,
      child: child,
    );

    final Widget semantic = Semantics(
      button: true,
      label: semanticsLabel ?? label,
      enabled: onPressed != null,
      child: button,
    );

    final double? resolvedWidth =
        width ?? (isExpanded ? double.infinity : null);

    final Widget sized = SizedBox(
      width: resolvedWidth,
      child: ClipRRect(borderRadius: radius, child: semantic),
    );

    // Mantener compatibilidad: si alguien depende de Expanded externamente,
    // no lo forzamos aquí; usamos SizedBox con width infinito cuando isExpanded = true.
    return sized;
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
}
