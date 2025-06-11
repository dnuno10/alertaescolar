import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../views/admin/student_profile_admin_view.dart';

class SelectedDateDetails extends StatelessWidget {
  final Size screenSize;
  final DateTime selectedDate;

  const SelectedDateDetails({
    super.key,
    required this.screenSize,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notifications = _generateMockNotifications();
    final dateString =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.accentBlue,
              size: screenSize.height * 0.025,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Text(
              '${l10n.attendanceFor ?? 'Asistencia para'} $dateString',
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Summary stats
        if (notifications.isNotEmpty) ...[
          _DateSummaryStats(
            notifications: notifications,
            screenSize: screenSize,
            l10n: l10n,
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
        ],

        // Students list
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: screenSize.height * 0.01,
                offset: Offset(0, screenSize.height * 0.003),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notifications.isEmpty
                    ? (l10n.noAttendanceRecords)
                    : '${l10n.scannedStudents} (${notifications.length})',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (notifications.isEmpty) ...[
                SizedBox(height: AppTheme.getLargePadding(screenSize)),
                _EmptyState(screenSize: screenSize, l10n: l10n),
              ] else ...[
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                ...notifications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final notification = entry.value;
                  return _StudentAttendanceItem(
                    notification: notification,
                    screenSize: screenSize,
                    isLast: index == notifications.length - 1,
                    l10n: l10n,
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Notificacion> _generateMockNotifications() {
    // Only show records for past dates or today
    if (selectedDate.isAfter(DateTime.now())) {
      return [];
    }

    return [
      Notificacion(
        id: 'notif_001',
        alumnoId: 'std_001',
        titulo: 'Entrada registrada',
        mensaje: 'Ana García Martínez ha llegado a la escuela',
        tipo: TipoNotificacion.entrada,
        fechaHora: selectedDate.add(const Duration(hours: 7, minutes: 30)),
        datosAdicionales: {
          'alumnoNombre': 'Ana García Martínez',
          'alumnoGrado': '3°A',
          'alumnoGrupo': 'A',
          'escaneadoPor': 'María López',
          'ubicacion': 'Entrada Principal',
        },
      ),
      Notificacion(
        id: 'notif_002',
        alumnoId: 'std_002',
        titulo: 'Llegada tardía',
        mensaje: 'Carlos Rodríguez Silva llegó tarde',
        tipo: TipoNotificacion.retraso,
        fechaHora: selectedDate.add(const Duration(hours: 7, minutes: 45)),
        datosAdicionales: {
          'alumnoNombre': 'Carlos Rodríguez Silva',
          'alumnoGrado': '2°B',
          'alumnoGrupo': 'B',
          'escaneadoPor': 'Juan Hernández',
          'ubicacion': 'Entrada Principal',
          'retraso_minutos': 15,
        },
      ),
      Notificacion(
        id: 'notif_003',
        alumnoId: 'std_003',
        titulo: 'Entrada registrada',
        mensaje: 'Sofía González Pérez ha llegado a la escuela',
        tipo: TipoNotificacion.entrada,
        fechaHora: selectedDate.add(const Duration(hours: 7, minutes: 25)),
        datosAdicionales: {
          'alumnoNombre': 'Sofía González Pérez',
          'alumnoGrado': '1°A',
          'alumnoGrupo': 'A',
          'escaneadoPor': 'María López',
          'ubicacion': 'Entrada Principal',
        },
      ),
      Notificacion(
        id: 'notif_004',
        alumnoId: 'std_004',
        titulo: 'Llegada tardía',
        mensaje: 'Miguel Torres López llegó tarde',
        tipo: TipoNotificacion.retraso,
        fechaHora: selectedDate.add(const Duration(hours: 8, minutes: 10)),
        datosAdicionales: {
          'alumnoNombre': 'Miguel Torres López',
          'alumnoGrado': '3°A',
          'alumnoGrupo': 'A',
          'escaneadoPor': 'Juan Hernández',
          'ubicacion': 'Entrada Secundaria',
          'retraso_minutos': 10,
        },
      ),
      Notificacion(
        id: 'notif_005',
        alumnoId: 'std_005',
        titulo: 'Entrada registrada',
        mensaje: 'Isabella Hernández Cruz ha llegado a la escuela',
        tipo: TipoNotificacion.entrada,
        fechaHora: selectedDate.add(const Duration(hours: 7, minutes: 35)),
        datosAdicionales: {
          'alumnoNombre': 'Isabella Hernández Cruz',
          'alumnoGrado': '2°B',
          'alumnoGrupo': 'B',
          'escaneadoPor': 'María López',
          'ubicacion': 'Entrada Principal',
        },
      ),
    ];
  }
}

class _DateSummaryStats extends StatelessWidget {
  final List<Notificacion> notifications;
  final Size screenSize;
  final AppLocalizations l10n;

  const _DateSummaryStats({
    required this.notifications,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final presentCount =
        notifications.where((n) => n.tipo == TipoNotificacion.entrada).length;
    final lateCount =
        notifications.where((n) => n.tipo == TipoNotificacion.retraso).length;
    final totalScanned = notifications.length;

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.01,
            offset: Offset(0, screenSize.height * 0.003),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.qr_code_scanner_rounded,
              color: AppTheme.accentBlue,
              value: totalScanned.toString(),
              label: l10n.totalScanned,
              screenSize: screenSize,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: _StatItem(
              icon: Icons.check_circle_rounded,
              color: AppTheme.successColor,
              value: presentCount.toString(),
              label: l10n.presentStudents,
              screenSize: screenSize,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: _StatItem(
              icon: Icons.schedule_rounded,
              color: AppTheme.warningColor,
              value: lateCount.toString(),
              label: l10n.lateStudents,
              screenSize: screenSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final Size screenSize;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: screenSize.height * 0.03,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            value,
            style: AppTheme.getH2(screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StudentAttendanceItem extends StatelessWidget {
  final Notificacion notification;
  final Size screenSize;
  final bool isLast;
  final AppLocalizations l10n;

  const _StudentAttendanceItem({
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
        '${notification.fechaHora.hour.toString().padLeft(2, '0')}:${notification.fechaHora.minute.toString().padLeft(2, '0')}';
    final alumnoNombre =
        notification.datosAdicionales?['alumnoNombre'] ?? 'Estudiante';
    final alumnoGrado = notification.datosAdicionales?['alumnoGrado'] ?? '';
    final escaneadoPor =
        notification.datosAdicionales?['escaneadoPor'] ?? l10n.unknown;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
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
                  width: screenSize.height * 0.05,
                  height: screenSize.height * 0.05,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alumnoNombre,
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeString,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  AppTheme.getSmallPadding(screenSize) * 0.75,
                              vertical: screenSize.height * 0.003,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getSmallRadius(screenSize) * 0.5),
                            ),
                            child: Text(
                              alumnoGrado,
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.accentBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                              width:
                                  AppTheme.getSmallPadding(screenSize) * 0.5),
                          Expanded(
                            child: Text(
                              '${l10n.scannedBy}: $escaneadoPor',
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.025,
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
      grado: notification.datosAdicionales?['alumnoGrado'] ?? '',
      grupo: notification.datosAdicionales?['alumnoGrupo'] ?? '',
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
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: screenSize.height * 0.06,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noStudentsScanned ?? 'No hay estudiantes escaneados',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.noAttendanceThisDate ??
                'No se registró asistencia en esta fecha',
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
