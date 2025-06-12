import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/comunicado.dart';

class PrioritySelector extends StatelessWidget {
  final PrioridadComunicado selectedPriority;
  final Function(PrioridadComunicado) onPriorityChanged;
  final Size screenSize;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final priorities = [
      {
        'value': PrioridadComunicado.baja,
        'label': l10n.low,
        'color': AppTheme.accentBlue
      },
      {
        'value': PrioridadComunicado.media,
        'label': l10n.medium,
        'color': AppTheme.accentOrange
      },
      {
        'value': PrioridadComunicado.alta,
        'label': l10n.high,
        'color': AppTheme.warningColor
      },
      {
        'value': PrioridadComunicado.critica,
        'label': l10n.critical,
        'color': AppTheme.errorColor
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
        mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
      ),
      itemCount: priorities.length,
      itemBuilder: (context, index) {
        final priority = priorities[index];
        final isSelected = selectedPriority == priority['value'];

        return GestureDetector(
          onTap: () =>
              onPriorityChanged(priority['value'] as PrioridadComunicado),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: isSelected
                  ? (priority['color'] as Color).withValues(alpha: 0.1)
                  : AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: isSelected
                    ? priority['color'] as Color
                    : AppTheme.getBorderColor(context),
                width: isSelected ? 2 : 1,
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
                  decoration: BoxDecoration(
                    color: (priority['color'] as Color)
                        .withValues(alpha: isSelected ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.priority_high_rounded,
                    color: priority['color'] as Color,
                    size: screenSize.height * 0.02,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.8),
                Expanded(
                  child: Text(
                    priority['label'] as String,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: isSelected
                          ? priority['color'] as Color
                          : AppTheme.getTextPrimaryColor(context),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: priority['color'] as Color,
                    size: screenSize.height * 0.018,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
