import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/notification_provider.dart';

class NotificationsListSection extends StatelessWidget {
  final Size screenSize;
  final List<dynamic> Function(List<dynamic>) getFilteredNotifications;
  final Map<String, List<dynamic>> Function(List<dynamic>) groupNotifications;
  final String Function(String) formatDateHeader;
  final String Function(DateTime) formatDateTime;
  final Map<String, dynamic> Function(String) getNotificationType;
  final void Function(String) onNotificationTap;

  const NotificationsListSection({
    super.key,
    required this.screenSize,
    required this.getFilteredNotifications,
    required this.groupNotifications,
    required this.formatDateHeader,
    required this.formatDateTime,
    required this.getNotificationType,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getLargePadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize),
      ),
      sliver: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return SliverToBoxAdapter(
              child: Container(
                height: screenSize.height * 0.25,
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentPurple,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }

          final filteredNotifications =
              getFilteredNotifications(provider.notifications);

          if (filteredNotifications.isEmpty) {
            return SliverToBoxAdapter(
              child: _buildEmptyState(context),
            );
          }

          final groupedNotifications =
              groupNotifications(filteredNotifications);

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dateKeys = groupedNotifications.keys.toList();
                final dateKey = dateKeys[index];
                final dayNotifications = groupedNotifications[dateKey]!;
                final isLast = index == dateKeys.length - 1;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast
                        ? screenSize.height * 0.1
                        : AppTheme.getLargePadding(screenSize),
                  ),
                  child: _buildDaySection(context, dateKey, dayNotifications),
                );
              },
              childCount: groupedNotifications.keys.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySection(
      BuildContext context, String dateKey, List<dynamic> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppTheme.getSmallPadding(screenSize) * 0.3,
            bottom: AppTheme.getSmallPadding(screenSize),
          ),
          child: Text(
            formatDateHeader(dateKey),
            style: AppTheme.getBodyLarge(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        ...notifications.asMap().entries.map((entry) {
          final index = entry.key;
          final notification = entry.value;
          final isLast = index == notifications.length - 1;

          return Padding(
            padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize)),
            child: _buildNotificationCard(context, notification),
          );
        }),
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context, dynamic notification) {
    final isUnread =
        notification.estado.toString() != 'EstadoNotificacion.leida';
    final notificationType = getNotificationType(notification.tipo.toString());

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: isUnread
            ? Border.all(
                color: AppTheme.accentPurple.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.01,
            offset: Offset(0, screenSize.height * 0.0025),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          onTap: () => onNotificationTap(notification.id),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenSize.height * 0.055,
                  height: screenSize.height * 0.055,
                  decoration: BoxDecoration(
                    color: notificationType['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize) * 0.7),
                  ),
                  child: Icon(
                    notificationType['icon'],
                    color: notificationType['color'],
                    size: screenSize.height * 0.0275,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallRadius(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.titulo,
                              style: AppTheme.getSubtitle1(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            SizedBox(
                                width:
                                    AppTheme.getSmallPadding(screenSize) * 0.5),
                            Container(
                              width: screenSize.height * 0.01,
                              height: screenSize.height * 0.01,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Text(
                        notification.mensaje,
                        style: AppTheme.getSubtitle2(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Text(
                        formatDateTime(notification.fechaHora),
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize) * 1.5),
      margin: EdgeInsets.only(bottom: screenSize.height * 0.1),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenSize.height * 0.1,
            height: screenSize.height * 0.1,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: screenSize.height * 0.05,
              color: AppTheme.accentPurple,
            ),
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
          Text(
            l10n.noNotifications,
            style: AppTheme.getH2(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            l10n.notificationsWillAppearHere,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
