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
          // Header with date picker and filter
          Row(
            children: [
              Expanded(
                child: Row(
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
                    SizedBox(
                        width: AppTheme.getSmallPadding(widget.screenSize)),
                    Text(
                      l10n.attendanceList,
                      style: AppTheme.getH2(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              _DatePickerButton(
                selectedDate: widget.selectedDate,
                onDateChanged: widget.onDateChanged,
                screenSize: widget.screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Filter chips
          _FilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            screenSize: widget.screenSize,
            l10n: l10n,
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Records count
          Text(
            '${filteredNotifications.length} ${l10n.studentsFound}',
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),

          // Attendance list
          if (filteredNotifications.isEmpty)
            _EmptyState(screenSize: widget.screenSize, l10n: l10n)
          else
            ...filteredNotifications.asMap().entries.map((entry) {
              final index = entry.key;
              final notification = entry.value;
              return _AttendanceListItem(
                notification: notification,
                screenSize: widget.screenSize,
                isLast: index == filteredNotifications.length - 1,
                l10n: l10n,
              );
            }),
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
          'alumnoGrado': '3°A',
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
          'alumnoGrado': '2°B',
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
          'alumnoGrado': '1°A',
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
          'alumnoGrado': '3°A',
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
          'alumnoGrado': '2°B',
          'alumnoGrupo': 'B',
          'escaneadoPor': 'María López',
          'ubicacion': l10n.mainEntrance,
        },
      ),
    ];
  }

  List<Notificacion> _filterNotifications(List<Notificacion> notifications) {
    switch (_selectedFilter) {
      case 'present':
        return notifications
            .where((n) =>
                n.tipo == TipoNotificacion.entrada && n.fechaHora.hour < 8)
            .toList();
      case 'late':
        return notifications
            .where((n) => n.tipo == TipoNotificacion.retraso)
            .toList();
      case 'absent':
        return notifications
            .where((n) => n.tipo == TipoNotificacion.ausencia)
            .toList();
      default:
        return notifications;
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
    final mockStudent = Alumno(
      id: notification.alumnoId,
      nombre: notification.datosAdicionales?['alumnoNombre'] ?? 'Estudiante',
      grupo: notification.datosAdicionales?['alumnoGrupo'] ?? 'A',
      id_escuela: 'school_001',
      id_llave: 'KEY${notification.alumnoId}',
      vinculado: true,
      matricula: 'MAT${notification.alumnoId}',
      fecha_registro: DateTime.now().subtract(const Duration(days: 30)),
      turno: Turno.matutino,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileAdminView(student: mockStudent),
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

class _EmptyState extends StatelessWidget {
  final Size screenSize;
  final AppLocalizations l10n;

  const _EmptyState({
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: screenSize.height * 0.06,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              l10n.noAttendanceRecords,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
