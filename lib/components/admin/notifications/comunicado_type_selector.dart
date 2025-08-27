import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/comunicado.dart';

class ComunicadoTypeSelector extends StatelessWidget {
  final TipoComunicado selectedType;
  final Function(TipoComunicado) onTypeSelected;
  final Size screenSize;

  const ComunicadoTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final comunicadoTypes = [
      {
        'value': TipoComunicado.informativo,
        'label': l10n.informative,
        'icon': Icons.info_rounded
      },
      {
        'value': TipoComunicado.paseo,
        'label': l10n.fieldTrip,
        'icon': Icons.directions_bus_rounded
      },
      {
        'value': TipoComunicado.emergencia,
        'label': l10n.emergency,
        'icon': Icons.emergency_rounded
      },
      {
        'value': TipoComunicado.evento,
        'label': l10n.event,
        'icon': Icons.event_rounded
      },
      {
        'value': TipoComunicado.recordatorioPago,
        'label': l10n.paymentReminder,
        'icon': Icons.payment_rounded
      },
      {
        'value': TipoComunicado.citatorio,
        'label': l10n.citation,
        'icon': Icons.gavel_rounded
      },
      {
        'value': TipoComunicado.celebracion,
        'label': l10n.celebration,
        'icon': Icons.celebration_rounded
      },
      {
        'value': TipoComunicado.suspencionClases,
        'label': l10n.classSuspension,
        'icon': Icons.cancel_rounded
      },
      {
        'value': TipoComunicado.cambioHorario,
        'label': l10n.scheduleChange,
        'icon': Icons.schedule_rounded
      },
    ];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize),
      runSpacing: AppTheme.getSmallPadding(screenSize),
      children: comunicadoTypes.map((type) {
        final isSelected = selectedType == type['value'];
        return GestureDetector(
          onTap: () => onTypeSelected(type['value'] as TipoComunicado),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getMediumPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.warningColor.withOpacity(0.1)
                  : AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
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
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                Text(
                  type['label'] as String,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: isSelected
                        ? AppTheme.warningColor
                        : AppTheme.getTextPrimaryColor(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
