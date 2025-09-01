import 'package:alertaescolar/components/admin/directory/directory_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:flutter/services.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/group_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../utils/modern_dropdown.dart';
import 'student_profile_admin_view.dart';

class StudentsDirectoryView extends StatefulWidget {
  const StudentsDirectoryView({super.key});

  @override
  State<StudentsDirectoryView> createState() => _StudentsDirectoryViewState();
}

class _StudentsDirectoryViewState extends State<StudentsDirectoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGrade = 'all'; // grupo
  String _selectedGroup = 'all'; // nivel_educativo
  String _selectedStatus = 'all';
  String _selectedTurno = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);

    // Load students and groups after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStudents);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    final userId = userProvider.currentUser?.id;
    String? escuelaId = userProvider.currentUser?.escuelaId;

    try {
      // Resolver escuelaId si viene null (tutor o admin)
      escuelaId ??= await studentProvider.getUserSchoolId(userId ?? '');
      escuelaId ??=
          await studentProvider.getAdminEscuelaUuidByUserId(userId ?? '');

      debugPrint(
          'Resolved escuelaId for admin directory: $escuelaId (userId=$userId)');

      if (escuelaId == null) {
        // No más fallback a 'ESC001'
        throw Exception('No se encontró escuela asociada al usuario');
      }

      await Future.wait([
        studentProvider.loadStudents(escuelaId: escuelaId, userId: userId),
        groupProvider.loadGroups(escuelaId: escuelaId),
      ]);

      if (mounted) _filterStudents();
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
      if (mounted) {
        // aquí tu diálogo/snackbar si quieres
      }
    }
  }

  Future<void> _loadStudents() async {
    if (!mounted) return;
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      String? escuelaUuid = userProvider.currentUser?.escuelaId;
      if (escuelaUuid == null || escuelaUuid.isEmpty) {
        final String? userId = userProvider.currentUser?.id;
        if (userId != null && userId.isNotEmpty) {
          escuelaUuid =
              await studentProvider.getAdminEscuelaUuidByUserId(userId);
        }
      }

      if (escuelaUuid == null || escuelaUuid.isEmpty) {
        debugPrint('No se pudo resolver el UUID de la escuela del admin.');
        return;
      }

      await studentProvider.loadStudents(escuelaId: escuelaUuid);

      if (mounted) _filterStudents();

      debugPrint(
        'After load and filter - Students loaded: ${studentProvider.students.length}',
      );
      debugPrint(
        'After load and filter - Filtered students: ${studentProvider.filteredStudents.length}',
      );

      if (studentProvider.error != null) {
        debugPrint('Error loading students: ${studentProvider.error}');
      }
    } catch (e) {
      debugPrint('Error in _loadStudents: $e');
    }
  }

  void _filterStudents() {
    if (!mounted) return;

    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    studentProvider.filterStudents(
      searchQuery: _searchController.text,
      grupo: _selectedGrade, // Filter by grupo name
      nivelEducativo: _selectedGroup, // Filter by nivel_educativo
      status: _selectedStatus,
      turno: _selectedTurno, // Filter by turno name
    );
  }

  // Get available groups based on selected education level
  List<String> _getAvailableGroups() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (_selectedGroup == 'all') {
      // Show all groups when no specific education level is selected
      return ['all', ...groupProvider.grupos.map((g) => g.grupo).toSet()];
    } else {
      // Show only groups for the selected education level
      final filteredGroups =
          groupProvider.getGroupsByNivelEducativo(_selectedGroup);
      return ['all', ...filteredGroups.map((g) => g.grupo).toSet()];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer4<ThemeProvider, StudentProvider, UserProvider,
        GroupProvider>(
      builder: (context, themeProvider, studentProvider, userProvider,
          groupProvider, child) {
        final allStudents = studentProvider.filteredStudents;

        // Show loading state
        if (studentProvider.isLoading && studentProvider.students.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error state
        if (studentProvider.error != null && studentProvider.students.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    studentProvider.error!,
                    style: AppTheme.getBodyMedium(screenSize),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _loadStudents();
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        // Get available options for dropdowns
        final availableNiveles = [
          'all',
          ...groupProvider.getAvailableNivelesEducativos()
        ];
        final availableGroups = _getAvailableGroups();

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Use new DirectoryHeader component
              SliverToBoxAdapter(
                child: DirectoryHeader(
                  title: l10n.studentsDirectory,
                  subtitle: l10n.manageAndSearchStudents,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Filters Card with Dynamic Dropdowns
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getLargeRadius(screenSize)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getShadowColor(context)
                                  .withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
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
                                  Icons.search_rounded,
                                  color: AppTheme.accentPurple,
                                  size: screenSize.width * 0.06,
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.getMediumPadding(screenSize)),
                                Expanded(
                                  child: Text(
                                    l10n.searchFilters,
                                    style: AppTheme.getH2(screenSize).copyWith(
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      _selectedGrade = 'all';
                                      _selectedGroup = 'all';
                                      _selectedStatus = 'all';
                                      _selectedTurno = 'all';
                                      _searchController.clear();
                                    });
                                    _filterStudents();
                                  },
                                  child: Text(
                                    l10n.clear,
                                    style: AppTheme.getCaption(screenSize)
                                        .copyWith(
                                      color: AppTheme.accentPurple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),

                            // Search Field
                            CustomInputField(
                              controller: _searchController,
                              label: l10n.searchByName,
                              icon: Icons.search_rounded,
                              screenSize: screenSize,
                              keyboardType: TextInputType.text,
                            ),

                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),

                            // Dynamic Dropdowns
                            Row(
                              children: [
                                // Education Level Dropdown
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: 'Nivel Educativo',
                                    value: _selectedGroup,
                                    items: availableNiveles,
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedGroup = value ?? 'all';
                                        // Reset group selection when education level changes
                                        _selectedGrade = 'all';
                                      });
                                      _filterStudents();
                                    },
                                    getLabel: (String value) =>
                                        value == 'all' ? l10n.all : value,
                                    screenSize: screenSize,
                                    backgroundColor:
                                        AppTheme.accentBlue.withOpacity(0.05),
                                  ),
                                ),

                                SizedBox(
                                    width:
                                        AppTheme.getMediumPadding(screenSize)),

                                // Group Dropdown (filtered by education level)
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: l10n.group,
                                    value: _selectedGrade,
                                    items: availableGroups,
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedGrade = value ?? 'all';
                                      });
                                      _filterStudents();
                                    },
                                    getLabel: (String value) =>
                                        value == 'all' ? l10n.all : value,
                                    screenSize: screenSize,
                                    backgroundColor:
                                        AppTheme.accentPurple.withOpacity(0.05),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                                height: AppTheme.getSmallPadding(screenSize)),

                            // Status and Turno Dropdowns
                            Row(
                              children: [
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: l10n.status,
                                    value: _selectedStatus,
                                    items: const ['all', 'active', 'inactive'],
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedStatus = value ?? 'all';
                                      });
                                      _filterStudents();
                                    },
                                    getLabel: (String value) {
                                      switch (value) {
                                        case 'all':
                                          return l10n.all;
                                        case 'active':
                                          return l10n.active;
                                        case 'inactive':
                                          return l10n.inactive;
                                        default:
                                          return value;
                                      }
                                    },
                                    screenSize: screenSize,
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.getMediumPadding(screenSize)),
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: l10n.shift,
                                    value: _selectedTurno,
                                    items: [
                                      'all',
                                      ...studentProvider
                                          .getAvailableTurnoNames()
                                    ],
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedTurno = value ?? 'all';
                                      });
                                      _filterStudents();
                                    },
                                    getLabel: (String value) =>
                                        value == 'all' ? l10n.all : value,
                                    screenSize: screenSize,
                                  ),
                                ),
                              ],
                            ),

                            // Results Summary
                            if (studentProvider.students.isNotEmpty) ...[
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              Container(
                                padding: EdgeInsets.all(
                                    AppTheme.getSmallPadding(screenSize)),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getSmallRadius(screenSize)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: AppTheme.accentBlue,
                                      size: screenSize.height * 0.02,
                                    ),
                                    SizedBox(
                                        width: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Expanded(
                                      child: Text(
                                        'Mostrando ${allStudents.length} de ${studentProvider.students.length} estudiantes',
                                        style:
                                            AppTheme.getCaptionSmall(screenSize)
                                                .copyWith(
                                          color: AppTheme.accentBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Students List Section
                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Students List
                      if (allStudents.isEmpty &&
                          studentProvider.students.isNotEmpty)
                        // No students match current filters
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                              AppTheme.getLargePadding(screenSize)),
                          decoration: BoxDecoration(
                            color: AppTheme.getCardColor(context),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getLargeRadius(screenSize)),
                            border: Border.all(
                                color: AppTheme.getBorderColor(context)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: screenSize.height * 0.08,
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              Text(
                                l10n.noStudentsFound,
                                style:
                                    AppTheme.getSubtitle1(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              Text(
                                l10n.tryAdjustingFilters,
                                style:
                                    AppTheme.getBodyMedium(screenSize).copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else if (allStudents.isEmpty &&
                          studentProvider.students.isEmpty)
                        // No students at all
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                              AppTheme.getLargePadding(screenSize)),
                          decoration: BoxDecoration(
                            color: AppTheme.getCardColor(context),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getLargeRadius(screenSize)),
                            border: Border.all(
                                color: AppTheme.getBorderColor(context)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.group_rounded,
                                size: screenSize.height * 0.08,
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              Text(
                                'No hay estudiantes registrados',
                                style:
                                    AppTheme.getSubtitle1(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              Text(
                                'Los estudiantes aparecerán aquí una vez que sean registrados',
                                style:
                                    AppTheme.getBodyMedium(screenSize).copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        // Show students list
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.getCardColor(context),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getLargeRadius(screenSize)),
                            border: Border.all(
                                color: AppTheme.getBorderColor(context)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Students list header
                              Padding(
                                padding: EdgeInsets.all(
                                    AppTheme.getMediumPadding(screenSize)),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.group_rounded,
                                      color: AppTheme.accentPurple,
                                      size: screenSize.height * 0.025,
                                    ),
                                    SizedBox(
                                        width: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Text(
                                      'Estudiantes Registrados',
                                      style: AppTheme.getSubtitle1(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppTheme.getSmallPadding(
                                            screenSize),
                                        vertical: AppTheme.getSmallPadding(
                                                screenSize) *
                                            0.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentPurple
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.getSmallRadius(
                                                screenSize)),
                                      ),
                                      child: Text(
                                        '${allStudents.length}',
                                        style: AppTheme.getCaption(screenSize)
                                            .copyWith(
                                          color: AppTheme.accentPurple,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Students list
                              ListView.separated(
                                padding: EdgeInsets.only(
                                  left: AppTheme.getMediumPadding(screenSize),
                                  right: AppTheme.getMediumPadding(screenSize),
                                  bottom: AppTheme.getMediumPadding(screenSize),
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: allStudents.length,
                                separatorBuilder: (context, index) => SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize),
                                ),
                                itemBuilder: (context, index) {
                                  final student = allStudents[index];
                                  return _buildStudentCard(
                                      context, student, screenSize, l10n);
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(
      BuildContext context, student, Size screenSize, l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentProfileAdminView(student: student),
            ),
          );
        },
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Student Avatar
              Container(
                width: screenSize.width * 0.12,
                height: screenSize.width * 0.12,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.width * 0.06,
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
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.3),
                    Text(
                      '${student.nivelEducativo} - ${student.grupo}',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    if (student.matricula.isNotEmpty) ...[
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        'Matrícula: ${student.matricula}',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: student.llaveActiva
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Text(
                      student.llaveActiva ? l10n.active : l10n.inactive,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: student.llaveActiva
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.025,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
