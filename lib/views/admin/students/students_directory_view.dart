import 'package:alertaescolar/components/admin/directory/directory_filters_card.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';

import '../../../models/models.dart';

class StudentsDirectoryView extends StatefulWidget {
  const StudentsDirectoryView({super.key});

  @override
  State<StudentsDirectoryView> createState() => _StudentsDirectoryViewState();
}

class _StudentsDirectoryViewState extends State<StudentsDirectoryView> {
  final TextEditingController _searchController = TextEditingController();
  List<Alumno> _allStudents = [];
  List<Alumno> _filteredStudents = [];
  String _selectedGrade = 'all';
  String _selectedGroup = 'all';
  String _selectedStatus = 'all';
  bool _isLoading = true;

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
      // Mock students data
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
        id: '1',
        nombre: 'Ana García López',
        grado: '6° A',
        grupo: 'A',
        escuelaId: 'ESC001',
        llave: 'STU001',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Alumno(
        id: '2',
        nombre: 'Carlos Mendoza Ruiz',
        grado: '5° B',
        grupo: 'B',
        escuelaId: 'ESC001',
        llave: 'STU002',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Alumno(
        id: '3',
        nombre: 'María Fernández Castro',
        grado: '4° C',
        grupo: 'C',
        escuelaId: 'ESC001',
        llave: 'STU003',
        activo: false,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Alumno(
        id: '4',
        nombre: 'José Luis Herrera',
        grado: '6° A',
        grupo: 'A',
        escuelaId: 'ESC001',
        llave: 'STU004',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Alumno(
        id: '5',
        nombre: 'Sofia Rodriguez',
        grado: '3° B',
        grupo: 'B',
        escuelaId: 'ESC001',
        llave: 'STU005',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 10)),
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
              // Custom Directory Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        AppTheme.getSmallPadding(screenSize),
                    left: AppTheme.getMediumPadding(screenSize),
                    right: AppTheme.getMediumPadding(screenSize),
                    bottom: AppTheme.getLargePadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.studentsDirectory,
                                  style: AppTheme.getH1(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextPrimaryColor(context),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        AppTheme.getSmallPadding(screenSize) *
                                            0.5),
                                Text(
                                  'Gestiona y busca estudiantes de la escuela',
                                  style: AppTheme.getBodyMedium(screenSize)
                                      .copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filters
                      DirectoryFiltersCard(
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

  Widget _buildQuickStat(
      String title, String value, IconData icon, Color color, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: screenSize.height * 0.025,
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  height: 1.2,
                ),
              ),
              Text(
                value,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
