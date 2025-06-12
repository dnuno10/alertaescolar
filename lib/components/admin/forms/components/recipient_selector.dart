import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class RecipientSelector extends StatelessWidget {
  final Size screenSize;
  final String recipientType;
  final String selectedGrade;
  final String selectedGroup;
  final String selectedStudent;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onGroupChanged;
  final ValueChanged<String> onStudentChanged;

  const RecipientSelector({
    super.key,
    required this.screenSize,
    required this.recipientType,
    required this.selectedGrade,
    required this.selectedGroup,
    required this.selectedStudent,
    required this.onGradeChanged,
    required this.onGroupChanged,
    required this.onStudentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (recipientType == 'group') {
      return _GroupSelector(
        screenSize: screenSize,
        selectedGrade: selectedGrade,
        selectedGroup: selectedGroup,
        onGradeChanged: onGradeChanged,
        onGroupChanged: onGroupChanged,
        l10n: l10n,
      );
    } else {
      return _StudentSelector(
        screenSize: screenSize,
        selectedStudent: selectedStudent,
        onStudentChanged: onStudentChanged,
        l10n: l10n,
      );
    }
  }
}

class _GroupSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedGrade;
  final String selectedGroup;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onGroupChanged;
  final AppLocalizations l10n;

  const _GroupSelector({
    required this.screenSize,
    required this.selectedGrade,
    required this.selectedGroup,
    required this.onGradeChanged,
    required this.onGroupChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final grades = ['1°', '2°', '3°', '4°', '5°', '6°'];
    final groups = ['A', 'B', 'C'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grade Selector
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
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGrade.isEmpty ? null : selectedGrade,
              hint: Text(
                l10n.allGrades,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(
                    l10n.allGrades,
                    style: AppTheme.getBodyMedium(screenSize),
                  ),
                ),
                ...grades.map((grade) => DropdownMenuItem(
                      value: grade,
                      child: Text(
                        grade,
                        style: AppTheme.getBodyMedium(screenSize),
                      ),
                    )),
              ],
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

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Group Selector
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
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGroup.isEmpty ? null : selectedGroup,
              hint: Text(
                l10n.allGroups,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(
                    l10n.allGroups,
                    style: AppTheme.getBodyMedium(screenSize),
                  ),
                ),
                ...groups.map((group) => DropdownMenuItem(
                      value: group,
                      child: Text(
                        group,
                        style: AppTheme.getBodyMedium(screenSize),
                      ),
                    )),
              ],
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

class _StudentSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedStudent;
  final ValueChanged<String> onStudentChanged;
  final AppLocalizations l10n;

  const _StudentSelector({
    required this.screenSize,
    required this.selectedStudent,
    required this.onStudentChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Mock student data
    final students = [
      'Ana García Martínez (3°A)',
      'Carlos Rodríguez Silva (2°B)',
      'Sofía González Pérez (1°A)',
      'Miguel Torres López (3°A)',
      'Isabella Hernández Cruz (2°B)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectStudent ?? 'Seleccionar estudiante',
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
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStudent.isEmpty ? null : selectedStudent,
              hint: Text(
                l10n.searchStudents,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              items: students
                  .map((student) => DropdownMenuItem(
                        value: student,
                        child: Text(
                          student,
                          style: AppTheme.getBodyMedium(screenSize),
                        ),
                      ))
                  .toList(),
              onChanged: (value) => onStudentChanged(value ?? ''),
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
