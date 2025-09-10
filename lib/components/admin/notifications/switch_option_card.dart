import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';

class SwitchOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;
  final Size screenSize;

  /// NUEVO: deshabilitar interacción (ej. mientras navegas/cargando)
  final bool enabled;

  /// NUEVO: bloquear el switch aunque esté habilitado (regla de negocio),
  /// p.ej. en "emergencia" el push debe estar siempre activo
  final bool locked;

  /// NUEVO: mensaje corto cuando está bloqueado
  final String? lockReason;

  const SwitchOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.color,
    required this.screenSize,
    this.enabled = true,
    this.locked = false,
    this.lockReason,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && !locked;

    return Semantics(
      container: true,
      label: title,
      enabled: enabled,
      readOnly: locked,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: value
                // ignore: deprecated_member_use
                ? color.withOpacity(0.05)
                : AppTheme.getBackgroundColor(context),
            borderRadius: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.getMediumRadius(screenSize),
              ),
            ).borderRadius,
            border: Border.all(
              color: value
                  // ignore: deprecated_member_use
                  ? color.withOpacity(0.3)
                  : AppTheme.getBorderColor(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                decoration: BoxDecoration(
                  color: value
                      // ignore: deprecated_member_use
                      ? color.withOpacity(0.1)
                      // ignore: deprecated_member_use
                      : AppTheme.getBorderColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(screenSize),
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      value ? color : AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.022,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (locked) ...[
                          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                          Icon(
                            Icons.lock_rounded,
                            size: screenSize.height * 0.018,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.3),
                    Text(
                      locked && (lockReason?.isNotEmpty ?? false)
                          ? lockReason!
                          : description,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: !isInteractive,
                child: Switch(
                  value: value,
                  onChanged: (v) {
                    if (!isInteractive) return;
                    HapticFeedback.selectionClick();
                    onChanged(v);
                  },
                  activeColor: color,
                  // ignore: deprecated_member_use
                  activeTrackColor: color.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
