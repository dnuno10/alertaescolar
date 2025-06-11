import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../views/admin/student_profile_admin_view.dart';

class StudentsListAdmin extends StatelessWidget {
  final Size screenSize;
  final String searchQuery;
  final String selectedGrade;
  final String selectedGroup;
  final String selectedStatus;

  const StudentsListAdmin({
    super.key,
    required this.screenSize,
    required this.searchQuery,
    required this.selectedGrade,
    required this.selectedGroup,
    required this.selectedStatus,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final students = _generateFilteredStudents();

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
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: AppTheme.warningColor,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.studentsDirectory,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.5),
                ),
                child: Text(
                  '${students.length} ${l10n.studentsFound}',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Students List
          if (students.isEmpty)
            _EmptyState(screenSize: screenSize, l10n: l10n)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _StudentListItem(
                  student: student,
                  screenSize: screenSize,
                  isLast: index == students.length - 1,
                  l10n: l10n,
                );
              },
            ),
        ],
      ),
    );
  }

  List<Alumno> _generateFilteredStudents() {
    // Mock student data
    final allStudents = [
      Alumno(
        id: 'std_001',
        nombre: 'Ana García Martínez',
        grado: '3°',
        grupo: 'A',
        escuelaId: 'school_001',
        llave: 'KEY001',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
        tutoresIds: ['tutor_001'],
      ),
      Alumno(
        id: 'std_002',
        nombre: 'Carlos Rodríguez Silva',
        grado: '2°',
        grupo: 'B',
        escuelaId: 'school_001',
        llave: 'KEY002',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 45)),
        tutoresIds: ['tutor_002'],
      ),
      Alumno(
        id: 'std_003',
        nombre: 'Sofía González Pérez',
        grado: '1°',
        grupo: 'A',
        escuelaId: 'school_001',
        llave: 'KEY003',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 60)),
        tutoresIds: ['tutor_003'],
      ),
      Alumno(
        id: 'std_004',
        nombre: 'Miguel Torres López',
        grado: '3°',
        grupo: 'A',
        escuelaId: 'school_001',
        llave: 'KEY004',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 20)),
        tutoresIds: ['tutor_004'],
      ),
      Alumno(
        id: 'std_005',
        nombre: 'Isabella Hernández Cruz',
        grado: '2°',
        grupo: 'B',
        escuelaId: 'school_001',
        llave: 'KEY005',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 35)),
        tutoresIds: ['tutor_005'],
      ),
      Alumno(
        id: 'std_006',
        nombre: 'Diego Morales Ruiz',
        grado: '4°',
        grupo: 'C',
        escuelaId: 'school_001',
        llave: 'KEY006',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 50)),
        tutoresIds: ['tutor_006'],
      ),
    ];

    // Apply filters
    return allStudents.where((student) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!student.nombre.toLowerCase().contains(query) &&
            !student.id.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Grade filter
      if (selectedGrade.isNotEmpty && student.grado != selectedGrade) {
        return false;
      }

      // Group filter
      if (selectedGroup.isNotEmpty && student.grupo != selectedGroup) {
        return false;
      }

      // Status filter (for demo, all students are active)
      if (selectedStatus == 'inactive') {
        return false; // No inactive students in mock data
      }

      return true;
    }).toList();
  }
}

class _StudentListItem extends StatelessWidget {
  final Alumno student;
  final Size screenSize;
  final bool isLast;
  final AppLocalizations l10n;

  const _StudentListItem({
    required this.student,
    required this.screenSize,
    required this.isLast,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
    ];
    final color = colors[student.hashCode % colors.length];

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToStudentProfile(context),
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Student Avatar
                Container(
                  width: screenSize.height * 0.07,
                  height: screenSize.height * 0.07,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(screenSize.height * 0.035),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(student.nombre),
                      style: AppTheme.getSubtitle1(screenSize).copyWith(
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
                        style: AppTheme.getSubtitle1(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                              vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getSmallRadius(screenSize) * 0.5),
                            ),
                            child: Text(
                              '${student.grado}${student.grupo}',
                              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                          Text(
                            'ID: ${student.id}',
                            style: AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Text(
                        '${l10n.registeredOn ?? 'Registrado el'}: ${_formatDate(student.fechaRegistro)}',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.successColor,
                        size: screenSize.height * 0.02,
                      ),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      l10n.activated,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: AppTheme.getSmallPadding(screenSize)),

                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.025,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStudentProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileAdminView(student: student),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'S';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyState extends StatelessWidget {
  final Size screenSize;
  final AppLocalizations l10n;

  const _EmptyState({
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: screenSize.height * 0.08,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              l10n.noStudentsFound,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.tryDifferentFilters ?? 'Intente con diferentes filtros o términos de búsqueda',
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
