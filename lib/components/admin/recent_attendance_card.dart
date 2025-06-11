import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../views/admin/attendance_calendar_view.dart';

class RecentAttendanceCard extends StatelessWidget {
  final Size screenSize;

  const RecentAttendanceCard({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Mock data for recent attendance notifications
    final recentNotifications = [
      Notificacion(
        id: 'notif_001',
        alumnoId: 'std_001',
        titulo: 'Entrada registrada',
        mensaje: 'Ana García Martínez ha llegado a la escuela a las 7:45 AM',
        tipo: TipoNotificacion.entrada,
        estado: EstadoNotificacion.nueva,
        fechaHora: DateTime.now().subtract(const Duration(minutes: 15)),
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
        mensaje: 'Carlos Rodríguez Silva llegó tarde a las 8:15 AM',
        tipo: TipoNotificacion.retraso,
        estado: EstadoNotificacion.nueva,
        fechaHora:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        datosAdicionales: {
          'alumnoNombre': 'Carlos Rodríguez Silva',
          'alumnoGrado': '2°B',
          'alumnoGrupo': 'B',
          'escaneadoPor': 'María López',
          'retraso_minutos': 15,
        },
      ),
      Notificacion(
        id: 'notif_003',
        alumnoId: 'std_003',
        titulo: 'Salida registrada',
        mensaje: 'Sofía González Pérez ha salido de la escuela a las 2:30 PM',
        tipo: TipoNotificacion.salida,
        estado: EstadoNotificacion.leida,
        fechaHora: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        datosAdicionales: {
          'alumnoNombre': 'Sofía González Pérez',
          'alumnoGrado': '1°A',
          'alumnoGrupo': 'A',
          'escaneadoPor': 'Juan Hernández',
          'ubicacion': 'Entrada Principal',
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentAttendance,
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceCalendarView(),
                ),
              ),
              child: Text(
                l10n.viewAll,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: screenSize.height * 0.015,
                offset: Offset(0, screenSize.height * 0.005),
              ),
            ],
          ),
          child: Column(
            children: [
              if (recentNotifications.isEmpty)
                _EmptyState(screenSize: screenSize, l10n: l10n)
              else
                ...recentNotifications.map((notification) => _AttendanceItem(
                      notification: notification,
                      screenSize: screenSize,
                      isLast: notification == recentNotifications.last,
                    )),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  final Notificacion notification;
  final Size screenSize;
  final bool isLast;

  const _AttendanceItem({
    required this.notification,
    required this.screenSize,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _getStatusColor(notification.tipo);
    final statusIcon = _getStatusIcon(notification.tipo);
    final timeAgo = _getTimeAgo(notification.fechaHora, l10n);
    final alumnoNombre =
        notification.datosAdicionales?['alumnoNombre'] ?? 'Estudiante';
    final alumnoGrado = notification.datosAdicionales?['alumnoGrado'] ?? '';
    final escaneadoPor =
        notification.datosAdicionales?['escaneadoPor'] ?? l10n.unknown;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: screenSize.width * 0.06,
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
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      timeAgo,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Text(
                        alumnoGrado,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: Text(
                        'Escaneado por: $escaneadoPor',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  String _getTimeAgo(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
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
            Icons.qr_code_scanner_rounded,
            size: screenSize.height * 0.08,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noAttendanceRecords,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.startScanningToSeeRecords ??
                'Comience a escanear para ver registros',
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
