import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../models/models.dart';
import '../../../components/admin/students/selectable_directory_filters_card.dart';

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
              NavHeader(title: l10n.selectStudent),

              // Filters and Students List
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: SelectableDirectoryFiltersCard(
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
