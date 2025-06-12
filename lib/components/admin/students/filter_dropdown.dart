import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Size screenSize;
  final String filterType;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.screenSize,
    required this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (newValue) => onChanged(newValue!),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  _getDropdownLabel(l10n, item, filterType),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getDropdownLabel(
      AppLocalizations l10n, String value, String filterType) {
    if (value == 'all') {
      switch (filterType) {
        case 'grade':
          return l10n.allGrades;
        case 'group':
          return l10n.allGroups;
        case 'status':
          return l10n.allStatuses;
        default:
          return l10n.all;
      }
    }

    if (filterType == 'status') {
      switch (value) {
        case 'active':
          return l10n.activeStudents;
        case 'inactive':
          return l10n.inactiveStudents;
        default:
          return value;
      }
    }

    return value;
  }
}
