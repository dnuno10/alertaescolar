import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/group_provider.dart';
import '../../../managers/turno_provider.dart';
import '../../../managers/student_provider.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/admin/attendance/attendance_calendar.dart';
import '../../../components/admin/attendance/calendar_explanation_header.dart';
import '../students/student_profile_admin_view.dart';

class AttendanceCalendarView extends StatefulWidget {
  const AttendanceCalendarView({super.key});

  @override
  State<AttendanceCalendarView> createState() => _AttendanceCalendarViewState();
}

class _AttendanceCalendarViewState extends State<AttendanceCalendarView> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();

  // Filter controllers and state
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'all';
  String _selectedNivelEducativo = 'all';
  String _selectedTurno = 'all';
  String _selectedAccess = 'all'; // entrada, salida, retraso

  // Data lists
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _filteredNotifications = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterNotifications);

    // Load initial data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNotifications);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    final escuelaId = userProvider.currentUser?.escuelaId;
    if (escuelaId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all required data in parallel
      await Future.wait([
        groupProvider.loadGroups(escuelaId: escuelaId),
        turnoProvider.loadTurnos(escuelaId: escuelaId),
        studentProvider.loadStudents(escuelaId: escuelaId),
        _loadNotifications(escuelaId),
      ]);

      _filterNotifications();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotifications(String escuelaId) async {
    try {
      final supabase = Supabase.instance.client;

      // Query notifications with student data, ensuring only students from the same school
      final response = await supabase
          .from('notificaciones')
          .select('''
            *,
            alumnos!inner(
              id,
              nombre,
              matricula,
              id_grupo,
              id_turno,
              id_escuela,
              grupos!inner(
                grupo,
                nivel_educativo
              ),
              turnos!inner(
                turno
              )
            )
          ''')
          .eq('alumnos.id_escuela', escuelaId)
          .order('fecha_registro', ascending: false);

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(response);
      });

      debugPrint(
          'Loaded ${_notifications.length} notifications for school $escuelaId');
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      throw Exception('Error al cargar notificaciones: $e');
    }
  }

  void _filterNotifications() {
    if (!mounted) return;

    List<Map<String, dynamic>> filtered = List.from(_notifications);

    // Filter by search query (student name)
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((notification) {
        final studentName =
            notification['alumnos']['nombre']?.toString().toLowerCase() ?? '';
        return studentName.contains(query);
      }).toList();
    }

    // Filter by group
    if (_selectedGroup != 'all') {
      filtered = filtered.where((notification) {
        final grupo =
            notification['alumnos']['grupos']['grupo']?.toString() ?? '';
        return grupo == _selectedGroup;
      }).toList();
    }

    // Filter by nivel educativo
    if (_selectedNivelEducativo != 'all') {
      filtered = filtered.where((notification) {
        final nivelEducativo =
            notification['alumnos']['grupos']['nivel_educativo']?.toString() ??
                '';
        return nivelEducativo == _selectedNivelEducativo;
      }).toList();
    }

    // Filter by turno
    if (_selectedTurno != 'all') {
      filtered = filtered.where((notification) {
        final turno =
            notification['alumnos']['turnos']['turno']?.toString() ?? '';
        return turno == _selectedTurno;
      }).toList();
    }

    // Filter by access type (entrada, salida, retraso)
    if (_selectedAccess != 'all') {
      filtered = filtered.where((notification) {
        final tipoNotificacion =
            notification['tipo_notificacion']?.toString() ?? '';
        return tipoNotificacion == _selectedAccess;
      }).toList();
    }

    setState(() {
      _filteredNotifications = filtered;
    });
  }

  // Get notifications for a specific date
  List<Map<String, dynamic>> _getNotificationsForDate(DateTime date) {
    return _filteredNotifications.where((notification) {
      final fechaRegistro = DateTime.parse(notification['fecha_registro']);
      return fechaRegistro.year == date.year &&
          fechaRegistro.month == date.month &&
          fechaRegistro.day == date.day;
    }).toList();
  }

  Widget _buildFiltersSection(BuildContext context, Size screenSize,
      GroupProvider groupProvider, TurnoProvider turnoProvider) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
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
                Icons.filter_list_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Filtros de Asistencia',
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  'Limpiar',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          CustomInputField(
            controller: _searchController,
            label: 'Buscar por nombre del estudiante...',
            icon: Icons.search_rounded,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Filter dropdowns in row
          // Replace the Wrap widget with this structure for exactly 2 filters per row
          Column(
            children: [
              // First row: Group and Nivel Educativo
              Row(
                children: [
                  // Group filter
                  Expanded(
                    child: _buildDropdownFilter(
                      context,
                      screenSize,
                      'Grupo',
                      _selectedGroup,
                      [
                        'all',
                        ...groupProvider.grupos.map((g) => g.grupo).toSet()
                      ],
                      (value) => setState(() {
                        _selectedGroup = value;
                        _filterNotifications();
                      }),
                    ),
                  ),

                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),

                  // Nivel Educativo filter
                  Expanded(
                    child: _buildDropdownFilter(
                      context,
                      screenSize,
                      'Nivel Educativo',
                      _selectedNivelEducativo,
                      [
                        'all',
                        ...groupProvider.grupos
                            .map((g) => g.nivelEducativo)
                            .toSet()
                      ],
                      (value) => setState(() {
                        _selectedNivelEducativo = value;
                        _filterNotifications();
                      }),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.getSmallPadding(screenSize)),

              // Second row: Turno and Acceso
              Row(
                children: [
                  // Turno filter
                  Expanded(
                    child: _buildDropdownFilter(
                      context,
                      screenSize,
                      'Turno',
                      _selectedTurno,
                      [
                        'all',
                        ...turnoProvider.turnos.map((t) => t.turno).toSet()
                      ],
                      (value) => setState(() {
                        _selectedTurno = value;
                        _filterNotifications();
                      }),
                    ),
                  ),

                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),

                  // Access type filter
                  Expanded(
                    child: _buildDropdownFilter(
                      context,
                      screenSize,
                      'Acceso',
                      _selectedAccess,
                      ['all', 'entrada', 'salida', 'retraso'],
                      (value) => setState(() {
                        _selectedAccess = value;
                        _filterNotifications();
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Results summary
          if (_notifications.isNotEmpty) ...[
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.height * 0.02,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      'Mostrando ${_filteredNotifications.length} de ${_notifications.length} registros',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
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
    );
  }

  Widget _buildDropdownFilter(
    BuildContext context,
    Size screenSize,
    String label,
    String selectedValue,
    Iterable<String> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.getBorderColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentBlue,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize) * 0.8,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'all' ? 'Todos' : item,
                style: AppTheme.getCaptionSmall(screenSize),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateDetails(BuildContext context, Size screenSize) {
    final notificationsForDate = _getNotificationsForDate(selectedDate);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
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
                Icons.calendar_today_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Registros del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Notifications list
          if (notificationsForDate.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: screenSize.height * 0.05,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      'No hay registros para esta fecha',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...notificationsForDate.map((notification) {
              return _buildNotificationCard(context, screenSize, notification);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Size screenSize,
      Map<String, dynamic> notification) {
    final student = notification['alumnos'];
    final tipoNotificacion = notification['tipo_notificacion'] ?? '';
    final fechaRegistro = DateTime.parse(notification['fecha_registro']);

    Color typeColor;
    IconData typeIcon;
    String typeText;

    switch (tipoNotificacion) {
      case 'entrada':
        typeColor = AppTheme.successColor;
        typeIcon = Icons.login_rounded;
        typeText = 'Entrada';
        break;
      case 'salida':
        typeColor = AppTheme.errorColor;
        typeIcon = Icons.logout_rounded;
        typeText = 'Salida';
        break;
      case 'retraso':
        typeColor = AppTheme.warningColor;
        typeIcon = Icons.schedule_rounded;
        typeText = 'Retraso';
        break;
      default:
        typeColor = AppTheme.getTextSecondaryColor(context);
        typeIcon = Icons.notifications_rounded;
        typeText = tipoNotificacion;
    }

    return GestureDetector(
      onTap: () => _navigateToStudentProfile(context, student),
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: typeColor.withOpacity(0.05),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: typeColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Type indicator
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Icon(
                typeIcon,
                color: typeColor,
                size: screenSize.height * 0.025,
              ),
            ),

            SizedBox(width: AppTheme.getMediumPadding(screenSize)),

            // Student info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['nombre'] ?? 'N/A',
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                  Text(
                    '${student['grupos']['nivel_educativo']} - ${student['grupos']['grupo']}',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Time and type
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Text(
                    typeText,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  '${fechaRegistro.hour.toString().padLeft(2, '0')}:${fechaRegistro.minute.toString().padLeft(2, '0')}',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Arrow indicator to show it's clickable
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.025,
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedGroup = 'all';
      _selectedNivelEducativo = 'all';
      _selectedTurno = 'all';
      _selectedAccess = 'all';
      _searchController.clear();
    });
    _filterNotifications();
  }

  // Convert notification student data to StudentDetails for navigation
  StudentDetails _convertToStudentDetails(Map<String, dynamic> studentData) {
    return StudentDetails(
      id: studentData['id'] ?? '',
      nombre: studentData['nombre'] ?? '',
      matricula: studentData['matricula'] ?? '',
      escuelaId: studentData['id_escuela'] ?? '',
      grupoId: studentData['id_grupo'] ?? '',
      grupo: studentData['grupos']['grupo'] ?? '',
      nivelEducativo: studentData['grupos']['nivel_educativo'] ?? '',
      turnoId: studentData['id_turno'],
      turno: studentData['turnos']['turno'] ?? '',
      llaveActiva:
          true, // We assume student is active if they have notifications
      fechaRegistro: DateTime.parse(
          studentData['fecha_registro'] ?? DateTime.now().toIso8601String()),
      tutores: const [],
      familyContacts: const [],
    );
  }

  void _navigateToStudentProfile(
      BuildContext context, Map<String, dynamic> studentData) {
    final studentDetails = _convertToStudentDetails(studentData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileAdminView(student: studentDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer4<ThemeProvider, UserProvider, GroupProvider, TurnoProvider>(
      builder: (context, themeProvider, userProvider, groupProvider,
          turnoProvider, child) {
        // Show loading state
        if (_isLoading && _notifications.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error state
        if (_error != null && _notifications.isEmpty) {
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
                    _error!,
                    style: AppTheme.getBodyMedium(screenSize),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.attendanceCalendar),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar Header with explanation
                      CalendarExplanationHeader(screenSize: screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Filters Section
                      _buildFiltersSection(
                          context, screenSize, groupProvider, turnoProvider),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Attendance Calendar
                      AttendanceCalendar(
                        screenSize: screenSize,
                        selectedDay: selectedDate,
                        focusedDay: focusedDay,
                        notifications: _filteredNotifications,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            selectedDate = selectedDay;
                            this.focusedDay = focusedDay;
                          });
                        },
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Enhanced Date Details with notifications
                      _buildDateDetails(context, screenSize),
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
