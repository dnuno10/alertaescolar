import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/time_format.dart';

class NotificationDetailModal extends StatefulWidget {
  final Notificacion notification;
  final Size screenSize;

  const NotificationDetailModal({
    super.key,
    required this.notification,
    required this.screenSize,
  });

  @override
  State<NotificationDetailModal> createState() =>
      _NotificationDetailModalState();
}

class _NotificationDetailModalState extends State<NotificationDetailModal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Set icon and color based on notification type
    IconData icon = Icons.notifications_rounded;
    String status = l10n.notifications;
    Color statusColor = AppTheme.accentPurple;

    final cleanType = widget.notification.tipo
        .toString()
        .toLowerCase()
        .replaceAll('tiponotificacion.', '');

    // emergencia enviada como comunicado
    final isComunicadoEmergencia = cleanType == 'comunicado' &&
        (widget.notification.datosAdicionales?['tipo_comunicado']
                ?.toString()
                .toLowerCase() ==
            'emergencia');

    if (isComunicadoEmergencia) {
      icon = Icons.warning_rounded;
      status = 'Emergencia'; // usa l10n si existe la clave
      statusColor = AppTheme.errorColor;
    } else {
      switch (cleanType) {
        case 'entrada':
          icon = Icons.login_rounded;
          status = l10n.entryRegistered;
          statusColor = AppTheme.successColor; // ✅ verde
          break;
        case 'salida':
          icon = Icons.logout_rounded;
          status = l10n.exitRegistered;
          statusColor = AppTheme.errorColor; // ✅ rojo (antes azul)
          break;
        case 'retraso':
          icon = Icons.schedule_rounded;
          status = l10n.arrivedLate;
          statusColor = AppTheme.warningColor;
          break;
        case 'ausencia':
          icon = Icons.cancel_rounded;
          status = l10n.absent;
          statusColor = AppTheme.errorColor;
          break;
        case 'permisoespecial':
          icon = Icons.event_available_rounded;
          status = l10n.specialPermission;
          statusColor = AppTheme.accentPurple;
          break;
        case 'comunicado':
          icon = Icons.announcement_rounded;
          status = l10n.announcement;
          statusColor = AppTheme.accentPurple;
          break;
        case 'emergency':
          icon = Icons.warning_rounded;
          status = 'Emergencia';
          statusColor = AppTheme.errorColor;
          break;
        default:
          icon = Icons.info_outline_rounded;
          status = l10n.notifications;
          statusColor = AppTheme.accentBlue;
      }
    }

    // Datos del alumno desde datosAdicionales (mapeados en NotificationProvider)
    final studentName =
        (widget.notification.datosAdicionales?['alumno_nombre'] ?? 'Estudiante')
            .toString();
    final studentGroup =
        (widget.notification.datosAdicionales?['alumno_grupo'] ?? '')
            .toString();
    final studentLevel =
        (widget.notification.datosAdicionales?['alumno_nivel_educativo'] ?? '')
            .toString();
    final studentMatricula =
        (widget.notification.datosAdicionales?['alumno_matricula'] ?? '')
            .toString();
    final studentTurno =
        (widget.notification.datosAdicionales?['alumno_turno'] ?? '')
            .toString();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.getLargeRadius(widget.screenSize)),
          topRight: Radius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        ),
      ),
      padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header with close button
          Row(
            children: [
              Container(
                width: widget.screenSize.height * 0.06,
                height: widget.screenSize.height * 0.06,
                child: Icon(
                  icon,
                  color: statusColor,
                  size: widget.screenSize.height * 0.035,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: AppTheme.getH2(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(widget.notification.fechaHora),
                      style: AppTheme.getCaption(widget.screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: widget.screenSize.height * 0.025,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CÁPSULAS (primero) - Información específica de comunicados
                  if (widget.notification.tipo ==
                      TipoNotificacion.comunicado) ...[
                    // Fila de cápsulas (tipo, prioridad, destinatarios)
                    Wrap(
                      spacing:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.6,
                      runSpacing:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.4,
                      children: [
                        // Cápsula de tipo de comunicado
                        if (widget.notification
                                .datosAdicionales?['tipo_comunicado'] !=
                            null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  AppTheme.getSmallPadding(widget.screenSize) *
                                      0.8,
                              vertical:
                                  AppTheme.getSmallPadding(widget.screenSize) *
                                      0.4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPurple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatComunicadoType(
                                widget.notification
                                    .datosAdicionales?['tipo_comunicado'],
                              ),
                              style: AppTheme.getCaption(widget.screenSize)
                                  .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        // Cápsula de prioridad
                        if (widget.notification
                                .datosAdicionales?['prioridad_comunicado'] !=
                            null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  AppTheme.getSmallPadding(widget.screenSize) *
                                      0.8,
                              vertical:
                                  AppTheme.getSmallPadding(widget.screenSize) *
                                      0.4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                widget.notification
                                    .datosAdicionales?['prioridad_comunicado'],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatPrioridad(
                                widget.notification
                                    .datosAdicionales?['prioridad_comunicado'],
                              ),
                              style: AppTheme.getCaption(widget.screenSize)
                                  .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(
                        height: AppTheme.getMediumPadding(widget.screenSize)),
                  ],

                  // 2. DETALLES DEL ESTUDIANTE (segundo)
                  _buildDetailRow(
                    context,
                    l10n.student,
                    studentName,
                    Icons.person_rounded,
                    widget.screenSize,
                  ),

                  _buildDetailRow(
                    context,
                    l10n.group,
                    '$studentGroup - $studentLevel',
                    Icons.group_rounded,
                    widget.screenSize,
                  ),

                  if (studentMatricula.isNotEmpty)
                    _buildDetailRow(
                      context,
                      'Matrícula',
                      studentMatricula,
                      Icons.badge_rounded,
                      widget.screenSize,
                    ),

                  if (studentTurno.isNotEmpty)
                    _buildDetailRow(
                      context,
                      l10n.shift,
                      studentTurno,
                      Icons.school_rounded,
                      widget.screenSize,
                    ),

                  _buildDetailRow(
                    context,
                    l10n.date,
                    _formatDate(widget.notification.fechaHora),
                    Icons.calendar_today_rounded,
                    widget.screenSize,
                  ),

                  _buildDetailRow(
                    context,
                    l10n.time,
                    TimeFormat.format24to12(
                        _formatTime(widget.notification.fechaHora)),
                    Icons.access_time_rounded,
                    widget.screenSize,
                  ),

                  SizedBox(
                      height: AppTheme.getMediumPadding(widget.screenSize)),

                  // 3. TÍTULO (tercero)
                  Text(
                    l10n.title,
                    style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(
                      height:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.5),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        AppTheme.getMediumPadding(widget.screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(widget.screenSize)),
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                      ),
                    ),
                    child: Text(
                      widget.notification.titulo,
                      style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(
                      height: AppTheme.getMediumPadding(widget.screenSize)),

                  // 4. MENSAJE (último)
                  Text(
                    'Mensaje',
                    style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(
                      height:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.5),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        AppTheme.getMediumPadding(widget.screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(widget.screenSize)),
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                      ),
                    ),
                    child: Text(
                      widget.notification.mensaje,
                      style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                  ),

                  SizedBox(
                      height: AppTheme.getMediumPadding(widget.screenSize)),
                ],
              ),
            ),
          ),

          // Botón de acción (fijo)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getMediumPadding(widget.screenSize) * 0.75,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(widget.screenSize)),
                ),
                textStyle: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              child: Text(
                l10n.close,
                style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Size screenSize,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
      child: Row(
        children: [
          Icon(
            icon,
            size: screenSize.height * 0.022,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.75),
          Text(
            '$label: ',
            style: AppTheme.getSubtitle2(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTheme.getSubtitle2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    // Convertir a zona horaria local para mostrar la fecha correcta
    final localDateTime = dateTime.toLocal();
    return '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    // Convertir a zona horaria local para mostrar la hora correcta
    final localDateTime = dateTime.toLocal();
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        final m = difference.inMinutes;
        return m <= 0 ? 'Ahora' : '${m}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${localDateTime.day}/${localDateTime.month}';
    }
  }

  String _formatComunicadoType(String? tipoValue) {
    if (tipoValue == null) return 'Informativo';

    final tipo = tipoValue.toLowerCase();
    switch (tipo) {
      case 'emergencia':
        return 'Emergencia';
      case 'paseo':
        return 'Paseo escolar';
      case 'evento':
        return 'Evento';
      case 'recordatoriopago':
      case 'recordatorio_pago':
        return 'Recordatorio de pago';
      case 'citatorio':
        return 'Citatorio';
      case 'informativo':
        return 'Informativo';
      case 'celebracion':
        return 'Celebración';
      case 'suspencionclases': // Versión mal escrita por compatibilidad
      case 'suspencion_clases': // Versión mal escrita con guión bajo
      case 'suspension_clases': // Versión corregida
        return 'Suspensión de clases';
      case 'cambiohorario':
      case 'cambio_horario':
        return 'Cambio de horario';
      default:
        if (tipo.isEmpty) return 'Informativo';
        return tipo[0].toUpperCase() + tipo.substring(1);
    }
  }

  String _formatPrioridad(String? prioridadValue) {
    if (prioridadValue == null) return 'Normal';

    final prioridad = prioridadValue.toLowerCase();
    switch (prioridad) {
      case 'baja':
        return 'Baja';
      case 'media':
        return 'Media';
      case 'alta':
        return 'Alta';
      case 'critica':
        return 'Crítica';
      default:
        if (prioridad.isEmpty) return 'Normal';
        return prioridad[0].toUpperCase() + prioridad.substring(1);
    }
  }

  Color _getPriorityColor(String? prioridadValue) {
    if (prioridadValue == null) return AppTheme.accentBlue;

    final prioridad = prioridadValue.toLowerCase();
    switch (prioridad) {
      case 'baja':
        return Colors.green;
      case 'media':
        return AppTheme.accentBlue;
      case 'alta':
        return AppTheme.warningColor;
      case 'critica':
        return AppTheme.errorColor;
      default:
        return AppTheme.accentPurple;
    }
  }
}
