import 'package:alertaescolar/components/textfield/custom_input_field.dart';
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
import '../../../components/admin/attendance/calendar_explanation_header.dart';
import '../../../components/loading_dialog.dart';
import '../students/student_profile_admin_view.dart';
import '../../../utils/time_format.dart';
import '../../../utils/modern_dropdown.dart';

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

    // Show loading dialog
    LoadingDialog.show(context, message: 'Cargando datos de asistencia...');

    setState(() {
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

      await _filterNotifications();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      // Hide loading dialog
      if (mounted) {
        LoadingDialog.hide(context);
      }
    }
  }

  Future<void> _loadNotifications(String escuelaId) async {
    try {
      final supabase = Supabase.instance.client;

      // Query notifications with student data, ensuring only students from the same school
      // Only include attendance-related notifications (entrada, salida, retraso)
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
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso'])
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

  Future<void> _filterNotifications() async {
    if (!mounted) return;

    // Show loading dialog
    LoadingDialog.show(context, message: 'Filtrando registros...');

    try {
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
          final nivelEducativo = notification['alumnos']['grupos']
                      ['nivel_educativo']
                  ?.toString() ??
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

      // Filter by selected date
      filtered = filtered.where((notification) {
        final fechaRegistro = DateTime.parse(notification['fecha_registro']);
        return fechaRegistro.year == selectedDate.year &&
            fechaRegistro.month == selectedDate.month &&
            fechaRegistro.day == selectedDate.day;
      }).toList();

      setState(() {
        _filteredNotifications = filtered;
      });
    } finally {
      // Hide loading dialog
      if (mounted) {
        LoadingDialog.hide(context);
      }
    }
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
    final l10n = AppLocalizations.of(context);

    // Opciones dinámicas para los dropdowns
    final grupos = ['all', ...groupProvider.grupos.map((g) => g.grupo).toSet()];
    final niveles = [
      'all',
      ...groupProvider.grupos.map((g) => g.nivelEducativo).toSet()
    ];
    final turnos = ['all', ...turnoProvider.turnos.map((t) => t.turno).toSet()];
    final accessTypes = ['all', 'entrada', 'salida', 'retraso'];

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

          // Filtros con ModernDropdown
          Row(
            children: [
              Expanded(
                child: ModernDropdown<String>(
                  label: l10n.allGroups,
                  value: _selectedGroup,
                  items: grupos,
                  onChanged: (val) {
                    setState(() => _selectedGroup = val ?? 'all');
                    _filterNotifications();
                  },
                  getLabel: (v) => v == 'all' ? l10n.allGroups : v,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModernDropdown<String>(
                  label: l10n.educationalLevels,
                  value: _selectedNivelEducativo,
                  items: niveles,
                  onChanged: (val) {
                    setState(() => _selectedNivelEducativo = val ?? 'all');
                    _filterNotifications();
                  },
                  getLabel: (v) => v == 'all' ? l10n.all : v,
                  screenSize: screenSize,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ModernDropdown<String>(
                  label: l10n.shift,
                  value: _selectedTurno,
                  items: turnos,
                  onChanged: (val) {
                    setState(() => _selectedTurno = val ?? 'all');
                    _filterNotifications();
                  },
                  getLabel: (v) => v == 'all' ? l10n.all : v,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ModernDropdown<String>(
                  label: l10n.access,
                  value: _selectedAccess,
                  items: accessTypes,
                  onChanged: (val) {
                    setState(() => _selectedAccess = val ?? 'all');
                    _filterNotifications();
                  },
                  getLabel: (v) {
                    switch (v) {
                      case 'all':
                        return l10n.all;
                      case 'entrada':
                        return l10n.entryRegistered;
                      case 'salida':
                        return l10n.exitRegistered;
                      case 'retraso':
                        return l10n.lateArrival;
                      default:
                        return v;
                    }
                  },
                  screenSize: screenSize,
                ),
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
    final horaAmPm = TimeFormat.format24to12(
        '${fechaRegistro.hour.toString().padLeft(2, '0')}:${fechaRegistro.minute.toString().padLeft(2, '0')}');

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
                  horaAmPm,
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

  Future<void> _clearAllFilters() async {
    setState(() {
      _selectedGroup = 'all';
      _selectedNivelEducativo = 'all';
      _selectedTurno = 'all';
      _selectedAccess = 'all';
      _searchController.clear();
      // We don't reset the date because the date picker is now the main way to select date
    });
    await _filterNotifications();
  }

  // This method is no longer needed as we're using LoadingDialog instead
  // Keeping an empty block to preserve line numbers for easier debugging

  // Convert notification student data to StudentDetails for navigation
  Future<StudentDetails> _convertToStudentDetailsWithKeys(
      Map<String, dynamic> studentData) async {
    try {
      final supabase = Supabase.instance.client;

      // Query key information from llaves table
      final keyResponse = await supabase
          .from('llaves')
          .select('*')
          .eq('id_alumno', studentData['id'])
          .maybeSingle();

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
        llaveId: keyResponse?['id'],
        llaveCodigo: keyResponse?['codigo'],
        llaveActiva: keyResponse?['activo'] ?? false,
        fechaRegistro: DateTime.parse(
            studentData['fecha_registro'] ?? DateTime.now().toIso8601String()),
        fechaRegistroLlave: keyResponse?['fecha_registro'] != null
            ? DateTime.parse(keyResponse!['fecha_registro'])
            : null,
        fechaDesactivacionLlave: keyResponse?['fecha_desactivacion'] != null
            ? DateTime.parse(keyResponse!['fecha_desactivacion'])
            : null,
        limiteVinculacion: keyResponse?['limite_vinculacion'],
        tutores: const [],
        familyContacts: const [],
      );
    } catch (e) {
      debugPrint('Error loading key data: $e');
      // Fallback to basic student details without key info
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
        llaveActiva: false,
        fechaRegistro: DateTime.parse(
            studentData['fecha_registro'] ?? DateTime.now().toIso8601String()),
        tutores: const [],
        familyContacts: const [],
      );
    }
  }

  void _navigateToStudentProfile(
      BuildContext context, Map<String, dynamic> studentData) async {
    final studentDetails = await _convertToStudentDetailsWithKeys(studentData);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StudentProfileAdminView(student: studentDetails),
        ),
      );
    }
  }

  Widget _buildDateSelector(BuildContext context, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Asistencia',
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppTheme.accentPurple,
                      onPrimary: Colors.white,
                      surface: AppTheme.getCardColor(context),
                      onSurface: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
                focusedDay = picked;
              });
              await _filterNotifications();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.getSmallPadding(screenSize),
              horizontal: AppTheme.getMediumPadding(screenSize),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentPurple.withOpacity(0.1),
                  AppTheme.accentBlue.withOpacity(0.05),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize) * 0.6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.accentPurple,
                          size: screenSize.height * 0.02,
                        ),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.8),
                      Flexible(
                        child: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppTheme.accentPurple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final groupProvider = Provider.of<GroupProvider>(context);
    final turnoProvider = Provider.of<TurnoProvider>(context);

    // Opciones dinámicas para los dropdowns
    final grupos = ['all', ...groupProvider.grupos.map((g) => g.grupo).toSet()];
    final niveles = [
      'all',
      ...groupProvider.grupos.map((g) => g.nivelEducativo).toSet()
    ];
    final turnos = ['all', ...turnoProvider.turnos.map((t) => t.turno).toSet()];
    final accessTypes = ['all', 'entrada', 'salida', 'retraso'];

    return Consumer4<ThemeProvider, UserProvider, GroupProvider, TurnoProvider>(
      builder: (context, themeProvider, userProvider, groupProvider,
          turnoProvider, child) {
        // Show error state
        if (_error != null && _notifications.isEmpty) {
          // Make sure loading dialog is hidden in error case
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingDialog.hide(context);
          });

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

        // We don't show the loading state separately anymore because we use LoadingDialog

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

                      // Filters Section with Date Selector
                      _buildFiltersSection(
                          context, screenSize, groupProvider, turnoProvider),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Date Selector (Dialog Calendar)
                      _buildDateSelector(context, screenSize),

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
