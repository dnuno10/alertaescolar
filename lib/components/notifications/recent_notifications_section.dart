import 'package:alertaescolar/components/notifications/empty_notifications_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/notification_provider.dart';
import 'notification_card.dart';

class RecentNotificationsSection extends StatelessWidget {
  final Size screenSize;
  final VoidCallback onTapSeeAll;
  final Function(String)? onNotificationTap;

  const RecentNotificationsSection({
    super.key,
    required this.screenSize,
    required this.onTapSeeAll,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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

            // Badge "Ver todo" optimizado: solo escucha unreadCount
            Selector<NotificationProvider, int>(
              selector: (_, p) => p.unreadCount,
              builder: (context, unreadCount, _) {
                final showBadge = unreadCount > 0;

                return GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    if (showBadge) {
                      await context
                          .read<NotificationProvider>()
                          .markAllAsRead();
                    }
                    onTapSeeAll();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: showBadge
                          ? AppTheme.warningColor
                          // ignore: deprecated_member_use
                          : AppTheme.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        showBadge
                            ? AppTheme.getMediumRadius(screenSize)
                            : AppTheme.getSmallRadius(screenSize),
                      ),
                      boxShadow: showBadge
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
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
                                decoration: BoxDecoration(
                                  color: AppTheme.getBackgroundColor(context),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                width:
                                    AppTheme.getSmallPadding(screenSize) * 0.5,
                              ),
                              Text(
                                '$unreadCount ${l10n.newNotifications}',
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: AppTheme.getBackgroundColor(context),
                                  fontWeight: FontWeight.bold,
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

        // Lista de notificaciones (solo escucha top-5 e isLoading)
        SizedBox(
          height: screenSize.height * 0.2,
          child: Selector<NotificationProvider,
              ({bool loading, List notifications})>(
            selector: (_, p) => (
              loading: p.isLoading,
              notifications: p.getRecentNotifications(limit: 5),
            ),
            builder: (context, data, _) {
              // ⬇️ Mostrar CircularProgressIndicator mientras no hayan cargado
              if (data.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                );
              }

              final recentNotifications = data.notifications;
              if (recentNotifications.isEmpty) {
                return EmptyNotificationsCard(
                  screenSize: screenSize,
                  onRefresh: () =>
                      context.read<NotificationProvider>().loadNotifications(),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: recentNotifications.length,
                itemBuilder: (context, index) {
                  final notification = recentNotifications[index];
                  final studentName =
                      (notification.datosAdicionales?['alumno_nombre'] ??
                              'Estudiante')
                          .toString();
                  final studentGroup =
                      (notification.datosAdicionales?['alumno_grupo'] ?? '')
                          .toString();

                  return NotificationCard(
                    notification: notification,
                    index: index,
                    screenSize: screenSize,
                    onTap: () {
                      final cb = onNotificationTap;
                      if (cb != null) {
                        cb(notification.id);
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
