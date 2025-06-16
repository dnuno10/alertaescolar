import 'package:alertaescolar/components/admin/directory/directory_filters_card.dart';
import 'package:alertaescolar/components/admin/directory/directory_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';

class StudentsDirectoryView extends StatefulWidget {
  const StudentsDirectoryView({super.key});

  @override
  State<StudentsDirectoryView> createState() => _StudentsDirectoryViewState();
}

class _StudentsDirectoryViewState extends State<StudentsDirectoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGrade = 'all';
  String _selectedGroup = 'all';
  String _selectedStatus = 'all';
  String _selectedTurno = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);

    // Load students after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    // Get the current user's school ID
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final escuelaId = userProvider.currentUser?.escuelaId;

    debugPrint('Loading students for escuelaId: $escuelaId');

    if (escuelaId != null) {
      await studentProvider.loadStudents(escuelaId: escuelaId);
    } else {
      // Fallback: try to load students without school filter (this might not work depending on your database structure)
      debugPrint('No escuelaId found for current user, using fallback');
      await studentProvider.loadStudents(escuelaId: 'ESC001');
    }

    // Apply current filters after loading
    _filterStudents();

    debugPrint(
        'After load and filter - Students loaded: ${studentProvider.students.length}');
    debugPrint(
        'After load and filter - Filtered students: ${studentProvider.filteredStudents.length}');
    if (studentProvider.error != null) {
      debugPrint('Error loading students: ${studentProvider.error}');
    }
  }

  void _filterStudents() {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    studentProvider.filterStudents(
      searchQuery: _searchController.text,
      grado: _selectedGrade,
      grupo: _selectedGroup,
      status: _selectedStatus,
      turno: _selectedTurno,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer3<ThemeProvider, StudentProvider, UserProvider>(
      builder: (context, themeProvider, studentProvider, userProvider, child) {
        final allStudents = studentProvider.getAlumnosFromStudents();

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
                    onPressed: _loadStudents,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

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
                        totalStudents: studentProvider.students.length,
                        filteredStudents: allStudents.length,
                        students: allStudents,
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
