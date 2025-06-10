import 'package:flutter/material.dart';
import '../models/models.dart';
import '../app/app_theme.dart';
import 'custom_card.dart';

class NotificationCard extends StatelessWidget {
  final Notificacion notification;
  final String? studentName;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDismiss;

  const NotificationCard({
    super.key,
    required this.notification,
    this.studentName,
    this.onTap,
    this.onMarkAsRead,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = notification.estado == EstadoNotificacion.nueva;

    return CustomCard(
      onTap: onTap,
      color:
          isUnread ? theme.colorScheme.primaryContainer.withOpacity(0.3) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con tipo de notificación y tiempo
          Row(
            children: [
              // Ícono de tipo de notificación
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _getNotificationColor(notification.tipo).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AppTheme.getNotificationIcon(notification.tipo.name),
                  size: 20,
                  color: _getNotificationColor(notification.tipo),
                ),
              ),

              const SizedBox(width: 12),

              // Título y tiempo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTime(notification.fechaHora),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Estado no leído
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Mensaje
          Text(
            notification.mensaje,
            style: theme.textTheme.bodyMedium,
          ),

          // Nombre del estudiante si se proporciona
          if (studentName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  studentName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          // Acciones
          if (isUnread && onMarkAsRead != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onMarkAsRead,
                child: const Text('Marcar como leída'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getNotificationColor(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.entrada:
        return AppTheme.successColor;
      case TipoNotificacion.salida:
        return AppTheme.infoColor;
      case TipoNotificacion.retraso:
        return AppTheme.warningColor;
      case TipoNotificacion.ausencia:
        return AppTheme.errorColor;
      case TipoNotificacion.permisoEspecial:
        return AppTheme.infoColor;
      case TipoNotificacion.alerta:
        return AppTheme.errorColor;
      case TipoNotificacion.comunicado:
        return AppTheme.primaryColor;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
