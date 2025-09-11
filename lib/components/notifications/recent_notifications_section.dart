import 'package:alertaescolar/components/notifications/empty_notifications_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/notification_provider.dart';
import 'notification_card.dart';

class RecentNotificationsSection extends StatefulWidget {
  final Size screenSize;
  final VoidCallback onTapSeeAll;
  final Function(String)? onNotificationTap;
  final void Function(Future<void> Function())? onReloadCallbackSet;

  const RecentNotificationsSection({
    super.key,
    required this.screenSize,
    required this.onTapSeeAll,
    this.onNotificationTap,
    this.onReloadCallbackSet,
  });

  @override
  State<RecentNotificationsSection> createState() =>
      _RecentNotificationsSectionState();
}

class _RecentNotificationsSectionState
    extends State<RecentNotificationsSection> {
  bool _isCallbackRegistered = false;
  Timer? _debounceTimer;
  NotificationProvider? _notificationProvider;

  // Para detectar cambios directamente
  VoidCallback? _providerListener;
  int _lastNotificationCount = 0;
  DateTime? _lastUpdateTime;

  // Sistema de realtime local adicional para INSERT/DELETE inmediato
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _realtimeChannel;
  Timer? _localPollingTimer;

  /// Método para forzar la recarga desde el padre (home_view)
  Future<void> forceReload() async {
    debugPrint('🔄 RecentNotificationsSection: Force reload triggered');

    // Cancelar cualquier recarga pendiente
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 50), () async {
      if (!mounted) return;

      final notificationProvider = context.read<NotificationProvider>();

      debugPrint(
          '🔄 Current notifications count: ${notificationProvider.notifications.length}');
      debugPrint(
          '🔄 Provider loading state: ${notificationProvider.isLoading}');

      // Verificación inmediata ANTES del reload completo
      await notificationProvider.checkImmediateUpdates();

      // Si no detectó cambios, hacer reload completo
      if (mounted) {
        // Verificar y asegurar conexiones realtime
        await notificationProvider.ensureRealtimeConnections();

        // Reinicializar realtime local para asegurar conexión
        _initializeLocalRealtime();

        // Reinicia completamente el sistema de notificaciones y realtime
        await notificationProvider.reloadAndRefreshRealtime();

        debugPrint(
            '🔄 After reload - notifications count: ${notificationProvider.notifications.length}');

        // Fuerza una actualización del widget si está montado
        setState(() {
          // Forzar rebuild
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    if (_notificationProvider != provider) {
      // Remover listener anterior si existe
      if (_providerListener != null && _notificationProvider != null) {
        _notificationProvider!.removeListener(_providerListener!);
      }

      _notificationProvider = provider;
      _lastNotificationCount = provider.notifications.length;
      _lastUpdateTime = provider.lastUpdateTime;

      // Crear nuevo listener
      _providerListener = () {
        if (!mounted) return;

        final newCount = provider.notifications.length;
        final newUpdateTime = provider.lastUpdateTime;

        // Verificar si hay cambios reales
        if (newCount != _lastNotificationCount ||
            (newUpdateTime != _lastUpdateTime)) {
          _lastNotificationCount = newCount;
          _lastUpdateTime = newUpdateTime;

          // Forzar rebuild con setState
          setState(() {
            // Los datos han cambiado, forzar actualización
          });

          debugPrint(
              '🔄 RecentNotificationsSection: Detected changes - Count: $newCount, Time: $newUpdateTime');
        } else {
          // Si no hay cambios detectados, hacer verificación inmediata
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              provider.checkImmediateUpdates().then((_) {
                // Verificar de nuevo después de la verificación inmediata
                if (mounted) {
                  final finalCount = provider.notifications.length;
                  final finalTime = provider.lastUpdateTime;

                  if (finalCount != _lastNotificationCount ||
                      finalTime != _lastUpdateTime) {
                    _lastNotificationCount = finalCount;
                    _lastUpdateTime = finalTime;
                    setState(() {
                      // Forzar rebuild después de verificación inmediata
                    });
                  }
                }
              });
            }
          });
        }
      };

      // Agregar el listener
      provider.addListener(_providerListener!);

      // Inicializar realtime local para detección inmediata
      _initializeLocalRealtime();

      // Forzar una verificación del estado del realtime si está montado
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkRealtimeStatus();
          }
        });
      }
    }
  }

  /// Verifica el estado del realtime y reconecta si es necesario
  void _checkRealtimeStatus() async {
    try {
      final provider = _notificationProvider;
      if (provider != null) {
        // Verificar conexiones realtime con verificación inmediata incluida
        await provider.ensureRealtimeConnections();

        // Si no hay notificaciones y el provider no está cargando,
        // forzar una recarga
        if (provider.notifications.isEmpty && !provider.isLoading) {
          debugPrint(
              '🔄 RecentNotificationsSection: No notifications found, forcing reload...');
          await provider.loadNotifications();
        } else {
          // Hacer verificación inmediata adicional para detectar cambios recientes
          await provider.checkImmediateUpdates();
        }
      }
    } catch (e) {
      debugPrint('Error checking realtime status: $e');
    }
  }

  /// Inicializa el sistema de realtime local para detección inmediata de INSERT/DELETE
  void _initializeLocalRealtime() {
    _startLocalPolling();
    _subscribeToLocalRealtime();
  }

  /// Inicia polling local cada 1 segundo para detectar cambios inmediatamente
  void _startLocalPolling() {
    _localPollingTimer?.cancel();

    _localPollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted || _notificationProvider == null) return;

      try {
        // Verificar cambios inmediatos en el provider
        await _notificationProvider!.checkImmediateUpdates();
      } catch (e) {
        debugPrint('🔔 Local polling error: $e');
      }
    });
  }

  /// Suscribe a realtime local para notificaciones
  void _subscribeToLocalRealtime() async {
    try {
      await _unsubscribeFromLocalRealtime();

      _realtimeChannel = _supabase
          .channel('recent-notifications-section')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notificaciones',
            callback: (payload) {
              debugPrint('🔔 Local realtime event: ${payload.eventType}');

              // Forzar verificación inmediata
              if (mounted && _notificationProvider != null) {
                _notificationProvider!.checkImmediateUpdates().then((_) {
                  if (mounted) {
                    setState(() {
                      // Forzar rebuild después de cambio realtime
                    });
                  }
                });
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('🔔 Error subscribing to local realtime: $e');
    }
  }

  /// Cancela la suscripción de realtime local
  Future<void> _unsubscribeFromLocalRealtime() async {
    if (_realtimeChannel != null) {
      try {
        await _supabase.removeChannel(_realtimeChannel!);
      } catch (e) {
        debugPrint('🔔 Error unsubscribing from local realtime: $e');
      }
      _realtimeChannel = null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _localPollingTimer?.cancel();

    // Cancelar realtime local
    _unsubscribeFromLocalRealtime();

    // Remover listener del provider
    if (_providerListener != null && _notificationProvider != null) {
      _notificationProvider!.removeListener(_providerListener!);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Registrar callback de recarga si se proporciona y no se ha registrado aún
    if (widget.onReloadCallbackSet != null && !_isCallbackRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onReloadCallbackSet!(forceReload);
      });
      _isCallbackRegistered = true;
    }

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
                style: AppTheme.getH2(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),

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
                    widget.onTapSeeAll();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(widget.screenSize),
                      vertical:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: showBadge
                          ? AppTheme.warningColor
                          // ignore: deprecated_member_use
                          : AppTheme.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        showBadge
                            ? AppTheme.getMediumRadius(widget.screenSize)
                            : AppTheme.getSmallRadius(widget.screenSize),
                      ),
                      boxShadow: showBadge
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: AppTheme.warningColor.withOpacity(0.25),
                                blurRadius: widget.screenSize.height * 0.008,
                                offset:
                                    Offset(0, widget.screenSize.height * 0.003),
                              )
                            ]
                          : [],
                    ),
                    child: showBadge
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: widget.screenSize.height * 0.008,
                                height: widget.screenSize.height * 0.008,
                                decoration: BoxDecoration(
                                  color: AppTheme.getBackgroundColor(context),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                width: AppTheme.getSmallPadding(
                                        widget.screenSize) *
                                    0.5,
                              ),
                              Text(
                                '$unreadCount ${l10n.newNotifications}',
                                style: AppTheme.getCaption(widget.screenSize)
                                    .copyWith(
                                  color: AppTheme.getBackgroundColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            l10n.viewAll,
                            style:
                                AppTheme.getCaption(widget.screenSize).copyWith(
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
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

        // Lista de notificaciones con Consumer para detectar todos los cambios
        SizedBox(
          height: widget.screenSize.height * 0.2,
          child: Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              // ⬇️ Mostrar CircularProgressIndicator mientras no hayan cargado
              if (provider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                );
              }

              final recentNotifications =
                  provider.getRecentNotifications(limit: 5);
              if (recentNotifications.isEmpty) {
                return EmptyNotificationsCard(
                  screenSize: widget.screenSize,
                  onRefresh: () => provider.loadNotifications(),
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
                    screenSize: widget.screenSize,
                    onTap: () {
                      final cb = widget.onNotificationTap;
                      if (cb != null) {
                        cb(notification.id);
                      } else {
                        widget.onTapSeeAll();
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
