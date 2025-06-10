// 🚀 Premium Notifications View - Following Fintech/EdTech Design References
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/notification_provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewViewState();
}

class _NotificationsViewViewState extends State<NotificationsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = 'access_alerts';
  String _timeFilter = 'today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();
      provider.loadNotifications();
      provider.markAllAsRead(); // Auto-mark as read when entering notifications
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // Modern Header
          _buildModernHeader(context, screenSize),

          // Enhanced Filter Section
          SliverToBoxAdapter(
            child: _buildEnhancedFilterSection(context, screenSize),
          ),

          // Time Filter Section
          SliverToBoxAdapter(
            child: _buildTimeFilterSection(context, screenSize),
          ),

          // Notifications List
          _buildNotificationsList(context, screenSize),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notifications,
                          style: AppTheme.getH1(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        Consumer<NotificationProvider>(
                          builder: (context, provider, child) {
                            final filteredCount = _getFilteredNotifications(
                                    provider.notifications)
                                .length;
                            return Text(
                              '$filteredCount ${_getFilterLabel(l10n)}',
                              style: AppTheme.getSubtitle1(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildEnhancedFilterSection(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getLargePadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categories,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Container(
            height: screenSize.height * 0.065,
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: screenSize.height * 0.01,
                  offset: Offset(0, screenSize.height * 0.0025),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.accentPurple,
              unselectedLabelColor: AppTheme.getTextSecondaryColor(context),
              indicatorColor: AppTheme.accentPurple,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTheme.getSubtitle2(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: AppTheme.getSubtitle2(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              dividerColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.5),
              onTap: (index) {
                setState(() {
                  _currentFilter =
                      ['access_alerts', 'communications', 'all'][index];
                });
              },
              tabs: [
                Tab(text: l10n.accessAlerts),
                Tab(text: l10n.announcements),
                Tab(text: l10n.allNotifications),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterSection(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getLargePadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.period,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Row(
            children: [
              _buildTimeFilterChip('today', l10n.today, context, screenSize),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              _buildTimeFilterChip(
                  '7days', l10n.sevenDays, context, screenSize),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              _buildTimeFilterChip(
                  '14days', l10n.fourteenDays, context, screenSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(
      String value, String label, BuildContext context, Size screenSize) {
    final isSelected = _timeFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _timeFilter = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: screenSize.height * 0.055,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentBlue
                : AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: isSelected
                ? null
                : Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.accentBlue.withValues(alpha: 0.25),
                      blurRadius: screenSize.height * 0.01,
                      offset: Offset(0, screenSize.height * 0.0025),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.getShadowColor(context),
                      blurRadius: screenSize.height * 0.005,
                      offset: Offset(0, screenSize.height * 0.00125),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.getSubtitle2(screenSize).copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, Size screenSize) {
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
              _getFilteredNotifications(provider.notifications);

          if (filteredNotifications.isEmpty) {
            return SliverToBoxAdapter(
                child: _buildEmptyState(context, screenSize));
          }

          // Group notifications by date
          final groupedNotifications =
              _groupNotificationsByDate(filteredNotifications);

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
                  child: _buildDaySection(
                      dateKey, dayNotifications, context, screenSize),
                );
              },
              childCount: groupedNotifications.keys.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySection(String dateKey, List<dynamic> notifications,
      BuildContext context, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppTheme.getSmallPadding(screenSize) * 0.3,
            bottom: AppTheme.getSmallPadding(screenSize),
          ),
          child: Text(
            _formatDateHeader(dateKey),
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
            child: _buildNotificationCard(notification, context, screenSize),
          );
        }),
      ],
    );
  }

  Widget _buildNotificationCard(
      dynamic notification, BuildContext context, Size screenSize) {
    final isUnread =
        notification.estado.toString() != 'EstadoNotificacion.leida';
    final notificationType = _getNotificationType(notification.tipo.toString());

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
          onTap: () => _handleNotificationTap(notification.id),
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
                        _formatDateTime(notification.fechaHora),
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

  Widget _buildEmptyState(BuildContext context, Size screenSize) {
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

  // Helper methods
  String _getFilterLabel(AppLocalizations l10n) {
    switch (_currentFilter) {
      case 'access_alerts':
        return l10n.accessRecordsAndAlerts;
      case 'communications':
        return l10n.announcements;
      default:
        return l10n.notifications;
    }
  }

  List<dynamic> _getFilteredNotifications(List<dynamic> notifications) {
    List<dynamic> filtered = notifications;

    // Apply type filter
    switch (_currentFilter) {
      case 'access_alerts':
        filtered = notifications.where((n) {
          final type = n.tipo.toString().toLowerCase();
          return type.contains('entrada') ||
              type.contains('salida') ||
              type.contains('acceso') ||
              type.contains('retraso') ||
              type.contains('ausencia') ||
              type.contains('emergency');
        }).toList();
        break;
      case 'communications':
        filtered = notifications.where((n) {
          final type = n.tipo.toString().toLowerCase();
          return type.contains('comunicado') || type.contains('evento');
        }).toList();
        break;
      default:
        // all - no filter
        break;
    }

    // Apply time filter
    final now = DateTime.now();
    switch (_timeFilter) {
      case 'today':
        filtered = filtered.where((n) => _isToday(n.fechaHora)).toList();
        break;
      case '7days':
        filtered = filtered.where((n) {
          final difference = now.difference(n.fechaHora).inDays;
          return difference <= 7;
        }).toList();
        break;
      case '14days':
        filtered = filtered.where((n) {
          final difference = now.difference(n.fechaHora).inDays;
          return difference <= 14;
        }).toList();
        break;
    }

    return filtered;
  }

  Map<String, List<dynamic>> _groupNotificationsByDate(
      List<dynamic> notifications) {
    final Map<String, List<dynamic>> grouped = {};

    for (final notification in notifications) {
      final dateKey = _getDateKey(notification.fechaHora);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }

    // Sort by date (newest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final sortedGrouped = <String, List<dynamic>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final date =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      final weekdays = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo'
      ];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _handleNotificationTap(String notificationId) {
    // Just handle the tap, no need to mark as read since it's automatic
    // You can add navigation to detail view here if needed
  }

  Map<String, dynamic> _getNotificationType(String type) {
    final cleanType = type.toLowerCase().replaceAll('tiponotificacion.', '');
    switch (cleanType) {
      case 'entrada':
        return {
          'icon': Icons.login_outlined,
          'color': AppTheme.accentBlue,
        };
      case 'salida':
        return {
          'icon': Icons.logout_outlined,
          'color': AppTheme.accentBlue,
        };
      case 'retraso':
        return {
          'icon': Icons.access_time_outlined,
          'color': AppTheme.warningColor,
        };
      case 'ausencia':
        return {
          'icon': Icons.person_off_outlined,
          'color': AppTheme.warningColor,
        };
      case 'emergency':
        return {
          'icon': Icons.warning_outlined,
          'color': AppTheme.errorColor,
        };
      case 'comunicado':
        return {
          'icon': Icons.campaign_outlined,
          'color': AppTheme.accentPurple,
        };
      case 'evento':
        return {
          'icon': Icons.event_outlined,
          'color': AppTheme.accentPurple,
        };
      case 'acceso':
        return {
          'icon': Icons.key_outlined,
          'color': AppTheme.accentBlue,
        };
      default:
        return {
          'icon': Icons.info_outline,
          'color': AppTheme.accentBlue,
        };
    }
  }
}
