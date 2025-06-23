import 'package:alertaescolar/components/notifications/empty_notifications_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/notification_provider.dart';
import '../../../models/models.dart';
import 'notification_card.dart';

class RecentNotificationsSection extends StatelessWidget {
  final Size screenSize;
  final VoidCallback onTapSeeAll;
  final List<Notificacion> notifications;
  final Function(String)? onNotificationTap;

  const RecentNotificationsSection({
    super.key,
    required this.screenSize,
    required this.onTapSeeAll,
    required this.notifications,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recentNotifications = notifications.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y botón
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.recentNotifications,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                final unreadCount = provider.unreadCount;
                final showBadge = unreadCount > 0;

                return GestureDetector(
                  onTap: onTapSeeAll,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: showBadge
                          ? AppTheme.warningColor
                          : AppTheme.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        showBadge
                            ? AppTheme.getMediumRadius(screenSize)
                            : AppTheme.getSmallRadius(screenSize),
                      ),
                      boxShadow: showBadge
                          ? [
                              BoxShadow(
                                color: AppTheme.warningColor.withOpacity(0.25),
                                blurRadius: screenSize.height * 0.008,
                                offset: Offset(0, screenSize.height * 0.003),
                              )
                            ]
                          : [],
                    ),
                    child: showBadge
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: screenSize.height * 0.008,
                                height: screenSize.height * 0.008,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize) *
                                      0.5),
                              Text(
                                '$unreadCount ${l10n.newNotifications}',
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            l10n.viewAll,
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.accentPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Lista de notificaciones
        SizedBox(
          height: screenSize.height * 0.2,
          child: Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final recentNotifications =
                  provider.notifications.take(5).toList();

              if (recentNotifications.isEmpty) {
                return EmptyNotificationsCard(screenSize: screenSize);
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: recentNotifications.length,
                itemBuilder: (context, index) {
                  final notification = recentNotifications[index];
                  final studentName =
                      notification.datosAdicionales?['alumno_nombre'] ??
                          'Estudiante';
                  final studentGroup =
                      notification.datosAdicionales?['alumno_grupo'] ?? '';

                  return NotificationCard(
                    notification: notification,
                    index: index,
                    screenSize: screenSize,
                    onTap: () {
                      if (onNotificationTap != null) {
                        onNotificationTap!(notification.id);
                      } else {
                        onTapSeeAll();
                      }
                    },
                    subtitle: '$studentName - $studentGroup',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
