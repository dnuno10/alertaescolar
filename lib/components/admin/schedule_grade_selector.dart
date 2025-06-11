import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ScheduleGradeSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedGrade;
  final String selectedGroup;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onGroupChanged;

  const ScheduleGradeSelector({
    super.key,
    required this.screenSize,
    required this.selectedGrade,
    required this.selectedGroup,
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
                  Icons.class_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.selectGradeAndGroup ?? 'Seleccionar grado y grupo',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Grade Selection
          Text(
            l10n.selectGrade,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _GradeSelector(
            selectedGrade: selectedGrade,
            onGradeChanged: onGradeChanged,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Group Selection
          Text(
            l10n.selectGroup,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _GroupSelector(
            selectedGroup: selectedGroup,
            onGroupChanged: onGroupChanged,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Selected Info
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.02,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  '${l10n.editingScheduleFor ?? 'Editando horario para'}: $selectedGrade$selectedGroup',
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeSelector extends StatelessWidget {
  final String selectedGrade;
  final ValueChanged<String> onGradeChanged;
  final Size screenSize;

  const _GradeSelector({
    required this.selectedGrade,
    required this.onGradeChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final grades = ['1°', '2°', '3°', '4°', '5°', '6°'];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize),
      runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      children: grades.map((grade) => _SelectionChip(
        label: grade,
        isSelected: selectedGrade == grade,
        onTap: () => onGradeChanged(grade),
        screenSize: screenSize,
        color: AppTheme.accentBlue,
      )).toList(),
    );
  }
}

class _GroupSelector extends StatelessWidget {
  final String selectedGroup;
  final ValueChanged<String> onGroupChanged;
  final Size screenSize;

  const _GroupSelector({
    required this.selectedGroup,
    required this.onGroupChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final groups = ['A', 'B', 'C', 'D'];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize),
      runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      children: groups.map((group) => _SelectionChip(
        label: group,
        isSelected: selectedGroup == group,
        onTap: () => onGroupChanged(group),
        screenSize: screenSize,
        color: AppTheme.successColor,
      )).toList(),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;
  final Color color;

  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.screenSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize),
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
          style: AppTheme.getCaption(screenSize).copyWith(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
