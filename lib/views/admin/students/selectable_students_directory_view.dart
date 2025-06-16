import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
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
  String _selectedGrade = 'all';
  String _selectedGroup = 'all';
  String _selectedStatus = 'all';
  String _selectedTurno = 'all';

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
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    // TODO: Get escuelaId from user session or arguments
    final escuelaId = widget.arguments?['escuelaId'] ?? 'ESC001';

    await studentProvider.loadStudents(escuelaId: escuelaId);
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

  void _selectStudent(StudentDetails student) {
    if (widget.selectionMode) {
      // Convert Alumno to the expected format for notifications
      final selectedStudentData = {
        'id': student.id,
        'name': student.nombre,
        'grade': student.grupo,
        'section': student.grupo,
        'active': student.llaveActiva,
        'llave': student.llaveId ?? '',
        'escuelaId': student.escuelaId,
        'matricula': student.matricula,
      };

      Navigator.pop(context, selectedStudentData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, StudentProvider>(
      builder: (context, themeProvider, studentProvider, child) {
        final allStudents = studentProvider.filteredStudents;
        final filteredStudents = allStudents;

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
                    totalStudents: allStudents.length,
                    filteredStudents: filteredStudents.length,
                    students: filteredStudents,
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
                        _selectedTurno = 'all';
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
