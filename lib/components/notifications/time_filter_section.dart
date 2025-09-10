import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class TimeFilterSection extends StatelessWidget {
  final Size screenSize;
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const TimeFilterSection({
    super.key,
    required this.screenSize,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getLargePadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.period,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Row(
            children: [
              _TimeFilterChip(
                value: 'today',
                label: l10n.today,
                isSelected: currentFilter == 'today',
                onSelected: onFilterChanged,
                screenSize: screenSize,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              _TimeFilterChip(
                value: '7days',
                label: l10n.sevenDays,
                isSelected: currentFilter == '7days',
                onSelected: onFilterChanged,
                screenSize: screenSize,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              _TimeFilterChip(
                value: '14days',
                label: l10n.fourteenDays,
                isSelected: currentFilter == '14days',
                onSelected: onFilterChanged,
                screenSize: screenSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeFilterChip extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final ValueChanged<String> onSelected;
  final Size screenSize;

  const _TimeFilterChip({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final rad = AppTheme.getSmallRadius(screenSize);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelected(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: screenSize.height * 0.052,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentBlue
                : AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(rad),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentBlue
                  : AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.getSubtitle2(screenSize).copyWith(
              color: isSelected
                  ? Colors.white
                  : AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
