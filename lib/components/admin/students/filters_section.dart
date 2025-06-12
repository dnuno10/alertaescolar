import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/textfield/custom_input_field.dart';

class FiltersSection extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final Function(String?) onStatusChanged;
  final Size screenSize;

  const FiltersSection({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Added non-null assertion

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.searchFilters,
            style: AppTheme.getH2(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Search Field
          CustomInputField(
            controller: searchController,
            label: l10n.searchByDateStaffOrLocation,
            screenSize: screenSize,
            icon: Icons.search_rounded,
            keyboardType: TextInputType.text,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Status Filter
          Text(
            l10n.status,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
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
              value: selectedStatus,
              isExpanded: true,
              underline: const SizedBox(),
              onChanged: onStatusChanged,
              items: [
                DropdownMenuItem(value: 'all', child: Text(l10n.all)),
                DropdownMenuItem(value: 'present', child: Text(l10n.present)),
                DropdownMenuItem(value: 'late', child: Text(l10n.late)),
                DropdownMenuItem(value: 'absent', child: Text(l10n.absent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
