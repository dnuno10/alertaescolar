import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/time_format.dart';

class NotificationDetailModal extends StatelessWidget {
  final Notificacion notification;
  final Size screenSize;

  const NotificationDetailModal({
    super.key,
    required this.notification,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Set icon and color based on notification type
    IconData icon = Icons.notifications_rounded;
    String status = l10n.notifications;
    Color statusColor = AppTheme.accentPurple;

    // Use the same icon and color logic as in NotificationsView
    final cleanType = notification.tipo
        .toString()
        .toLowerCase()
        .replaceAll('tiponotificacion.', '');
    switch (cleanType) {
      case 'entrada':
        icon = Icons.login_rounded;
        status = l10n.entryRegistered;
        statusColor = AppTheme.successColor;
        break;
      case 'salida':
        icon = Icons.logout_rounded;
        status = l10n.exitRegistered;
        statusColor = AppTheme.accentBlue;
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
      default:
        icon = Icons.info_outline_rounded;
        status = l10n.notifications;
        statusColor = AppTheme.accentBlue;
    }

    // Get student info from datosAdicionales
    final studentName =
        notification.datosAdicionales?['alumno_nombre'] ?? 'Estudiante';
    final studentGroup = notification.datosAdicionales?['alumno_grupo'] ?? '';
    final studentLevel =
        notification.datosAdicionales?['alumno_nivel_educativo'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
          topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
      ),
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Row(
            children: [
              Container(
                width: screenSize.height * 0.06,
                height: screenSize.height * 0.06,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(screenSize),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: screenSize.height * 0.035,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Text(
                  status,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.5),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.025,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Notification details
          _buildDetailRow(
            context,
            l10n.student,
            studentName,
            Icons.person_rounded,
            screenSize,
          ),

          _buildDetailRow(
            context,
            l10n.group,
            "$studentGroup - $studentLevel",
            Icons.group_rounded,
            screenSize,
          ),

          _buildDetailRow(
            context,
            l10n.date,
            _formatDate(notification.fechaHora),
            Icons.calendar_today_rounded,
            screenSize,
          ),

          _buildDetailRow(
            context,
            l10n.time,
            TimeFormat.format24to12(_formatTime(notification.fechaHora)),
            Icons.access_time_rounded,
            screenSize,
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Título (para todos los tipos de notificaciones)
          Text(
            l10n.title,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
              ),
            ),
            child: Text(
              notification.titulo,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Información específica de comunicados y permisos especiales
          if (notification.tipo == TipoNotificacion.comunicado) ...[
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Sección de metadatos del comunicado con mejor diseño
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context).withOpacity(0.7),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles del anuncio',
                    style: AppTheme.getSubtitle1(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                  // Tipo de comunicado
                  if (notification.datosAdicionales?['tipo_comunicado'] !=
                      null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: screenSize.height * 0.022,
                          color: AppTheme.accentPurple,
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.75),
                        Text(
                          'Tipo:',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppTheme.getSmallPadding(screenSize) * 1,
                            vertical:
                                AppTheme.getSmallPadding(screenSize) * 0.25,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _formatComunicadoType(notification
                                .datosAdicionales?['tipo_comunicado']),
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  ],

                  // Prioridad de comunicado
                  if (notification.datosAdicionales?['prioridad_comunicado'] !=
                      null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.priority_high_rounded,
                          size: screenSize.height * 0.022,
                          color: _getPriorityColor(notification
                              .datosAdicionales?['prioridad_comunicado']),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.75),
                        Text(
                          'Prioridad:',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppTheme.getSmallPadding(screenSize) * 1,
                            vertical:
                                AppTheme.getSmallPadding(screenSize) * 0.25,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification
                                .datosAdicionales?['prioridad_comunicado']),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _formatPrioridad(notification
                                .datosAdicionales?['prioridad_comunicado']),
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Message content
          Text(
            'Mensaje',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
              ),
            ),
            child: Text(
              notification.mensaje,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor:
                    Colors.white, // Siempre blanco para mejor contraste
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getMediumPadding(screenSize) * 0.75,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                ),
                textStyle: AppTheme.getSubtitle1(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // Garantizar color de texto blanco
                ),
              ),
              child: Text(
                l10n.close,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // Always white for contrast
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
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
        return 'Recordatorio de pago';
      case 'citatorio':
        return 'Citatorio';
      case 'informativo':
        return 'Informativo';
      case 'celebracion':
        return 'Celebración';
      case 'suspencionclases':
        return 'Suspensión de clases';
      case 'cambiohorario':
        return 'Cambio de horario';
      default:
        return tipo.replaceFirstMapped(
            tipo[0], (match) => match.group(0)!.toUpperCase());
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
        return prioridad.replaceFirstMapped(
            prioridad[0], (match) => match.group(0)!.toUpperCase());
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

  // Format a date string from the database
  String _formatDateFromString(String? dateString) {
    if (dateString == null) return '';
    try {
      final DateTime date = DateTime.parse(dateString);
      return _formatDate(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
}
