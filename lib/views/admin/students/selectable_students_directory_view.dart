import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/group_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../utils/modern_dropdown.dart';

class SelectableStudentsDirectoryView extends StatefulWidget {
  final bool selectionMode;
  final bool allowMultiSelect;
  final Map<String, dynamic>? arguments;

  const SelectableStudentsDirectoryView({
    super.key,
    this.selectionMode = true,
    this.allowMultiSelect = false,
    this.arguments,
  });

  @override
  State<SelectableStudentsDirectoryView> createState() =>
      _SelectableStudentsDirectoryViewState();
}

class _SelectableStudentsDirectoryViewState
    extends State<SelectableStudentsDirectoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGrade = 'all'; // grupo
  String _selectedGroup = 'all'; // nivel_educativo
  String _selectedStatus = 'all';
  String _selectedTurno = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);

    // Load initial data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Get escuelaId from user session or arguments
    final escuelaId = userProvider.currentUser?.escuelaId ??
        widget.arguments?['escuelaId'] ??
        'ESC001';

    try {
      // Load both students and groups in parallel
      await Future.wait([
        studentProvider.loadStudents(escuelaId: escuelaId),
        groupProvider.loadGroups(escuelaId: escuelaId),
      ]);

      if (mounted) {
        _filterStudents();
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  void _filterStudents() {
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

  void _selectStudent(StudentDetails student) {
    if (widget.selectionMode) {
      // Convert StudentDetails to the expected format for notifications
      final l10n = AppLocalizations.of(context);
      final selectedStudentData = {
        'id': student.id,
        'name': student.nombre,
        'group': student.grupo,
        'nivelEducativo': student.nivelEducativo,
        'matricula': student.matricula,
        'active': student.llaveActiva,
        'keyCode': student.llaveCodigo ?? '',
        'keyId': student.llaveId ?? '',
        'escuelaId': student.escuelaId,
        'turno': student.turno ?? '',
        'turnoId': student.turnoId ?? '',
        // Additional information for display
        'status': student.llaveActiva ? l10n.active : l10n.inactive,
        'statusColor': student.llaveActiva ? 'active' : 'inactive',
      };

      Navigator.pop(context, selectedStudentData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer3<ThemeProvider, StudentProvider, GroupProvider>(
      builder: (context, themeProvider, studentProvider, groupProvider, child) {
        final allStudents = studentProvider.filteredStudents;
        final filteredStudents = allStudents;

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
              NavHeader(title: l10n.selectStudent),

              // Enhanced Filters and Students List
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Container(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getLargeRadius(screenSize)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.getShadowColor(context)
                              .withValues(alpha: 0.1),
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
                              Icons.person_search_rounded,
                              color: AppTheme.accentBlue,
                              size: screenSize.width * 0.06,
                            ),
                            SizedBox(
                                width: AppTheme.getMediumPadding(screenSize)),
                            Expanded(
                              child: Text(
                                'Seleccionar Estudiante',
                                style: AppTheme.getH2(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
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
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: AppTheme.accentBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                        // Search Field
                        CustomInputField(
                          controller: _searchController,
                          label: l10n.searchByName,
                          icon: Icons.search_rounded,
                          screenSize: screenSize,
                          keyboardType: TextInputType.text,
                        ),

                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

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
                                    AppTheme.accentBlue.withValues(alpha: 0.05),
                              ),
                            ),

                            SizedBox(
                                width: AppTheme.getMediumPadding(screenSize)),

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
                                backgroundColor: AppTheme.accentPurple
                                    .withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        // Status Dropdown
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
                                width: AppTheme.getMediumPadding(screenSize)),

                            // Empty space to maintain layout
                            const Expanded(child: SizedBox()),
                          ],
                        ),

                        // Results Summary
                        if (studentProvider.students.isNotEmpty) ...[
                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),
                          Container(
                            padding: EdgeInsets.all(
                                AppTheme.getSmallPadding(screenSize)),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withValues(alpha: 0.1),
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
                                    width:
                                        AppTheme.getSmallPadding(screenSize)),
                                Expanded(
                                  child: Text(
                                    'Mostrando ${filteredStudents.length} de ${studentProvider.students.length} estudiantes',
                                    style: AppTheme.getCaptionSmall(screenSize)
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

                        // Students List
                        if (filteredStudents.isNotEmpty) ...[
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),
                          Text(
                            'Estudiantes Disponibles',
                            style: AppTheme.getSubtitle1(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),
                          ...filteredStudents.map((student) {
                            return Container(
                              margin: EdgeInsets.only(
                                  bottom: AppTheme.getSmallPadding(screenSize)),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getMediumRadius(screenSize)),
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    _selectStudent(student);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        AppTheme.getMediumPadding(screenSize)),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.getBorderColor(context)
                                            .withValues(alpha: 0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.getMediumRadius(screenSize)),
                                    ),
                                    child: Row(
                                      children: [
                                        // Student Avatar
                                        Container(
                                          width: screenSize.width * 0.12,
                                          height: screenSize.width * 0.12,
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentBlue
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                                AppTheme.getSmallRadius(
                                                    screenSize)),
                                          ),
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: AppTheme.accentBlue,
                                            size: screenSize.width * 0.06,
                                          ),
                                        ),

                                        SizedBox(
                                            width: AppTheme.getMediumPadding(
                                                screenSize)),

                                        // Student Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.nombre,
                                                style: AppTheme.getBodyMedium(
                                                        screenSize)
                                                    .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme
                                                      .getTextPrimaryColor(
                                                          context),
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      AppTheme.getSmallPadding(
                                                              screenSize) *
                                                          0.3),
                                              Text(
                                                '${student.nivelEducativo} - ${student.grupo}',
                                                style: AppTheme.getCaption(
                                                        screenSize)
                                                    .copyWith(
                                                  color: AppTheme
                                                      .getTextSecondaryColor(
                                                          context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Status and Arrow
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    AppTheme.getSmallPadding(
                                                        screenSize),
                                                vertical:
                                                    AppTheme.getSmallPadding(
                                                            screenSize) *
                                                        0.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: student.llaveActiva
                                                    ? AppTheme.successColor
                                                        .withValues(alpha: 0.1)
                                                    : AppTheme.errorColor
                                                        .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppTheme.getSmallRadius(
                                                            screenSize)),
                                              ),
                                              child: Text(
                                                student.llaveActiva
                                                    ? l10n.active
                                                    : l10n.inactive,
                                                style: AppTheme.getCaptionSmall(
                                                        screenSize)
                                                    .copyWith(
                                                  color: student.llaveActiva
                                                      ? AppTheme.successColor
                                                      : AppTheme.errorColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    AppTheme.getSmallPadding(
                                                            screenSize) *
                                                        0.3),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: AppTheme
                                                  .getTextSecondaryColor(
                                                      context),
                                              size: screenSize.height * 0.025,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ] else ...[
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_search_rounded,
                                  size: screenSize.height * 0.08,
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                ),
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                Text(
                                  'No se encontraron estudiantes',
                                  style: AppTheme.getBodyMedium(screenSize)
                                      .copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
