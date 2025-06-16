import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../textfield/custom_input_field.dart';
import '../../../models/models.dart';
import '../../../views/admin/students/student_profile_admin_view.dart';

class DirectoryFiltersCard extends StatefulWidget {
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

  const DirectoryFiltersCard({
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
  });

  @override
  State<DirectoryFiltersCard> createState() => _DirectoryFiltersCardState();
}

class _DirectoryFiltersCardState extends State<DirectoryFiltersCard> {
  bool _hasActiveFilters() {
    return widget.searchController.text.isNotEmpty ||
        widget.selectedGrade != 'all' ||
        widget.selectedGroup != 'all' ||
        widget.selectedStatus != 'all';
  }

  void _navigateToStudentProfile(Alumno student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileAdminView(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Debug: Check what students data is being received
    debugPrint(
        'DirectoryFiltersCard: Received ${widget.students.length} students');
    if (widget.students.isNotEmpty) {
      debugPrint(
          'DirectoryFiltersCard: First student: ${widget.students.first.nombre}');
    }

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.1),
            blurRadius: widget.screenSize.height * 0.02,
            offset: Offset(0, widget.screenSize.height * 0.008),
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
                color: AppTheme.accentPurple,
                size: widget.screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
              Expanded(
                child: Text(
                  l10n.searchFilters, // Replaced hardcoded text
                  style: AppTheme.getH2(widget.screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_hasActiveFilters())
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        AppTheme.getSmallPadding(widget.screenSize) * 0.75,
                    vertical:
                        AppTheme.getSmallPadding(widget.screenSize) * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Text(
                    l10n.activeFilters, // Replaced hardcoded text
                    style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              TextButton(
                onPressed: widget.onClearFilters,
                child: Text(
                  l10n.clear, // Replaced hardcoded text
                  style: AppTheme.getCaption(widget.screenSize).copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Enhanced Search Bar using CustomInputField
          CustomInputField(
            controller: widget.searchController,
            label: l10n.searchByName, // Replaced hardcoded text
            screenSize: widget.screenSize,
            icon: Icons.search_rounded,
            keyboardType: TextInputType.text,
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Filter Dropdowns in responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Desktop/Tablet layout - 3 columns
                return Row(
                  children: [
                    Expanded(
                        child: _buildFilterDropdown(
                            l10n.grade, // Replaced hardcoded text
                            widget.selectedGrade,
                            ['all', '1°', '2°', '3°', '4°', '5°', '6°'])),
                    SizedBox(
                        width: AppTheme.getSmallPadding(widget.screenSize)),
                    Expanded(
                        child: _buildFilterDropdown(
                            l10n.group, // Replaced hardcoded text
                            widget.selectedGroup,
                            ['all', 'A', 'B', 'C', 'D'])),
                    SizedBox(
                        width: AppTheme.getSmallPadding(widget.screenSize)),
                    Expanded(
                        child: _buildFilterDropdown(
                            l10n.status, // Replaced hardcoded text
                            widget.selectedStatus,
                            ['all', 'active', 'inactive'])),
                  ],
                );
              } else {
                // Mobile layout - 2 columns
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildFilterDropdown(
                                l10n.grade, // Replaced hardcoded text
                                widget.selectedGrade,
                                ['all', '1°', '2°', '3°', '4°', '5°', '6°'])),
                        SizedBox(
                            width: AppTheme.getSmallPadding(widget.screenSize)),
                        Expanded(
                            child: _buildFilterDropdown(
                                l10n.group, // Replaced hardcoded text
                                widget.selectedGroup,
                                ['all', 'A', 'B', 'C', 'D'])),
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(widget.screenSize)),
                    _buildFilterDropdown(
                        l10n.status, // Replaced hardcoded text
                        widget.selectedStatus,
                        ['all', 'active', 'inactive']),
                  ],
                );
              }
            },
          ),

          // Enhanced Statistics Section
          Container(
            margin: EdgeInsets.only(
              top: AppTheme.getMediumPadding(widget.screenSize),
            ),
            padding:
                EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.studentDirectory, // Replaced hardcoded text
                          style:
                              AppTheme.getBodyLarge(widget.screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.studentsCountOf(
                              widget.totalStudents,
                              widget.filteredStudents
                                  .toString()), // Replaced hardcoded text
                          style: AppTheme.getCaptionSmall(widget.screenSize)
                              .copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.75,
                        vertical:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(widget.screenSize)),
                      ),
                      child: Text(
                        '${widget.filteredStudents}',
                        style: AppTheme.getCaption(widget.screenSize).copyWith(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildCompactStat(l10n.total, widget.totalStudents,
                        AppTheme.accentBlue), // Replaced hardcoded text
                    SizedBox(
                        width: AppTheme.getSmallPadding(widget.screenSize)),
                    _buildCompactStat(
                        l10n.active, // Replaced hardcoded text
                        widget.students.where((s) => s.vinculado).length,
                        AppTheme.successColor),
                    SizedBox(
                        width: AppTheme.getSmallPadding(widget.screenSize)),
                    _buildCompactStat(
                        l10n.inactive, // Replaced hardcoded text
                        widget.students.where((s) => !s.vinculado).length,
                        AppTheme.errorColor),
                  ],
                ),
              ],
            ),
          ),

          // Divider between filters and students list
          Container(
            margin: EdgeInsets.symmetric(
              vertical: AppTheme.getLargePadding(widget.screenSize),
            ),
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),

          // Students List Content
          if (widget.students.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                return _buildStudentItem(widget.students[index],
                    index == widget.students.length - 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(Alumno student, bool isLast) {
    final l10n = AppLocalizations.of(context);
    final statusColor =
        student.vinculado ? AppTheme.successColor : AppTheme.errorColor;
    final gradeGroup = student.grupo;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(widget.screenSize),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToStudentProfile(student),
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(widget.screenSize)),
          child: Container(
            padding:
                EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Row(
              children: [
                // Student Avatar
                Container(
                  width: widget.screenSize.width * 0.12,
                  height: widget.screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Center(
                    child: Text(
                      student.nombre.isNotEmpty
                          ? student.nombre[0].toUpperCase()
                          : 'E',
                      style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.nombre,
                              style: AppTheme.getBodyMedium(widget.screenSize)
                                  .copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            student.id,
                            style: AppTheme.getCaptionSmall(widget.screenSize)
                                .copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(widget.screenSize) *
                              0.5),
                      Wrap(
                        spacing:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                        runSpacing:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.25,
                        children: [
                          _buildChip(gradeGroup, AppTheme.accentBlue),
                          _buildChip(
                              student.vinculado
                                  ? l10n.active
                                  : l10n.inactive, // Replaced hardcoded text
                              statusColor),
                          _buildChip(student.id_llave,
                              AppTheme.getTextSecondaryColor(context)),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),

                // Navigation arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: widget.screenSize.height * 0.025,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: widget.screenSize.width * 0.15,
            color:
                AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Text(
            _hasActiveFilters()
                ? l10n.noStudentsFoundWithFilters // Replaced hardcoded text
                : l10n.noRegisteredStudents, // Replaced hardcoded text
            style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          Text(
            _hasActiveFilters()
                ? l10n.tryAdjustingFilters // Replaced hardcoded text
                : l10n
                    .studentsWillAppearWhenRegistered, // Replaced hardcoded text
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (_hasActiveFilters()) ...[
            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
            TextButton.icon(
              onPressed: widget.onClearFilters,
              icon: Icon(
                Icons.clear_all_rounded,
                color: AppTheme.accentPurple,
                size: widget.screenSize.height * 0.02,
              ),
              label: Text(
                l10n.clearFilters, // Replaced hardcoded text
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(widget.screenSize) * 0.6,
        vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(widget.screenSize) * 0.6),
      ),
      child: Text(
        text,
        style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: widget.screenSize.height * 0.014,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.5),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (newValue) {
              switch (label) {
                case 'Grado':
                  widget.onGradeChanged(newValue!);
                  break;
                case 'Grupo':
                  widget.onGroupChanged(newValue!);
                  break;
                case 'Estado':
                  widget.onStatusChanged(newValue!);
                  break;
              }
            },
            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  _getDropdownLabel(item, label),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getDropdownLabel(String value, String filterType) {
    final l10n = AppLocalizations.of(context);

    if (value == 'all') {
      switch (filterType) {
        case 'Grado':
          return l10n.allGrades; // Replaced hardcoded text
        case 'Grupo':
          return l10n.allGroups; // Replaced hardcoded text
        case 'Estado':
          return l10n.allStatuses; // Replaced hardcoded text
        default:
          return l10n.all; // Replaced hardcoded text
      }
    }

    // Specific labels for status
    if (filterType == 'Estado') {
      switch (value) {
        case 'active':
          return l10n.activeStudents; // Replaced hardcoded text
        case 'inactive':
          return l10n.inactiveStudents; // Replaced hardcoded text
        default:
          return value;
      }
    }

    return value;
  }

  Widget _buildCompactStat(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(widget.screenSize) * 0.75,
        vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(widget.screenSize) * 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: widget.screenSize.height * 0.013,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(widget.screenSize) * 0.3),
          Text(
            value.toString(),
            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: widget.screenSize.height * 0.013,
            ),
          ),
        ],
      ),
    );
  }
}
