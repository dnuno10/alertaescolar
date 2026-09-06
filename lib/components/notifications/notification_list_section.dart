// lib/components/notifications_list_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/notification_provider.dart';
import '../../models/models.dart';

class NotificationsListSection extends StatelessWidget {
  final Size screenSize;
  final List<dynamic> Function(List<dynamic>) getFilteredNotifications;
  final Map<String, List<dynamic>> Function(List<dynamic>) groupNotifications;
  final String Function(String) formatDateHeader;
  final String Function(DateTime) formatDateTime;
  final Map<String, dynamic> Function(Notificacion) getNotificationType;
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
    final horizontalPad = AppTheme.getLargePadding(screenSize);
    final verticalPad = AppTheme.getSmallPadding(screenSize);

    return SliverPadding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPad, vertical: verticalPad),
      sliver: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return SliverToBoxAdapter(
                child: _LoadingCard(screenSize: screenSize));
          }

          final filtered = getFilteredNotifications(provider.notifications);
          if (filtered.isEmpty) {
            return SliverToBoxAdapter(
                child: _EmptyState(screenSize: screenSize));
          }

          final grouped = groupNotifications(filtered);
          final keys = grouped.keys.toList();

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dateKey = keys[index];
                final dayList = grouped[dateKey]!;
                final isLast = index == keys.length - 1;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? horizontalPad * 1.5 : horizontalPad,
                  ),
                  child: _DaySection(
                    title: formatDateHeader(dateKey),
                    screenSize: screenSize,
                    children: dayList.map((e) {
                      final n = e as Notificacion;
                      return _GroupedRow(
                        key: ValueKey(n.id),
                        isFirst: dayList.indexOf(e) == 0,
                        isLast: dayList.indexOf(e) == dayList.length - 1,
                        screenSize: screenSize,
                        child: _NotificationCell(
                          notification: n,
                          formatDateTime: formatDateTime,
                          getNotificationType: getNotificationType,
                          onTap: () => onNotificationTap(n.id),
                          screenSize: screenSize,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              childCount: keys.length,
            ),
          );
        },
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.screenSize});
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.getLargePadding(screenSize);
    return Container(
      margin: EdgeInsets.only(top: pad, bottom: pad * 1.5),
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenSize.height * 0.030,
            height: screenSize.height * 0.030,
            child: const CircularProgressIndicator(
                strokeWidth: 2.2, color: AppTheme.accentPurple),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Text(
              AppLocalizations.of(context).loadingNotifications,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.screenSize});
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pad = AppTheme.getLargePadding(screenSize);
    final radius = AppTheme.getLargeRadius(screenSize);

    return Container(
      padding: EdgeInsets.all(pad * 1.1),
      margin: EdgeInsets.only(top: pad, bottom: pad * 1.6),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SoftGlyph(
            size: screenSize.height * 0.085,
            iconSize: screenSize.height * 0.030,
            color: AppTheme.accentPurple,
            screenSize: screenSize,
            icon: Icons.notifications_none_rounded,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noNotifications,
            textAlign: TextAlign.center,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.6),
          Text(
            l10n.notificationsWillAppearHere,
            textAlign: TextAlign.center,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.title,
    required this.screenSize,
    required this.children,
  });

  final String title;
  final Size screenSize;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final padX = AppTheme.getSmallPadding(screenSize) * 0.3;
    final sectionSpacing = AppTheme.getSmallPadding(screenSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: padX, bottom: sectionSpacing),
          child: Text(
            title.toUpperCase(),
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              letterSpacing: 0.8,
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _GroupedContainer(
          screenSize: screenSize,
          children: children,
        ),
      ],
    );
  }
}

/// Contenedor estilo "grouped list" (iOS) con borde y divisores internos.
class _GroupedContainer extends StatelessWidget {
  const _GroupedContainer({
    required this.screenSize,
    required this.children,
  });

  final Size screenSize;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final radiusL = AppTheme.getLargeRadius(screenSize);
    final borderColor = AppTheme.getBorderColor(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radiusL),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(radiusL),
        ),
        child: Column(
          children: _withDividers(children, context),
        ),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items, BuildContext context) {
    if (items.isEmpty) return items;
    final List<Widget> withDividers = [];
    for (int i = 0; i < items.length; i++) {
      withDividers.add(items[i]);
      if (i < items.length - 1) {
        withDividers.add(_ThinDivider(screenSize: screenSize));
      }
    }
    return withDividers;
  }
}

/// Fila con padding que sabe si es la primera/última para radius en splash.
class _GroupedRow extends StatelessWidget {
  const _GroupedRow({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.child,
    required this.screenSize,
  });

  final bool isFirst;
  final bool isLast;
  final Widget child;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    final radius = AppTheme.getLargeRadius(screenSize);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // El onTap real vive dentro de la celda para mantener ergonomía.
        },
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? radius : 0),
          bottom: Radius.circular(isLast ? radius : 0),
        ),
        child: child,
      ),
    );
  }
}

/// Celda de notificación al estilo iOS: leading circular + título + hora + indicador de no leído.
class _NotificationCell extends StatelessWidget {
  final Notificacion notification;
  final String Function(DateTime) formatDateTime;
  final Map<String, dynamic> Function(Notificacion) getNotificationType;
  final VoidCallback onTap;
  final Size screenSize;

  const _NotificationCell({
    required this.notification,
    required this.formatDateTime,
    required this.getNotificationType,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread =
        notification.estado.toString() != 'EstadoNotificacion.leida';
    final t = getNotificationType(notification);
    final Color accent = t['color'] as Color;
    final IconData ic = t['icon'] as IconData;

    final cellHPad = AppTheme.getMediumPadding(screenSize);
    final cellVPad = AppTheme.getMediumPadding(screenSize) * 0.85;

    final titleStyle = AppTheme.getSubtitle2(screenSize).copyWith(
      color: AppTheme.getTextPrimaryColor(context),
      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
      height: 1.2,
    );

    final timeStyle = AppTheme.getCaptionSmall(screenSize).copyWith(
      color: AppTheme.getTextSecondaryColor(context),
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      button: true,
      label: notification.titulo,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: cellHPad, vertical: cellVPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TypeGlyph(
                color: accent,
                icon: ic,
                screenSize: screenSize,
              ),
              SizedBox(width: screenSize.width * 0.028),

              /// Texto + metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Primera línea: Título + hora a la derecha
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            notification.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Text(
                          formatDateTime(notification.fechaHora),
                          style: timeStyle,
                        ),
                      ],
                    ),

                    /// Segunda línea: “dot” no leído opcional
                    if (isUnread)
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppTheme.getSmallPadding(screenSize) * 0.45),
                        child: Row(
                          children: [
                            _UnreadDot(color: accent, screenSize: screenSize),
                            SizedBox(
                                width:
                                    AppTheme.getSmallPadding(screenSize) * 0.6),
                            Text(
                              'No leída',
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              /// Chevron sutil
              Padding(
                padding:
                    EdgeInsets.only(left: AppTheme.getSmallPadding(screenSize)),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: screenSize.height * 0.026,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icono circular suave para el tipo de notificación.
class _TypeGlyph extends StatelessWidget {
  const _TypeGlyph({
    required this.color,
    required this.icon,
    required this.screenSize,
  });

  final Color color;
  final IconData icon;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    final size = screenSize.height * 0.042;
    final inner = screenSize.height * 0.024;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Icon(icon, size: inner, color: color),
    );
  }
}

class _SoftGlyph extends StatelessWidget {
  const _SoftGlyph({
    required this.size,
    required this.iconSize,
    required this.color,
    required this.screenSize,
    required this.icon,
  });

  final double size;
  final double iconSize;
  final Color color;
  final Size screenSize;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.color, required this.screenSize});
  final Color color;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    final d = screenSize.height * 0.0105;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider({required this.screenSize});
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(
        left: screenSize.width * 0.13, // alinea con texto (después de glyph)
      ),
      color: AppTheme.getBorderColor(context),
    );
  }
}
