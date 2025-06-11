import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class StudentsFilters extends StatelessWidget {
  final Size screenSize;
  final String selectedGrade;
  final String selectedGroup;
  final String selectedStatus;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onGroupChanged;
  final ValueChanged<String> onStatusChanged;

  const StudentsFilters({
    super.key,
    required this.screenSize,
    required this.selectedGrade,
    required this.selectedGroup,
    required this.selectedStatus,
    required this.onGradeChanged,
    required this.onGroupChanged,
    required this.onStatusChanged,
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.filterBy,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    l10n.clearFilters ?? 'Limpiar filtros',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.accentPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Grade Filter
          _FilterSection(
            title: l10n.grade ?? 'Grado',
            icon: Icons.school_rounded,
            color: AppTheme.accentBlue,
            screenSize: screenSize,
            child: _GradeFilter(
              selectedGrade: selectedGrade,
              onGradeChanged: onGradeChanged,
              screenSize: screenSize,
              l10n: l10n,
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Group Filter
          _FilterSection(
            title: l10n.group ?? 'Grupo',
            icon: Icons.class_rounded,
            color: AppTheme.successColor,
            screenSize: screenSize,
            child: _GroupFilter(
              selectedGroup: selectedGroup,
              onGroupChanged: onGroupChanged,
              screenSize: screenSize,
              l10n: l10n,
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Status Filter
          _FilterSection(
            title: l10n.status,
            icon: Icons.toggle_on_rounded,
            color: AppTheme.warningColor,
            screenSize: screenSize,
            child: _StatusFilter(
              selectedStatus: selectedStatus,
              onStatusChanged: onStatusChanged,
              screenSize: screenSize,
              l10n: l10n,
            ),
          ),

          if (_hasActiveFilters()) ...[
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            _ActiveFiltersDisplay(
              selectedGrade: selectedGrade,
              selectedGroup: selectedGroup,
              selectedStatus: selectedStatus,
              screenSize: screenSize,
              l10n: l10n,
            ),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedGrade.isNotEmpty || 
           selectedGroup.isNotEmpty || 
           selectedStatus.isNotEmpty;
  }

  void _clearAllFilters() {
    onGradeChanged('');
    onGroupChanged('');
    onStatusChanged('');
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final Size screenSize;

  const _FilterSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: screenSize.height * 0.02,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
            Text(
              title,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        child,
      ],
    );
  }
}

class _GradeFilter extends StatelessWidget {
  final String selectedGrade;
  final ValueChanged<String> onGradeChanged;
  final Size screenSize;
  final AppLocalizations l10n;

  const _GradeFilter({
    required this.selectedGrade,
    required this.onGradeChanged,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final grades = ['1°', '2°', '3°', '4°', '5°', '6°'];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      children: [
        _FilterChip(
          label: l10n.allGrades,
          isSelected: selectedGrade.isEmpty,
          onTap: () => onGradeChanged(''),
          color: AppTheme.accentBlue,
          screenSize: screenSize,
        ),
        ...grades.map((grade) => _FilterChip(
          label: grade,
          isSelected: selectedGrade == grade,
          onTap: () => onGradeChanged(grade),
          color: AppTheme.accentBlue,
          screenSize: screenSize,
        )),
      ],
    );
  }
}

class _GroupFilter extends StatelessWidget {
  final String selectedGroup;
  final ValueChanged<String> onGroupChanged;
  final Size screenSize;
  final AppLocalizations l10n;

  const _GroupFilter({
    required this.selectedGroup,
    required this.onGroupChanged,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final groups = ['A', 'B', 'C', 'D'];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      children: [
        _FilterChip(
          label: l10n.allGroups,
          isSelected: selectedGroup.isEmpty,
          onTap: () => onGroupChanged(''),
          color: AppTheme.successColor,
          screenSize: screenSize,
        ),
        ...groups.map((group) => _FilterChip(
          label: group,
          isSelected: selectedGroup == group,
          onTap: () => onGroupChanged(group),
          color: AppTheme.successColor,
          screenSize: screenSize,
        )),
      ],
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final Size screenSize;
  final AppLocalizations l10n;

  const _StatusFilter({
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'value': 'active', 'label': l10n.activeStudents, 'color': AppTheme.successColor},
      {'value': 'inactive', 'label': l10n.inactiveStudents, 'color': AppTheme.errorColor},
    ];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      children: [
        _FilterChip(
          label: l10n.allStatus ?? 'Todos los estados',
          isSelected: selectedStatus.isEmpty,
          onTap: () => onStatusChanged(''),
          color: AppTheme.warningColor,
          screenSize: screenSize,
        ),
        ...statuses.map((status) => _FilterChip(
          label: status['label'] as String,
          isSelected: selectedStatus == status['value'],
          onTap: () => onStatusChanged(status['value'] as String),
          color: status['color'] as Color,
          screenSize: screenSize,
        )),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final Size screenSize;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
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
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          border: Border.all(
            color: color.withOpacity(isSelected ? 1.0 : 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ActiveFiltersDisplay extends StatelessWidget {
  final String selectedGrade;
  final String selectedGroup;
  final String selectedStatus;
  final Size screenSize;
  final AppLocalizations l10n;

  const _ActiveFiltersDisplay({
    required this.selectedGrade,
    required this.selectedGroup,
    required this.selectedStatus,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilters = <String>[];
    
    if (selectedGrade.isNotEmpty) activeFilters.add('${l10n.grade}: $selectedGrade');
    if (selectedGroup.isNotEmpty) activeFilters.add('${l10n.group}: $selectedGroup');
    if (selectedStatus.isNotEmpty) {
      final statusText = selectedStatus == 'active' 
          ? l10n.activeStudents 
          : l10n.inactiveStudents;
      activeFilters.add('${l10n.status}: $statusText');
    }

    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.activeFilters ?? 'Filtros activos',
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            activeFilters.join(' • '),
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.accentPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
