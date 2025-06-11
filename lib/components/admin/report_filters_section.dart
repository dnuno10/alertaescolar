import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ReportFiltersSection extends StatelessWidget {
  final Size screenSize;
  final String selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final String selectedGrade;
  final String selectedGroup;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onGroupChanged;

  const ReportFiltersSection({
    super.key,
    required this.screenSize,
    required this.selectedPeriod,
    required this.startDate,
    required this.endDate,
    required this.selectedGrade,
    required this.selectedGroup,
    required this.onPeriodChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onGradeChanged,
    required this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.reportFilters,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Period Selection
          Text(
            l10n.reportPeriod,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildPeriodSelector(context, l10n),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Custom Date Range (if custom period selected)
          if (selectedPeriod == 'custom') ...[
            _buildDateRangeSelector(context, l10n),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ],

          // Grade and Group Selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.grade,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    _buildGradeDropdown(context, l10n),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.group,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    _buildGroupDropdown(context, l10n),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, AppLocalizations l10n) {
    final periods = [
      {'value': 'weekly', 'label': l10n.weeklyReport},
      {'value': 'monthly', 'label': l10n.monthlyReport},
      {'value': 'custom', 'label': l10n.customPeriod},
    ];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize),
      children: periods.map((period) {
        final isSelected = selectedPeriod == period['value'];
        return GestureDetector(
          onTap: () => onPeriodChanged(period['value']!),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getMediumPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentPurple
                  : AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: isSelected
                    ? AppTheme.accentPurple
                    : AppTheme.getBorderColor(context),
              ),
            ),
            child: Text(
              period['label']!,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildDateSelector(
            context,
            l10n.startDate,
            startDate,
            onStartDateChanged,
          ),
        ),
        SizedBox(width: AppTheme.getMediumPadding(screenSize)),
        Expanded(
          child: _buildDateSelector(
            context,
            l10n.endDate,
            endDate,
            onEndDateChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    ValueChanged<DateTime?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        GestureDetector(
          onTap: () => _selectDate(context, selectedDate, onChanged),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: screenSize.width * 0.04,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Seleccionar fecha',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: selectedDate != null
                          ? AppTheme.getTextPrimaryColor(context)
                          : AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDropdown(BuildContext context, AppLocalizations l10n) {
    final grades = ['all', '1°', '2°', '3°', '4°', '5°', '6°'];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: DropdownButton<String>(
        value: selectedGrade,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (value) => onGradeChanged(value!),
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
        ),
        items: grades.map((grade) {
          return DropdownMenuItem(
            value: grade,
            child: Text(grade == 'all' ? l10n.allGrades : grade),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupDropdown(BuildContext context, AppLocalizations l10n) {
    final groups = ['all', 'A', 'B', 'C', 'D'];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: DropdownButton<String>(
        value: selectedGroup,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (value) => onGroupChanged(value!),
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
        ),
        items: groups.map((group) {
          return DropdownMenuItem(
            value: group,
            child: Text(group == 'all' ? l10n.allGroups : group),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    ValueChanged<DateTime?> onChanged,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}
