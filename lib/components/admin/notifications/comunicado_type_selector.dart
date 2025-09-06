import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';

class ComunicadoTypeSelector extends StatelessWidget {
  final TipoComunicacion selectedType;
  final Function(TipoComunicacion) onTypeSelected;
  final Size screenSize;

  // NUEVO:
  final bool enabled;
  final bool enableHaptics;
  final String? semanticsLabel;

  const ComunicadoTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.screenSize,
    this.enabled = true, // <- NUEVO
    this.enableHaptics = false, // <- NUEVO
    this.semanticsLabel, // <- NUEVO
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final List<Map<String, Object>> comunicadoTypes = [
      {
        'value': TipoComunicacion.informativo,
        'label': l10n.informative,
        'icon': Icons.info_rounded,
      },
      {
        'value': TipoComunicacion.paseo,
        'label': l10n.fieldTrip,
        'icon': Icons.directions_bus_rounded,
      },
      {
        'value': TipoComunicacion.emergencia,
        'label': l10n.emergency,
        'icon': Icons.emergency_rounded,
      },
      {
        'value': TipoComunicacion.evento,
        'label': l10n.event,
        'icon': Icons.event_rounded,
      },
      {
        'value': TipoComunicacion.recordatorioPago,
        'label': l10n.paymentReminder,
        'icon': Icons.payment_rounded,
      },
      {
        'value': TipoComunicacion.citatorio,
        'label': l10n.citation,
        'icon': Icons.gavel_rounded,
      },
      {
        'value': TipoComunicacion.celebracion,
        'label': l10n.celebration,
        'icon': Icons.celebration_rounded,
      },
      {
        'value': TipoComunicacion.suspencionClases,
        'label': l10n.classSuspension,
        'icon': Icons.cancel_rounded,
      },
      {
        'value': TipoComunicacion.cambioHorario,
        'label': l10n.scheduleChange,
        'icon': Icons.schedule_rounded,
      },
    ];

    final double overallOpacity = enabled ? 1.0 : 0.6;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: overallOpacity,
        child: Wrap(
          spacing: AppTheme.getSmallPadding(screenSize),
          runSpacing: AppTheme.getSmallPadding(screenSize),
          children: comunicadoTypes.map((type) {
            final value = type['value'] as TipoComunicacion;
            final isSelected = selectedType == value;

            void handleTap() {
              if (enableHaptics) {
                try {
                  HapticFeedback.selectionClick();
                } catch (_) {}
              }
              onTypeSelected(value);
            }

            return Semantics(
              button: true,
              selected: isSelected,
              enabled: enabled,
              label: semanticsLabel ??
                  '${type['label'] as String}${isSelected ? ' (seleccionado)' : ''}',
              child: GestureDetector(
                onTap: handleTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getMediumPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.warningColor.withOpacity(0.1)
                        : AppTheme.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.warningColor
                          : AppTheme.getBorderColor(context),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        color: isSelected
                            ? AppTheme.warningColor
                            : AppTheme.getTextSecondaryColor(context),
                        size: screenSize.height * 0.022,
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Text(
                        type['label'] as String,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: isSelected
                              ? AppTheme.warningColor
                              : AppTheme.getTextPrimaryColor(context),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
