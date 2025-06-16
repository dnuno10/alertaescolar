import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';

class NotificationCard extends StatelessWidget {
  final Notificacion notification;
  final int index;
  final Size screenSize;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.index,
    required this.screenSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
      AppTheme.accentYellow
    ];
    final color = colors[index % colors.length];
    final isUnread = notification.estado != EstadoNotificacion.leida;

    IconData icon;
    String status;
    Color statusColor;

    switch (notification.tipo) {
      case TipoNotificacion.entrada:
        icon = Icons.login_rounded;
        status = l10n.entryRegistered;
        statusColor = AppTheme.successColor;
        break;
      case TipoNotificacion.salida:
        icon = Icons.logout_rounded;
        status = l10n.exitRegistered;
        statusColor = AppTheme.accentBlue;
        break;
      case TipoNotificacion.retraso:
        icon = Icons.schedule_rounded;
        status = l10n.arrivedLate;
        statusColor = AppTheme.warningColor;
        break;
      case TipoNotificacion.ausencia:
        icon = Icons.cancel_rounded;
        status = l10n.absent;
        statusColor = AppTheme.errorColor;
        break;
      case TipoNotificacion.permisoEspecial:
        icon = Icons.event_available_rounded;
        status = l10n.specialPermission;
        statusColor = AppTheme.accentPurple;
        break;

      case TipoNotificacion.comunicado:
        icon = Icons.announcement_rounded;
        status = l10n.announcement;
        statusColor = AppTheme.accentBlue;
        break;
      default:
        icon = Icons.notifications_rounded;
        status = l10n.notifications;
        statusColor = color;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenSize.width * 0.75,
        margin: EdgeInsets.only(right: AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
          border: Border.all(
            color: isUnread ? statusColor : AppTheme.getBorderColor(context),
            width: isUnread ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? statusColor.withOpacity(0.12)
                  : AppTheme.getShadowColor(context),
              blurRadius: isUnread
                  ? screenSize.height * 0.015
                  : screenSize.height * 0.01,
              offset: Offset(0, screenSize.height * 0.004),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con ícono
              Row(
                children: [
                  Container(
                    width: screenSize.height * 0.05,
                    height: screenSize.height * 0.05,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: screenSize.height * 0.025,
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.height * 0.008,
                            vertical: screenSize.height * 0.003,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                screenSize.height * 0.008),
                          ),
                          child: Text(
                            status,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.003),
                        Text(
                          _formatTime(notification.fechaHora, context),
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: screenSize.height * 0.008,
                      height: screenSize.height * 0.008,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  notification.mensaje,
                  style: AppTheme.getSubtitle2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: screenSize.height * 0.015,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  SizedBox(width: screenSize.height * 0.005),
                  Flexible(
                    child: Text(
                      l10n.tapToViewDetails,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
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
      ),
    );
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final l10n = AppLocalizations.of(context); // Added l10n instance

    if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes); // Replaced hardcoded text
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours); // Replaced hardcoded text
    } else {
      return l10n.daysAgo(difference.inDays); // Replaced hardcoded text
    }
  }
}
