import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ScheduleGradeSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedGrade;
  final String selectedGroup;
  final Function(String) onGradeChanged;
  final Function(String) onGroupChanged;

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
    final grades = ['1°', '2°', '3°', '4°', '5°', '6°'];
    final groups = ['A', 'B', 'C', 'D'];

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.class_rounded,
            color: AppTheme.accentPurple,
            size: screenSize.height * 0.025,
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Seleccionar:',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),

          // Grade Selector
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedGrade,
              decoration: InputDecoration(
                labelText: 'Grado',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
                ),
              ),
              items: grades.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onGradeChanged(value);
                }
              },
            ),
          ),

          SizedBox(width: AppTheme.getMediumPadding(screenSize)),

          // Group Selector
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedGroup,
              decoration: InputDecoration(
                labelText: 'Grupo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
                ),
              ),
              items: groups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onGroupChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
