import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ReportFilters extends StatelessWidget {
  final Size screenSize;
  final String selectedPeriod;
  final String selectedGrade;
  final String selectedGroup;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onGroupChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;

  const ReportFilters({
    super.key,
    required this.screenSize,
    required this.selectedPeriod,
    required this.selectedGrade,
    required this.selectedGroup,
    required this.startDate,
    required this.endDate,
    required this.onPeriodChanged,
    required this.onGradeChanged,
    required this.onGroupChanged,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.reportFilters ?? 'Filtros del reporte',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          
          // Period Filter
          _PeriodSelector(
            screenSize: screenSize,
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
            l10n: l10n,
          ),
          
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          
          // Custom Date Range (only shown for custom period)
          if (selectedPeriod == 'custom') ...[
            _DateRangeSelector(
              screenSize: screenSize,
              startDate: startDate,
              endDate: endDate,
              onDateRangeChanged: onDateRangeChanged,
              l10n: l10n,
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ],
          
          // Grade and Group Filters
          Row(
            children: [
              Expanded(
                child: _GradeSelector(
                  screenSize: screenSize,
                  selectedGrade: selectedGrade,
                  onGradeChanged: onGradeChanged,
                  l10n: l10n,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: _GroupSelector(
                  screenSize: screenSize,
                  selectedGroup: selectedGroup,
                  onGroupChanged: onGroupChanged,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final AppLocalizations l10n;

  const _PeriodSelector({
    required this.screenSize,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      {'value': 'daily', 'label': l10n.dailyReport},
      {'value': 'weekly', 'label': l10n.weeklyReport},
      {'value': 'monthly', 'label': l10n.monthlyReport},
      {'value': 'custom', 'label': l10n.customPeriod ?? 'Período personalizado'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportPeriod ?? 'Período del reporte',
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Wrap(
          spacing: AppTheme.getSmallPadding(screenSize),
          runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
          children: periods.map((period) => _PeriodChip(
            value: period['value'] as String,
            label: period['label'] as String,
            isSelected: selectedPeriod == period['value'],
            onTap: () => onPeriodChanged(period['value'] as String),
            screenSize: screenSize,
          )).toList(),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;

  const _PeriodChip({
    required this.value,
    required this.label,
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
          color: isSelected ? AppTheme.accentBlue : AppTheme.accentBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          border: Border.all(
            color: AppTheme.accentBlue.withOpacity(isSelected ? 1.0 : 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: isSelected ? Colors.white : AppTheme.accentBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final Size screenSize;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final AppLocalizations l10n;

  const _DateRangeSelector({
    required this.screenSize,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectDateRange,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Row(
          children: [
            Expanded(
              child: _DateButton(
                label: l10n.startDate,
                date: startDate,
                onTap: () => _selectStartDate(context),
                screenSize: screenSize,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
            Expanded(
              child: _DateButton(
                label: l10n.endDate,
                date: endDate,
                onTap: () => _selectEndDate(context),
                screenSize: screenSize,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: endDate ?? DateTime.now(),
    );
    if (date != null) {
      onDateRangeChanged(date, endDate);
    }
  }

  void _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      onDateRangeChanged(startDate, date);
    }
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final Size screenSize;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getInputFillColor(context),
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.02,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                Text(
                  date != null 
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : 'Seleccionar',
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedGrade;
  final ValueChanged<String> onGradeChanged;
  final AppLocalizations l10n;

  const _GradeSelector({
    required this.screenSize,
    required this.selectedGrade,
    required this.onGradeChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final grades = ['', '1°', '2°', '3°', '4°', '5°', '6°'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectGrade,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getMediumPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize),
          ),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGrade.isEmpty ? '' : selectedGrade,
              hint: Text(
                l10n.allGrades,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              items: grades.map((grade) => DropdownMenuItem(
                value: grade,
                child: Text(
                  grade.isEmpty ? l10n.allGrades : grade,
                  style: AppTheme.getBodyMedium(screenSize),
                ),
              )).toList(),
              onChanged: (value) => onGradeChanged(value ?? ''),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              dropdownColor: AppTheme.getCardColor(context),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedGroup;
  final ValueChanged<String> onGroupChanged;
  final AppLocalizations l10n;

  const _GroupSelector({
    required this.screenSize,
    required this.selectedGroup,
    required this.onGroupChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final groups = ['', 'A', 'B', 'C'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectGroup,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getMediumPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize),
          ),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGroup.isEmpty ? '' : selectedGroup,
              hint: Text(
                l10n.allGroups,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              items: groups.map((group) => DropdownMenuItem(
                value: group,
                child: Text(
                  group.isEmpty ? l10n.allGroups : group,
                  style: AppTheme.getBodyMedium(screenSize),
                ),
              )).toList(),
              onChanged: (value) => onGroupChanged(value ?? ''),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              dropdownColor: AppTheme.getCardColor(context),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
