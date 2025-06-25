import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../views/admin/students/student_profile_admin_view.dart';

class AttendanceListSection extends StatefulWidget {
  final Size screenSize;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const AttendanceListSection({
    super.key,
    required this.screenSize,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<AttendanceListSection> createState() => _AttendanceListSectionState();
}

class _AttendanceListSectionState extends State<AttendanceListSection> {
  String _selectedFilter = 'all'; // all, present, late, absent
  TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'all';
  String _selectedShift = 'all';
  String _selectedAccessType = 'all';
  String _selectedStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notifications = _generateMockNotifications();
    final filteredNotifications = _filterNotifications(notifications);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: widget.screenSize.height * 0.015,
            offset: Offset(0, widget.screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          _buildSearchBar(),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          _buildFilterSection(),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          _buildEmptyState(context),
        ],
      ),
    );
  }

  List<Notificacion> _generateMockNotifications() {
    // Only show records for past dates or today
    if (widget.selectedDate.isAfter(DateTime.now())) {
      return [];
    }

    final l10n = AppLocalizations.of(context);

    return [
      Notificacion(
        id: 'notif_001',
        alumnoId: 'std_001',
        titulo: l10n.entryRegistered,
        mensaje: l10n.studentArrivalMessage('Ana García Martínez'),
        tipo: TipoNotificacion.entrada,
        fechaHora:
            widget.selectedDate.add(const Duration(hours: 7, minutes: 30)),
        datosAdicionales: {
          'alumnoNombre': 'Ana García Martínez',
          'alumnoGrado': '3°',
          'alumnoGrupo': 'A',
          'escaneadoPor': 'María López',
          'ubicacion': l10n.mainEntrance,
        },
      ),
      Notificacion(
        id: 'notif_002',
        alumnoId: 'std_002',
        titulo: l10n.lateArrival,
        mensaje:
            '${l10n.studentName} Carlos Rodríguez Silva ${l10n.arrivedAt} 8:00 AM',
        tipo: TipoNotificacion.retraso,
        fechaHora:
            widget.selectedDate.add(const Duration(hours: 8, minutes: 15)),
        datosAdicionales: {
          'alumnoNombre': 'Carlos Rodríguez Silva',
          'alumnoGrado': '2°',
          'alumnoGrupo': 'B',
          'escaneadoPor': 'Juan Hernández',
          'ubicacion': l10n.mainEntrance,
          'retraso_minutos': 15,
        },
      ),
      Notificacion(
        id: 'notif_003',
        alumnoId: 'std_003',
        titulo: l10n.entryRegistered,
        mensaje: l10n.studentArrivalMessage('Sofía González Pérez'),
        tipo: TipoNotificacion.entrada,
        fechaHora:
            widget.selectedDate.add(const Duration(hours: 7, minutes: 25)),
        datosAdicionales: {
          'alumnoNombre': 'Sofía González Pérez',
          'alumnoGrado': '1°',
          'alumnoGrupo': 'A',
          'escaneadoPor': 'María López',
          'ubicacion': l10n.mainEntrance,
        },
      ),
      Notificacion(
        id: 'notif_004',
        alumnoId: 'std_004',
        titulo: l10n.lateArrival,
        mensaje: l10n.studentLateArrivalMessage('Miguel Torres López'),
        tipo: TipoNotificacion.retraso,
        fechaHora:
            widget.selectedDate.add(const Duration(hours: 8, minutes: 10)),
        datosAdicionales: {
          'alumnoNombre': 'Miguel Torres López',
          'alumnoGrado': '3°',
          'alumnoGrupo': 'A',
          'escaneadoPor': 'Juan Hernández',
          'ubicacion': l10n.secondaryEntrance,
          'retraso_minutos': 10,
        },
      ),
      Notificacion(
        id: 'notif_005',
        alumnoId: 'std_005',
        titulo: l10n.entryRegistered,
        mensaje: l10n.studentArrivalMessage('Isabella Hernández Cruz'),
        tipo: TipoNotificacion.entrada,
        fechaHora:
            widget.selectedDate.add(const Duration(hours: 7, minutes: 35)),
        datosAdicionales: {
          'alumnoNombre': 'Isabella Hernández Cruz',
          'alumnoGrado': '2°',
          'alumnoGrupo': 'B',
          'escaneadoPor': 'María López',
          'ubicacion': l10n.mainEntrance,
        },
      ),
    ];
  }

  List<Notificacion> _filterNotifications(List<Notificacion> notifications) {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredBySearch = notifications.where((notification) {
      final studentName = notification.datosAdicionales?['alumnoNombre']
              ?.toString()
              .toLowerCase() ??
          '';
      return studentName.contains(searchQuery);
    }).toList();

    if (_selectedGroup != 'all') {
      filteredBySearch.removeWhere((notification) =>
          notification.datosAdicionales?['alumnoGrupo'] != _selectedGroup);
    }

    if (_selectedShift != 'all') {
      filteredBySearch.removeWhere((notification) =>
          notification.datosAdicionales?['turno'] != _selectedShift);
    }

    if (_selectedAccessType != 'all') {
      filteredBySearch.removeWhere((notification) =>
          notification.datosAdicionales?['tipoAcceso'] != _selectedAccessType);
    }

    if (_selectedStatus != 'all') {
      filteredBySearch.removeWhere((notification) {
        final status = _getStatusText(notification.tipo);
        return status != _selectedStatus;
      });
    }

    return filteredBySearch;
  }

  String _getStatusText(TipoNotificacion tipo) {
    final l10n = AppLocalizations.of(context);
    switch (tipo) {
      case TipoNotificacion.entrada:
        return l10n.present;
      case TipoNotificacion.retraso:
        return l10n.late;
      case TipoNotificacion.salida:
        return l10n.exit;
      case TipoNotificacion.ausencia:
        return l10n.absent;
      default:
        return l10n.present;
    }
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                  AppTheme.getSmallPadding(widget.screenSize) * 0.5),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize)),
              ),
              child: Icon(
                Icons.list_alt_rounded,
                color: AppTheme.successColor,
                size: widget.screenSize.height * 0.025,
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
            Text(
              l10n.attendanceList,
              style: AppTheme.getH2(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
        _DatePickerButton(
          selectedDate: widget.selectedDate,
          onDateChanged: widget.onDateChanged,
          screenSize: widget.screenSize,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(widget.screenSize),
        vertical: AppTheme.getSmallPadding(widget.screenSize),
      ),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppTheme.getTextSecondaryColor(context),
            size: widget.screenSize.width * 0.05,
          ),
          SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.done,
              style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              decoration: InputDecoration(
                hintText: l10n.searchStudent,
                hintStyle: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _filterNotifications(_generateMockNotifications());
                });
              },
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
            IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _filterNotifications(_generateMockNotifications());
                });
              },
              icon: Icon(
                Icons.clear_rounded,
                color: AppTheme.getTextSecondaryColor(context),
                size: widget.screenSize.width * 0.05,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'group',
                  _selectedGroup,
                  ['all', 'A', 'B', 'C'],
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
              Expanded(
                child: _buildFilterDropdown(
                  'shift',
                  _selectedShift,
                  ['all', l10n.morning, l10n.afternoon],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'access',
                  _selectedAccessType,
                  ['all', l10n.entry, l10n.exit],
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
              Expanded(
                child: _buildFilterDropdown(
                  'status',
                  _selectedStatus,
                  ['all', l10n.present, l10n.late, l10n.exit, l10n.absent],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notifications = _filterNotifications(_generateMockNotifications());

    if (notifications.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getBackgroundColor(context),
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(widget.screenSize)),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_2_rounded,
              size: widget.screenSize.width * 0.15,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
            Text(
              l10n.noStudentsScanned,
              style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.5),
            Text(
              l10n.startScanningToSeeRecords,
              style: AppTheme.getCaption(widget.screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          '${notifications.length} ${l10n.studentsFound}',
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        ...notifications.asMap().entries.map((entry) {
          final index = entry.key;
          final notification = entry.value;
          return _AttendanceListItem(
            notification: notification,
            screenSize: widget.screenSize,
            isLast: index == notifications.length - 1,
            l10n: l10n,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    final color = isSelected
        ? AppTheme.accentPurple
        : AppTheme.getTextSecondaryColor(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _filterNotifications(_generateMockNotifications());
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(widget.screenSize) * 0.75,
          vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(widget.screenSize) * 0.75),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: widget.screenSize.width * 0.035,
              color: color,
            ),
            SizedBox(width: widget.screenSize.width * 0.01),
            Text(
              label,
              style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getFilterLabel(label),
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
                  case 'group':
                    _selectedGroup = newValue!;
                    break;
                  case 'shift':
                    _selectedShift = newValue!;
                    break;
                  case 'access':
                    _selectedAccessType = newValue!;
                    break;
                  case 'status':
                    _selectedStatus = newValue!;
                    break;
                }
                _filterNotifications(_generateMockNotifications());
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
    return value == 'all' ? l10n.all : value;
  }

  String _getFilterLabel(String filterType) {
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
}

class _DatePickerButton extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final Size screenSize;

  const _DatePickerButton({
    required this.selectedDate,
    required this.onDateChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _showDatePicker(context, l10n),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
        ),
        decoration: BoxDecoration(
          color: AppTheme.accentBlue.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          border: Border.all(
            color: AppTheme.accentBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.accentBlue,
              size: screenSize.height * 0.02,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
            Text(
              l10n.dateFormat(selectedDate), // Provide the full DateTime object
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, AppLocalizations l10n) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.accentBlue,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      onDateChanged(date);
    }
  }
}

class _FilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Size screenSize;
  final AppLocalizations l10n;

  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {
        'value': 'all',
        'label': l10n.allStudents,
        'color': AppTheme.getTextSecondaryColor(context)
      },
      {
        'value': 'present',
        'label': l10n.present,
        'color': AppTheme.successColor
      },
      {'value': 'late', 'label': l10n.late, 'color': AppTheme.warningColor},
      {'value': 'absent', 'label': l10n.absent, 'color': AppTheme.errorColor},
    ];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter['value'];
        final color = filter['color'] as Color;

        return GestureDetector(
          onTap: () => onFilterChanged(filter['value'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              border: Border.all(
                color: color.withOpacity(isSelected ? 1.0 : 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              filter['label'] as String,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AttendanceListItem extends StatelessWidget {
  final Notificacion notification;
  final Size screenSize;
  final bool isLast;
  final AppLocalizations l10n;

  const _AttendanceListItem({
    required this.notification,
    required this.screenSize,
    required this.isLast,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(notification.tipo);
    final statusIcon = _getStatusIcon(notification.tipo);
    final timeString =
        l10n.timeFormat(notification.fechaHora); // Replaced time format
    final alumnoNombre = notification.datosAdicionales?['alumnoNombre'] ??
        l10n.student; // Replaced 'Estudiante'
    final alumnoGrado = notification.datosAdicionales?['alumnoGrado'] ?? '';
    final escaneadoPor =
        notification.datosAdicionales?['escaneadoPor'] ?? l10n.unknown;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToStudentProfile(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            child: Row(
              children: [
                Container(
                  width: screenSize.height * 0.04,
                  height: screenSize.height * 0.04,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: Colors.white,
                    size: screenSize.height * 0.02,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alumnoNombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.height * 0.003),
                      Row(
                        children: [
                          Text(
                            alumnoGrado,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                              width:
                                  AppTheme.getSmallPadding(screenSize) * 0.5),
                          Text(
                            '•',
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                          SizedBox(
                              width:
                                  AppTheme.getSmallPadding(screenSize) * 0.5),
                          Text(
                            escaneadoPor,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  timeString,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStudentProfile(BuildContext context) {
    // Remove mock student navigation since this is mock data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Esta es información de demostración'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
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
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getStatusIcon(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.entrada:
        return Icons.check_rounded;
      case TipoNotificacion.salida:
        return Icons.logout_rounded;
      case TipoNotificacion.retraso:
        return Icons.schedule_rounded;
      case TipoNotificacion.ausencia:
        return Icons.close_rounded;
      default:
        return Icons.check_rounded;
    }
  }
}
