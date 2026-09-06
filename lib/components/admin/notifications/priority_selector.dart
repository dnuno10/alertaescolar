import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';

class PrioritySelector extends StatelessWidget {
  final PrioridadComunicado selectedPriority;
  final Function(PrioridadComunicado) onPriorityChanged;
  final Size screenSize;

  // NUEVO:
  final bool enabled;
  final bool enableHaptics;
  final String? semanticsLabel;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.screenSize,
    this.enabled = true,
    this.enableHaptics = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final List<Map<String, Object>> priorities = [
      {
        'value': PrioridadComunicado.baja,
        'label': l10n.low,
        'color': AppTheme.accentBlue,
      },
      {
        'value': PrioridadComunicado.media,
        'label': l10n.medium,
        'color': AppTheme.accentOrange,
      },
      {
        'value': PrioridadComunicado.alta,
        'label': l10n.high,
        'color': AppTheme.warningColor,
      },
      {
        'value': PrioridadComunicado.critica,
        'label': l10n.critical,
        'color': AppTheme.errorColor,
      },
    ];

    // Cuando está deshabilitado, bloquea interacción y baja opacidad
    final double overallOpacity = enabled ? 1.0 : 0.6;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: overallOpacity,
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
            mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
          ),
          itemCount: priorities.length,
          itemBuilder: (context, index) {
            final item = priorities[index];
            final value = item['value'] as PrioridadComunicado;
            final color = item['color'] as Color;
            final isSelected = selectedPriority == value;

            final Color borderColor =
                isSelected ? color : AppTheme.getBorderColor(context);
            final Color fillColor = isSelected
                // ignore: deprecated_member_use
                ? color.withOpacity(0.0)
                : AppTheme.getBackgroundColor(context);

            void handleTap() {
              if (enableHaptics) {
                try {
                  HapticFeedback.selectionClick();
                } catch (_) {}
              }
              onPriorityChanged(value);
            }

            return Semantics(
              button: true,
              selected: isSelected,
              enabled: enabled,
              label: semanticsLabel ??
                  '${item['label'] as String} ${isSelected ? l10n.selected : ''}'
                      .trim(),
              child: GestureDetector(
                onTap: handleTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.7),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: enabled
                          ? borderColor
                          // ignore: deprecated_member_use
                          : AppTheme.getBorderColor(context).withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: screenSize.width * 0.08,
                        height: screenSize.width * 0.08,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                          maxWidth: 40,
                          maxHeight: 40,
                        ),
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: color,
                          size: screenSize.height * 0.02,
                        ),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.8),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: isSelected
                                ? color
                                : AppTheme.getTextPrimaryColor(context),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: screenSize.height * 0.018,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
