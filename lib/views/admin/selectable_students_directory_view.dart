import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../../components/admin/directory_filters_card.dart';
import '../../models/models.dart';

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
  List<Alumno> _allStudents = [];
  List<Alumno> _filteredStudents = [];
  String _selectedGrade = 'all';
  String _selectedGroup = 'all';
  String _selectedStatus = 'all';
  bool _isLoading = true;
  Alumno? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = _getMockStudents();
      setState(() {
        _allStudents = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Alumno> _getMockStudents() {
    return [
      Alumno(
        id: 'STU001',
        nombre: 'Ana García López',
        grado: '6°',
        grupo: 'A',
        escuelaId: 'ESC001',
        llave: 'STU001',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Alumno(
        id: 'STU002',
        nombre: 'Carlos Mendoza Ruiz',
        grado: '5°',
        grupo: 'B',
        escuelaId: 'ESC001',
        llave: 'STU002',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Alumno(
        id: 'STU003',
        nombre: 'María Fernández Castro',
        grado: '4°',
        grupo: 'C',
        escuelaId: 'ESC001',
        llave: 'STU003',
        activo: false,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Alumno(
        id: 'STU004',
        nombre: 'José Luis Herrera',
        grado: '6°',
        grupo: 'A',
        escuelaId: 'ESC001',
        llave: 'STU004',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Alumno(
        id: 'STU005',
        nombre: 'Sofia Rodriguez',
        grado: '3°',
        grupo: 'B',
        escuelaId: 'ESC001',
        llave: 'STU005',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Alumno(
        id: 'STU006',
        nombre: 'Miguel Torres Silva',
        grado: '5°',
        grupo: 'A',
        escuelaId: 'ESC001',
        llave: 'STU006',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Alumno(
        id: 'STU007',
        nombre: 'Laura Jiménez Cruz',
        grado: '4°',
        grupo: 'B',
        escuelaId: 'ESC001',
        llave: 'STU007',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Alumno(
        id: 'STU008',
        nombre: 'Diego Morales Vega',
        grado: '6°',
        grupo: 'C',
        escuelaId: 'ESC001',
        llave: 'STU008',
        activo: false,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 50)),
      ),
    ];
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final matchesSearch = student.nombre.toLowerCase().contains(query) ||
            student.id.toLowerCase().contains(query);

        final matchesGrade =
            _selectedGrade == 'all' || student.grado.contains(_selectedGrade);

        final matchesGroup =
            _selectedGroup == 'all' || student.grupo == _selectedGroup;

        final matchesStatus = _selectedStatus == 'all' ||
            (_selectedStatus == 'active' && student.activo) ||
            (_selectedStatus == 'inactive' && !student.activo);

        return matchesSearch && matchesGrade && matchesGroup && matchesStatus;
      }).toList();
    });
  }

  void _selectStudent(Alumno student) {
    if (widget.selectionMode) {
      // Convert Alumno to the expected format for notifications
      final selectedStudentData = {
        'id': student.id,
        'name': student.nombre,
        'grade': student.grado.replaceAll('°', 'to'),
        'section': student.grupo,
        'active': student.activo,
        'llave': student.llave,
        'escuelaId': student.escuelaId,
      };

      Navigator.pop(context, selectedStudentData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: 'Seleccionar Estudiante'),

              // Filters and Students List
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: _SelectableDirectoryFiltersCard(
                    screenSize: screenSize,
                    selectedGrade: _selectedGrade,
                    selectedGroup: _selectedGroup,
                    selectedStatus: _selectedStatus,
                    searchController: _searchController,
                    totalStudents: _allStudents.length,
                    filteredStudents: _filteredStudents.length,
                    students: _filteredStudents,
                    onGradeChanged: (value) {
                      setState(() => _selectedGrade = value);
                      _filterStudents();
                    },
                    onGroupChanged: (value) {
                      setState(() => _selectedGroup = value);
                      _filterStudents();
                    },
                    onStatusChanged: (value) {
                      setState(() => _selectedStatus = value);
                      _filterStudents();
                    },
                    onClearFilters: () {
                      setState(() {
                        _selectedGrade = 'all';
                        _selectedGroup = 'all';
                        _selectedStatus = 'all';
                        _searchController.clear();
                      });
                      _filterStudents();
                    },
                    onStudentSelected: _selectStudent,
                    selectionMode: widget.selectionMode,
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

// Custom selectable version of DirectoryFiltersCard
class _SelectableDirectoryFiltersCard extends StatelessWidget {
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

  const _SelectableDirectoryFiltersCard({
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
                  'Buscar Estudiante',
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
                    'Filtros activos',
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
                  'Limpiar',
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
            label: 'Buscar por nombre o ID',
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
                        child: _buildFilterDropdown(
                            'Grado',
                            selectedGrade,
                            ['all', '1°', '2°', '3°', '4°', '5°', '6°'],
                            context)),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                        child: _buildFilterDropdown('Grupo', selectedGroup,
                            ['all', 'A', 'B', 'C', 'D'], context)),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                        child: _buildFilterDropdown('Estado', selectedStatus,
                            ['all', 'active', 'inactive'], context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildFilterDropdown(
                                'Grado',
                                selectedGrade,
                                ['all', '1°', '2°', '3°', '4°', '5°', '6°'],
                                context)),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Expanded(
                            child: _buildFilterDropdown('Grupo', selectedGroup,
                                ['all', 'A', 'B', 'C', 'D'], context)),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    _buildFilterDropdown('Estado', selectedStatus,
                        ['all', 'active', 'inactive'], context),
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
                        'Estudiantes encontrados',
                        style: AppTheme.getBodyLarge(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$filteredStudents de $totalStudents estudiantes',
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
            _buildEmptyState(context)
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return _buildSelectableStudentItem(
                  context,
                  students[index],
                  index == students.length - 1,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSelectableStudentItem(
      BuildContext context, Alumno student, bool isLast) {
    final statusColor =
        student.activo ? AppTheme.successColor : AppTheme.errorColor;
    final gradeGroup = '${student.grado}${student.grupo}';

    return Container(
      margin: EdgeInsets.only(
          bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize)),
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
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Wrap(
                        spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
                        children: [
                          _buildChip(gradeGroup, AppTheme.accentBlue),
                          _buildChip(student.activo ? 'Activo' : 'Inactivo',
                              statusColor),
                          _buildChip('ID: ${student.id}',
                              AppTheme.getTextSecondaryColor(context)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.touch_app_rounded,
                    color: AppTheme.accentOrange,
                    size: screenSize.height * 0.025,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: screenSize.width * 0.15,
            color:
                AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'No se encontraron estudiantes',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Intenta ajustar los filtros de búsqueda',
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  Widget _buildFilterDropdown(
      String label, String value, List<String> items, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (newValue) {
              switch (label) {
                case 'Grado':
                  onGradeChanged(newValue!);
                  break;
                case 'Grupo':
                  onGroupChanged(newValue!);
                  break;
                case 'Estado':
                  onStatusChanged(newValue!);
                  break;
              }
            },
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(_getDropdownLabel(item, label),
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getDropdownLabel(String value, String filterType) {
    if (value == 'all') {
      switch (filterType) {
        case 'Grado':
          return 'Todos los grados';
        case 'Grupo':
          return 'Todos los grupos';
        case 'Estado':
          return 'Todos los estados';
        default:
          return 'Todos';
      }
    }

    if (filterType == 'Estado') {
      switch (value) {
        case 'active':
          return 'Activos';
        case 'inactive':
          return 'Inactivos';
        default:
          return value;
      }
    }

    return value;
  }
}
