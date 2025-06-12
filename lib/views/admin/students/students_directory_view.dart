import 'package:alertaescolar/components/admin/directory/directory_filters_card.dart';
import 'package:alertaescolar/components/admin/directory/directory_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/utils/mock_student_generator.dart';
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
      // Get mock students using the utility class
      final students = MockStudentGenerator.getMockStudents();
      setState(() {
        _allStudents = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
}
