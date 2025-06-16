import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../components/textfield/custom_input_field.dart';
import 'filter_dropdown.dart';
import 'student_empty_state.dart';
import 'selectable_student_item.dart';

class SelectableDirectoryFiltersCard extends StatelessWidget {
  final Size screenSize;
  final String selectedGrade;
  final String selectedGroup;
  final String selectedStatus;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onGroupChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onClearFilters;
  final TextEditingController searchController;
  final int totalStudents;
  final int filteredStudents;
  final List<Alumno> students;
  final Function(Alumno) onStudentSelected;
  final bool selectionMode;

  const SelectableDirectoryFiltersCard({
    super.key,
    required this.screenSize,
    required this.selectedGrade,
    required this.selectedGroup,
    required this.selectedStatus,
    required this.onGradeChanged,
    required this.onGroupChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.searchController,
    required this.totalStudents,
    required this.filteredStudents,
    required this.students,
    required this.onStudentSelected,
    required this.selectionMode,
  });

  bool _hasActiveFilters() {
    return searchController.text.isNotEmpty ||
        selectedGrade != 'all' ||
        selectedGroup != 'all' ||
        selectedStatus != 'all';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.1),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, screenSize.height * 0.008),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Filter Header
          Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: AppTheme.accentOrange,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.searchStudent,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_hasActiveFilters())
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Text(
                    l10n.activeFilters,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              TextButton(
                onPressed: onClearFilters,
                child: Text(
                  l10n.clear,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Search Bar
          CustomInputField(
            controller: searchController,
            label: l10n.searchByNameOrId,
            screenSize: screenSize,
            icon: Icons.search_rounded,
            keyboardType: TextInputType.text,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Filter Dropdowns
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      child: FilterDropdown(
                        label: l10n.grade,
                        value: selectedGrade,
                        items: ['all', '1°', '2°', '3°', '4°', '5°', '6°'],
                        onChanged: onGradeChanged,
                        screenSize: screenSize,
                        filterType: 'grade',
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: FilterDropdown(
                        label: l10n.group,
                        value: selectedGroup,
                        items: ['all', 'A', 'B', 'C', 'D'],
                        onChanged: onGroupChanged,
                        screenSize: screenSize,
                        filterType: 'group',
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: FilterDropdown(
                        label: l10n.status,
                        value: selectedStatus,
                        items: ['all', 'active', 'inactive'],
                        onChanged: onStatusChanged,
                        screenSize: screenSize,
                        filterType: 'status',
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilterDropdown(
                            label: l10n.grade,
                            value: selectedGrade,
                            items: ['all', '1°', '2°', '3°', '4°', '5°', '6°'],
                            onChanged: onGradeChanged,
                            screenSize: screenSize,
                            filterType: 'grade',
                          ),
                        ),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Expanded(
                          child: FilterDropdown(
                            label: l10n.group,
                            value: selectedGroup,
                            items: ['all', 'A', 'B', 'C', 'D'],
                            onChanged: onGroupChanged,
                            screenSize: screenSize,
                            filterType: 'group',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    FilterDropdown(
                      label: l10n.status,
                      value: selectedStatus,
                      items: ['all', 'active', 'inactive'],
                      onChanged: onStatusChanged,
                      screenSize: screenSize,
                      filterType: 'status',
                    ),
                  ],
                );
              }
            },
          ),

          // Statistics
          Container(
            margin: EdgeInsets.only(top: AppTheme.getMediumPadding(screenSize)),
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.studentsFound,
                        style: AppTheme.getBodyLarge(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.studentCountOf((filteredStudents / totalStudents)
                            .toInt()), // Using a formatted string as single parameter
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Text(
                    '$filteredStudents',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            margin: EdgeInsets.symmetric(
                vertical: AppTheme.getLargePadding(screenSize)),
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),

          // Students List
          if (students.isEmpty)
            StudentEmptyState(screenSize: screenSize)
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return SelectableStudentItem(
                  student: students[index],
                  isLast: index == students.length - 1,
                  onSelected: onStudentSelected,
                  screenSize: screenSize,
                );
              },
            ),
        ],
      ),
    );
  }
}
