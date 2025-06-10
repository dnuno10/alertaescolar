// 🚀 Premium Notifications View - Following Fintech/EdTech Design References
import 'package:alertaescolar/components/headers/notification_header.dart';
import 'package:alertaescolar/components/notifications/enhanced_filter_section.dart';
import 'package:alertaescolar/components/notifications/notification_list_section.dart';
import 'package:alertaescolar/components/notifications/time_filter_section.dart';
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
          // Notification Header
          NotificationHeader(
            screenSize: screenSize,
            getFilteredCount: (notifications) =>
                _getFilteredNotifications(notifications).length,
            getFilterLabel: _getFilterLabel,
          ),

          // Enhanced Filter Section
          SliverToBoxAdapter(
            child: EnhancedFilterSection(
              screenSize: screenSize,
              tabController: _tabController,
              currentFilter: _currentFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _currentFilter = filter;
                });
              },
            ),
          ),

          // Time Filter Section
          SliverToBoxAdapter(
            child: TimeFilterSection(
              screenSize: screenSize,
              currentFilter: _timeFilter,
              onFilterChanged: (newFilter) {
                setState(() {
                  _timeFilter = newFilter;
                });
              },
            ),
          ),

          // Notifications List
          NotificationsListSection(
            screenSize: screenSize,
            getFilteredNotifications: _getFilteredNotifications,
            groupNotifications: _groupNotificationsByDate,
            formatDateHeader: _formatDateHeader,
            formatDateTime: _formatDateTime,
            getNotificationType: _getNotificationType,
            onNotificationTap: _handleNotificationTap,
          )
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
