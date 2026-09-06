// lib/views/notifications/notifications_view.dart
import 'dart:async';
import 'package:alertaescolar/components/headers/notification_header.dart';
import 'package:alertaescolar/components/notifications/enhanced_filter_section.dart';
import 'package:alertaescolar/components/notifications/notification_detail_modal.dart';
import 'package:alertaescolar/components/notifications/notification_list_section.dart';
import 'package:alertaescolar/components/notifications/time_filter_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../../managers/notification_provider.dart';
import '../../../app/app_theme.dart';
import '../../../models/models.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewViewState();
}

class _NotificationsViewViewState extends State<NotificationsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = 'all';
  String _timeFilter = 'today';
  late Size screenSize;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<NotificationProvider>();
      await provider.reloadAndRefreshRealtime();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: LiquidPullToRefresh(
        onRefresh: _onPullToRefresh,
        color: AppTheme.accentPurple,
        backgroundColor: AppTheme.getBackgroundColor(context),
        height: 120,
        animSpeedFactor: 9.0,
        showChildOpacityTransition: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            NotificationHeader(screenSize: screenSize),
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
            NotificationsListSection(
              screenSize: screenSize,
              getFilteredNotifications: _getFilteredNotifications,
              groupNotifications: _groupNotificationsByDate,
              formatDateHeader: _formatDateHeader,
              formatDateTime: _formatDateTime,
              getNotificationType: (n) => _getNotificationType(n),
              onNotificationTap: _handleNotificationTap,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Fast Sheet Route (transición ultra-rápida) ----------
  // Esta ruta reemplaza al showModalBottomSheet para abrir "ya".
  // Anima en 140ms con leve slide + fade (estilo iOS).
  Route _fastSheetRoute(Widget child) {
    return PageRouteBuilder(
      opaque: false,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.20),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, anim, secondary) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(curved),
                child: Material(
                  color: Colors.transparent,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- Helpers ----------
  List<dynamic> _getFilteredNotifications(List<dynamic> notifications) {
    List<dynamic> filtered = notifications;

    // Apply type filter
    switch (_currentFilter) {
      case 'access_alerts':
        filtered = notifications.where((n) {
          final type = n.tipo.toString().toLowerCase();
          final isAccess = type.contains('entrada') ||
              type.contains('salida') ||
              type.contains('acceso') ||
              type.contains('retraso') ||
              type.contains('ausencia');

          // Emergencias enviadas como "comunicado"
          final isComunicadoEmergencia = type.contains('comunicado') &&
              (n.datosAdicionales?['tipo_comunicado']
                      ?.toString()
                      .toLowerCase() ==
                  'emergencia');

          // También soporta "emergency" si viniera directo del tipo
          final isEmergencyRaw = type.contains('emergency');

          return isAccess || isComunicadoEmergencia || isEmergencyRaw;
        }).toList();
        break;

      case 'communications':
        filtered = notifications.where((n) {
          final type = n.tipo.toString().toLowerCase();
          final isComunicado = type.contains('comunicado');
          final isEvento = type.contains('evento');
          final isPermiso = type.contains('permisoespecial');

          // Excluye comunicados de emergencia (ya los contamos como alertas)
          final isEmergencia = (n.datosAdicionales?['tipo_comunicado']
                  ?.toString()
                  .toLowerCase() ==
              'emergencia');

          return (isComunicado || isEvento || isPermiso) && !isEmergencia;
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
      grouped.putIfAbsent(dateKey, () => []);
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

  String _getDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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
      const weekdays = [
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
        final m = difference.inMinutes;
        return m <= 0 ? 'Ahora' : '${m}m';
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
    final localDate = date.toLocal();
    return localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day;
  }

  // ---------- Tap sin delay: abre YA y marca en background ----------
  void _handleNotificationTap(String notificationId) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final notification = provider.getNotificationById(notificationId);
    if (notification == null) return;

    // Feedback instantáneo (opcional)
    HapticFeedback.selectionClick();

    // 1) Optimistic update local (no bloquea la UI)
    provider.markLocalAsRead(notificationId);

    // 2) Abrir modal inmediato con ruta rápida (140ms)
    Navigator.of(context).push(_fastSheetRoute(
      NotificationDetailModal(
        notification: notification,
        screenSize: screenSize,
      ),
    ));

    // 3) Persistir como leída en background (sin await)
    Future.microtask(() => provider.markAsRead(notificationId));
  }

  // Mapea tipo → icono/color (entrada VERDE, salida ROJA)
  Map<String, dynamic> _getNotificationType(Notificacion n) {
    final cleanType =
        n.tipo.toString().toLowerCase().replaceAll('tiponotificacion.', '');

    // Emergencia enviada como comunicado
    final isComunicadoEmergencia = cleanType == 'comunicado' &&
        (n.datosAdicionales?['tipo_comunicado']?.toString().toLowerCase() ==
            'emergencia');

    if (isComunicadoEmergencia) {
      return {'icon': Icons.warning_outlined, 'color': AppTheme.errorColor};
    }

    switch (cleanType) {
      case 'entrada':
        return {'icon': Icons.login_outlined, 'color': AppTheme.successColor};
      case 'salida':
        return {'icon': Icons.logout_outlined, 'color': AppTheme.errorColor};
      case 'retraso':
        return {
          'icon': Icons.access_time_outlined,
          'color': AppTheme.warningColor
        };
      case 'ausencia':
        return {
          'icon': Icons.person_off_outlined,
          'color': AppTheme.warningColor
        };
      case 'emergency':
        return {'icon': Icons.warning_outlined, 'color': AppTheme.errorColor};
      case 'comunicado':
        return {
          'icon': Icons.campaign_outlined,
          'color': AppTheme.accentPurple
        };
      case 'evento':
        return {'icon': Icons.event_outlined, 'color': AppTheme.accentPurple};
      case 'permisoespecial':
        return {
          'icon': Icons.event_available_outlined,
          'color': AppTheme.accentPurple
        };
      case 'acceso':
        return {'icon': Icons.key_outlined, 'color': AppTheme.accentBlue};
      default:
        return {'icon': Icons.info_outline, 'color': AppTheme.accentBlue};
    }
  }

  Future<void> _onPullToRefresh() async {
    await context.read<NotificationProvider>().reloadAndRefreshRealtime();
  }
}
