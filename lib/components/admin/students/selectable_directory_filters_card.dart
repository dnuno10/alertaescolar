import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';
import '../../../components/textfield/custom_input_field.dart';
import 'filter_dropdown.dart';
import 'student_empty_state.dart';
import '../../../utils/modern_dropdown.dart';
import 'package:provider/provider.dart';

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
  final List<StudentDetails> students;
  final Function(StudentDetails) onStudentSelected;
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
              final studentProvider =
                  Provider.of<StudentProvider>(context, listen: false);
              final gradeItems = [
                'all',
                ...studentProvider.getAvailableGrupoNames().toSet()
              ];
              final groupItems = [
                'all',
                ...studentProvider.getAvailableNivelesEducativos().toSet()
              ];
              final statusItems = ['all', 'active', 'inactive'];
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      child: ModernDropdown<String>(
                        label: l10n.grade,
                        value: selectedGrade,
                        items: gradeItems,
                        onChanged: (String? value) =>
                            onGradeChanged(value ?? 'all'),
                        getLabel: (v) => v == 'all' ? l10n.all : v,
                        screenSize: screenSize,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: ModernDropdown<String>(
                        label: l10n.group,
                        value: selectedGroup,
                        items: groupItems,
                        onChanged: (String? value) =>
                            onGroupChanged(value ?? 'all'),
                        getLabel: (v) => v == 'all' ? l10n.all : v,
                        screenSize: screenSize,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: ModernDropdown<String>(
                        label: l10n.status,
                        value: selectedStatus,
                        items: statusItems,
                        onChanged: (String? value) =>
                            onStatusChanged(value ?? 'all'),
                        getLabel: (v) {
                          switch (v) {
                            case 'all':
                              return l10n.all;
                            case 'active':
                              return l10n.activated;
                            case 'inactive':
                              return l10n.deactivated;
                            default:
                              return v;
                          }
                        },
                        screenSize: screenSize,
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
                          child: ModernDropdown<String>(
                            label: l10n.grade,
                            value: selectedGrade,
                            items: gradeItems,
                            onChanged: (String? value) =>
                                onGradeChanged(value ?? 'all'),
                            getLabel: (v) => v == 'all' ? l10n.all : v,
                            screenSize: screenSize,
                          ),
                        ),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Expanded(
                          child: ModernDropdown<String>(
                            label: l10n.group,
                            value: selectedGroup,
                            items: groupItems,
                            onChanged: (String? value) =>
                                onGroupChanged(value ?? 'all'),
                            getLabel: (v) => v == 'all' ? l10n.all : v,
                            screenSize: screenSize,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Row(
                      children: [
                        Expanded(
                          child: ModernDropdown<String>(
                            label: l10n.status,
                            value: selectedStatus,
                            items: statusItems,
                            onChanged: (String? value) =>
                                onStatusChanged(value ?? 'all'),
                            getLabel: (v) {
                              switch (v) {
                                case 'all':
                                  return l10n.all;
                                case 'active':
                                  return l10n.activated;
                                case 'inactive':
                                  return l10n.deactivated;
                                default:
                                  return v;
                              }
                            },
                            screenSize: screenSize,
                          ),
                        ),
                      ],
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
                return _buildStudentItem(
                    context, students[index], index == students.length - 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(
      BuildContext context, StudentDetails student, bool isLast) {
    final l10n = AppLocalizations.of(context);
    final statusColor =
        student.llaveActiva ? AppTheme.successColor : AppTheme.errorColor;
    final gradeGroup = student.grupo;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onStudentSelected(student),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Row(
              children: [
                // Student Avatar
                Container(
                  width: screenSize.width * 0.12,
                  height: screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Center(
                    child: Text(
                      student.nombre.isNotEmpty
                          ? student.nombre[0].toUpperCase()
                          : 'E',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: AppTheme.getMediumPadding(screenSize)),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.nombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Wrap(
                        spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
                        runSpacing: AppTheme.getSmallPadding(screenSize) * 0.25,
                        children: [
                          _buildChip(gradeGroup, AppTheme.accentBlue),
                          _buildChip(
                              student.llaveActiva ? l10n.active : l10n.inactive,
                              statusColor),
                          student.matricula.isNotEmpty
                              ? _buildChip(student.matricula,
                                  AppTheme.getTextSecondaryColor(context))
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppTheme.getSmallPadding(screenSize)),

                // Selection indicator - different from main directory
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.touch_app_rounded,
                    color: AppTheme.accentOrange,
                    size: screenSize.height * 0.022,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.6,
        vertical: AppTheme.getSmallPadding(screenSize) * 0.2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize) * 0.6),
      ),
      child: Text(
        text,
        style: AppTheme.getCaptionSmall(screenSize).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: screenSize.height * 0.014,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
