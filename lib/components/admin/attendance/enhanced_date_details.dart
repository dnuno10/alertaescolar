import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../views/admin/students/student_profile_admin_view.dart';

class EnhancedDateDetails extends StatefulWidget {
  final Size screenSize;
  final DateTime selectedDate;

  const EnhancedDateDetails({
    super.key,
    required this.screenSize,
    required this.selectedDate,
  });

  @override
  State<EnhancedDateDetails> createState() => _EnhancedDateDetailsState();
}

class _EnhancedDateDetailsState extends State<EnhancedDateDetails> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'all';
  String _selectedShift = 'all';
  String _selectedAccessType = 'all';
  String _selectedStatus = 'all';
  List<Notificacion> _allNotifications = [];
  List<Notificacion> _filteredNotifications = [];
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterNotifications);
    // We no longer call _loadAttendanceData() here to avoid localization issues
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load data once to avoid unnecessary rebuilds
    if (!_isDataLoaded) {
      _loadAttendanceData();
      _isDataLoaded = true;
    }
  }

  void _loadAttendanceData() {
    // Now we're safely in didChangeDependencies where it's ok to access localizations
    _allNotifications = _generateCompleteData();
    _filterNotifications();
  }

  // This empty mock method is fine since it doesn't use localizations
  List<Notificacion> _generateMockData() {
    // Only show records for past dates or today
    if (widget.selectedDate.isAfter(DateTime.now())) {
      return [];
    }
    return <Notificacion>[]; // Return empty list, real data comes from _generateCompleteData
  }

  List<Notificacion> _generateCompleteData() {
    // This is safe now since we're calling it from didChangeDependencies
    // Only show records for past dates or today
    if (widget.selectedDate.isAfter(DateTime.now())) {
      return [];
    }

    final l10n = AppLocalizations.of(context);
    final random = DateTime.now().millisecond;
    final studentCount =
        50 + (random % 200); // Random between 50-250 for better performance

    return List.generate(studentCount, (index) {
      final names = [
        'Ana García Martínez',
        'Carlos López Rodríguez',
        'María Rodríguez Silva',
        'José Martínez González',
        'Sofía González Pérez',
        'Miguel Torres López',
        'Isabella Hernández Cruz',
        'Diego Morales Jiménez',
        'Valentina Ruiz Vargas',
        'Sebastián Castro Mendoza'
      ];
      final lastNames = [
        'Ramírez',
        'Flores',
        'Rivera',
        'Moreno',
        'Ortega',
        'Delgado',
        'Aguilar',
        'Jiménez'
      ];
      final groups = ['A', 'B', 'C', 'D'];
      final shifts = ['Matutino', 'Vespertino'];
      final accessTypes = ['Entrada', 'Salida'];
      final tipos = [
        TipoNotificacion.entrada,
        TipoNotificacion.retraso,
        TipoNotificacion.salida
      ];

      final baseName = names[index % names.length];
      final lastName = lastNames[index % lastNames.length];
      final studentName =
          index < names.length ? baseName : '$baseName $lastName';
      final tipo = tipos[index % tipos.length];
      final grade = '${(index % 6) + 1}°';
      final group = groups[index % groups.length];

      return Notificacion(
        id: 'notif_${index.toString().padLeft(4, '0')}',
        alumnoId: 'std_${index.toString().padLeft(4, '0')}',
        titulo: _getTipoTitle(tipo),
        mensaje: _getTipoMessage(tipo, studentName),
        tipo: tipo,
        fechaHora: widget.selectedDate.add(Duration(
          hours: 7 + (index % 5),
          minutes: index % 60,
        )),
        datosAdicionales: {
          'alumnoNombre': studentName,
          'alumnoGrado': grade,
          'alumnoGrupo': group,
          'escaneadoPor': 'Admin ${(index % 3) + 1}',
          'turno': shifts[index % shifts.length],
          'tipoAcceso': accessTypes[index % accessTypes.length],
          'ubicacion':
              index % 2 == 0 ? l10n.mainEntrance : l10n.secondaryEntrance,
          'telefono': '555-${(1000 + index).toString().substring(1)}',
          'email':
              '${studentName.toLowerCase().replaceAll(' ', '.')}@escuela.edu',
        },
      );
    });
  }

  String _getTipoTitle(TipoNotificacion tipo) {
    final l10n = AppLocalizations.of(context)!;

    switch (tipo) {
      case TipoNotificacion.entrada:
        return l10n.entryRegistered;
      case TipoNotificacion.salida:
        return l10n.exitRegistered;
      case TipoNotificacion.retraso:
        return l10n.lateArrival;
      default:
        return l10n.notification;
    }
  }

  String _getTipoMessage(TipoNotificacion tipo, String studentName) {
    final l10n = AppLocalizations.of(context)!;

    switch (tipo) {
      case TipoNotificacion.entrada:
        return l10n.studentArrivalMessage(studentName);
      case TipoNotificacion.salida:
        return l10n.studentExitMessage(studentName);
      case TipoNotificacion.retraso:
        return l10n.studentLateMessage(studentName);
      default:
        return l10n.notificationForStudent(studentName);
    }
  }

  void _filterNotifications() {
    if (!mounted || _allNotifications.isEmpty) return;

    final query = _searchController.text.toLowerCase().trim();
    // We can safely access localizations here as this will be called after build
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _filteredNotifications = _allNotifications.where((notification) {
        final studentName =
            notification.datosAdicionales?['alumnoNombre'] ?? '';
        final studentId = notification.alumnoId;
        final grade = notification.datosAdicionales?['alumnoGrado'] ?? '';
        final group = notification.datosAdicionales?['alumnoGrupo'] ?? '';
        final shift = notification.datosAdicionales?['turno'] ?? '';
        final accessType = notification.datosAdicionales?['tipoAcceso'] ?? '';

        // Enhanced search - search in name, ID, grade+group
        final matchesSearch = query.isEmpty ||
            studentName.toLowerCase().contains(query) ||
            studentId.toLowerCase().contains(query) ||
            '$grade$group'.toLowerCase().contains(query) ||
            grade.toLowerCase().contains(query);

        final matchesGroup = _selectedGroup == 'all' || group == _selectedGroup;
        final matchesShift = _selectedShift == 'all' || shift == _selectedShift;
        final matchesAccessType =
            _selectedAccessType == 'all' || accessType == _selectedAccessType;
        final matchesStatus = _selectedStatus == 'all' ||
            _getStatusFromTipo(notification.tipo) == _selectedStatus;

        return matchesSearch &&
            matchesGroup &&
            matchesShift &&
            matchesAccessType &&
            matchesStatus;
      }).toList();

      // Sort by time (most recent first)
      _filteredNotifications.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    });
  }

  String _getStatusFromTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.entrada:
        return 'presente';
      case TipoNotificacion.retraso:
        return 'tarde';
      case TipoNotificacion.salida:
        return 'salida';
      case TipoNotificacion.ausencia:
        return 'ausente';
      default:
        return 'presente';
    }
  }

  void _navigateToStudentProfile(Notificacion notification) {
    final studentName =
        notification.datosAdicionales?['alumnoNombre'] ?? 'Estudiante';
    final grade = notification.datosAdicionales?['alumnoGrado'] ?? '';
    final group = notification.datosAdicionales?['alumnoGrupo'] ?? '';

    final mockStudent = Alumno(
      id: notification.alumnoId,
      nombre: studentName,
      grado: grade,
      grupo: group,
      escuelaId: 'school_001',
      llave: 'KEY${notification.alumnoId}',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
      tutoresIds: ['tutor_001'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileAdminView(student: mockStudent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final presentCount = _filteredNotifications
        .where((n) => n.tipo == TipoNotificacion.entrada)
        .length;
    final lateCount = _filteredNotifications
        .where((n) => n.tipo == TipoNotificacion.retraso)
        .length;
    final exitCount = _filteredNotifications
        .where((n) => n.tipo == TipoNotificacion.salida)
        .length;
    final totalScanned = _filteredNotifications.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Combined Filters and Students Section
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(
                AppTheme.getLargeRadius(widget.screenSize)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context).withValues(alpha: 0.1),
                blurRadius: widget.screenSize.height * 0.02,
                offset: Offset(0, widget.screenSize.height * 0.008),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters Header
              Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppTheme.accentPurple,
                    size: widget.screenSize.width * 0.06,
                  ),
                  SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                  Expanded(
                    child: Text(
                      l10n.searchFilters,
                      style: AppTheme.getH2(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_hasActiveFilters())
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.75,
                        vertical:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(widget.screenSize)),
                      ),
                      child: Text(
                        l10n.activeFilters,
                        style: AppTheme.getCaptionSmall(widget.screenSize)
                            .copyWith(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      l10n.clear,
                      style: AppTheme.getCaption(widget.screenSize).copyWith(
                        color: AppTheme.accentPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

              // Enhanced Search Bar using CustomInputField
              CustomInputField(
                controller: _searchController,
                label: l10n.searchStudent,
                screenSize: widget.screenSize,
                icon: Icons.search_rounded,
                keyboardType: TextInputType.text,
              ),

              SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

              // Filter Dropdowns in responsive layout
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Desktop/Tablet layout - 4 columns
                    return Row(
                      children: [
                        Expanded(
                            child: _buildFilterDropdown(l10n.group,
                                _selectedGroup, ['all', 'A', 'B', 'C', 'D'])),
                        SizedBox(
                            width: AppTheme.getSmallPadding(widget.screenSize)),
                        Expanded(
                            child: _buildFilterDropdown(
                                l10n.shift,
                                _selectedShift,
                                ['all', l10n.morning, l10n.afternoon])),
                        SizedBox(
                            width: AppTheme.getSmallPadding(widget.screenSize)),
                        Expanded(
                            child: _buildFilterDropdown(
                                l10n.access,
                                _selectedAccessType,
                                ['all', l10n.entry, l10n.exit])),
                        SizedBox(
                            width: AppTheme.getSmallPadding(widget.screenSize)),
                        Expanded(
                            child: _buildFilterDropdown(
                                l10n.status, _selectedStatus, [
                          'all',
                          'presente',
                          'tarde',
                          'salida',
                          'ausente'
                        ])),
                      ],
                    );
                  } else {
                    // Mobile layout - 2 columns
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: _buildFilterDropdown(
                                    l10n.group,
                                    _selectedGroup,
                                    ['all', 'A', 'B', 'C', 'D'])),
                            SizedBox(
                                width: AppTheme.getSmallPadding(
                                    widget.screenSize)),
                            Expanded(
                                child: _buildFilterDropdown(
                                    l10n.shift,
                                    _selectedShift,
                                    ['all', l10n.morning, l10n.afternoon])),
                          ],
                        ),
                        SizedBox(
                            height:
                                AppTheme.getSmallPadding(widget.screenSize)),
                        Row(
                          children: [
                            Expanded(
                                child: _buildFilterDropdown(
                                    l10n.access,
                                    _selectedAccessType,
                                    ['all', l10n.entry, l10n.exit])),
                            SizedBox(
                                width: AppTheme.getSmallPadding(
                                    widget.screenSize)),
                            Expanded(
                                child: _buildFilterDropdown(
                                    l10n.status, _selectedStatus, [
                              'all',
                              'presente',
                              'tarde',
                              'salida',
                              'ausente'
                            ])),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),

              // Estadísticas - Nueva ubicación
              Container(
                margin: EdgeInsets.only(
                  top: AppTheme.getMediumPadding(widget.screenSize),
                ),
                padding: EdgeInsets.all(
                    AppTheme.getMediumPadding(widget.screenSize)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.dateFormatFull(widget.selectedDate),
                              style: AppTheme.getBodyLarge(widget.screenSize)
                                  .copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.studentCount(totalScanned),
                              style: AppTheme.getCaptionSmall(widget.screenSize)
                                  .copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(widget.screenSize)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildCompactStat(
                            l10n.present, presentCount, AppTheme.successColor),
                        SizedBox(
                            width: AppTheme.getSmallPadding(widget.screenSize)),
                        _buildCompactStat(
                            l10n.late, lateCount, AppTheme.warningColor),
                        SizedBox(
                            width: AppTheme.getSmallPadding(widget.screenSize)),
                        _buildCompactStat(
                            l10n.exit, exitCount, AppTheme.accentBlue),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider between filters and students list
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: AppTheme.getLargePadding(widget.screenSize),
                ),
                height: 1,
                color: AppTheme.getBorderColor(context),
              ),

              // Students List Content
              if (_filteredNotifications.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredNotifications.length,
                  itemBuilder: (context, index) {
                    return _buildStudentItem(_filteredNotifications[index],
                        index == _filteredNotifications.length - 1);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStat(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(widget.screenSize) * 0.75,
        vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(widget.screenSize) * 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: widget.screenSize.height * 0.015,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(widget.screenSize) * 0.3),
          Text(
            value.toString(),
            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: widget.screenSize.height * 0.015,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
        _selectedGroup != 'all' ||
        _selectedShift != 'all' ||
        _selectedAccessType != 'all' ||
        _selectedStatus != 'all';
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.5),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (newValue) {
              setState(() {
                switch (label) {
                  case 'Grupo':
                    _selectedGroup = newValue!;
                    break;
                  case 'Turno':
                    _selectedShift = newValue!;
                    break;
                  case 'Acceso':
                    _selectedAccessType = newValue!;
                    break;
                  case 'Estado':
                    _selectedStatus = newValue!;
                    break;
                }
                _filterNotifications();
              });
            },
            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  _getDropdownLabel(item, label),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getDropdownLabel(String value, String filterType) {
    final l10n = AppLocalizations.of(context);

    switch (filterType) {
      case 'group':
        return l10n.group;
      case 'shift':
        return l10n.shift;
      case 'access':
        return l10n.access;
      case 'status':
        return l10n.status;
      default:
        return filterType;
    }
  }

  Widget _buildStudentItem(Notificacion notification, bool isLast) {
    final statusColor = _getStatusColor(notification.tipo);
    final statusIcon = _getStatusIcon(notification.tipo);
    final studentName =
        notification.datosAdicionales?['alumnoNombre'] ?? 'Estudiante';
    final grade = notification.datosAdicionales?['alumnoGrado'] ?? '';
    final group = notification.datosAdicionales?['alumnoGrupo'] ?? '';
    final accessType = notification.datosAdicionales?['tipoAcceso'] ?? '';
    final location = notification.datosAdicionales?['ubicacion'] ?? '';
    final accessColor =
        accessType == 'Entrada' ? AppTheme.successColor : AppTheme.warningColor;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(widget.screenSize),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToStudentProfile(notification),
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(widget.screenSize)),
          child: Container(
            padding:
                EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Row(
              children: [
                // Student Avatar
                Container(
                  width: widget.screenSize.width * 0.12,
                  height: widget.screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Center(
                    child: Text(
                      studentName.isNotEmpty
                          ? studentName[0].toUpperCase()
                          : 'E',
                      style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              studentName,
                              style: AppTheme.getBodyMedium(widget.screenSize)
                                  .copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${notification.fechaHora.hour.toString().padLeft(2, '0')}:${notification.fechaHora.minute.toString().padLeft(2, '0')}',
                            style: AppTheme.getCaptionSmall(widget.screenSize)
                                .copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(widget.screenSize) *
                              0.5),
                      Wrap(
                        spacing:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                        runSpacing:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.25,
                        children: [
                          _buildChip('$grade$group', AppTheme.accentBlue),
                          _buildChip(accessType, accessColor),
                          _buildChip(
                              _getStatusText(notification.tipo), statusColor),
                          if (location.isNotEmpty)
                            _buildChip(location,
                                AppTheme.getTextSecondaryColor(context)),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),

                // Navigation arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: widget.screenSize.height * 0.025,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: widget.screenSize.width * 0.15,
            color:
                AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Text(
            _hasActiveFilters()
                ? l10n.noStudentsFoundWithFilters
                : widget.selectedDate.isAfter(DateTime.now())
                    ? l10n.noDataForFutureDates
                    : l10n.noScanRecordsForDate,
            style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          Text(
            _hasActiveFilters()
                ? l10n.tryAdjustingFilters
                : l10n.studentsWillAppearWhenScanned,
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (_hasActiveFilters()) ...[
            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: Icon(
                Icons.clear_all_rounded,
                color: AppTheme.accentPurple,
                size: widget.screenSize.height * 0.02,
              ),
              label: Text(
                l10n.clearFilters,
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(widget.screenSize) * 0.6,
        vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
            AppTheme.getSmallRadius(widget.screenSize) * 0.6),
      ),
      child: Text(
        text,
        style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: widget.screenSize.height * 0.014,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedGroup = 'all';
      _selectedShift = 'all';
      _selectedAccessType = 'all';
      _selectedStatus = 'all';
      _filterNotifications();
    });
  }

  Color _getStatusColor(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.entrada:
        return AppTheme.successColor;
      case TipoNotificacion.salida:
        return AppTheme.accentBlue;
      case TipoNotificacion.retraso:
        return AppTheme.warningColor;
      case TipoNotificacion.ausencia:
        return AppTheme.errorColor;
      case TipoNotificacion.permisoEspecial:
        return AppTheme.accentPurple;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getStatusIcon(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.entrada:
        return Icons.check_circle_rounded;
      case TipoNotificacion.salida:
        return Icons.logout_rounded;
      case TipoNotificacion.retraso:
        return Icons.schedule_rounded;
      case TipoNotificacion.ausencia:
        return Icons.cancel_rounded;
      case TipoNotificacion.permisoEspecial:
        return Icons.verified_user_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _getStatusText(TipoNotificacion tipo) {
    final l10n = AppLocalizations.of(context)!;

    switch (tipo) {
      case TipoNotificacion.entrada:
        return l10n.present;
      case TipoNotificacion.salida:
        return l10n.exit;
      case TipoNotificacion.retraso:
        return l10n.late;
      case TipoNotificacion.ausencia:
        return l10n.absent;
      case TipoNotificacion.permisoEspecial:
        return l10n.justified;
      default:
        return l10n.notAvailable;
    }
  }
}
