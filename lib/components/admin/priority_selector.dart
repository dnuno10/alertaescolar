import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class PrioritySelector extends StatelessWidget {
  final Size screenSize;
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.screenSize,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final priorities = [
      {'value': 'low', 'label': l10n.low, 'color': AppTheme.successColor},
      {'value': 'medium', 'label': l10n.medium, 'color': AppTheme.accentBlue},
      {'value': 'high', 'label': l10n.high, 'color': AppTheme.warningColor},
      {'value': 'urgent', 'label': l10n.urgent, 'color': AppTheme.errorColor},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.priority,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Wrap(
          spacing: AppTheme.getSmallPadding(screenSize),
          runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
          children: priorities.map((priority) => _PriorityChip(
            value: priority['value'] as String,
            label: priority['label'] as String,
            color: priority['color'] as Color,
            isSelected: selectedPriority == priority['value'],
            onTap: () => onPriorityChanged(priority['value'] as String),
            screenSize: screenSize,
          )).toList(),
        ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;

  const _PriorityChip({
    required this.value,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(screenSize)),
          border: Border.all(
            color: color.withOpacity(isSelected ? 1.0 : 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenSize.height * 0.012,
              height: screenSize.height * 0.012,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
            Text(
              label,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
