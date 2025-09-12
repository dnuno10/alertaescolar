import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/user_provider.dart';
import '../../../utils/time_format.dart';
import '../../../views/admin/qr_and_notifications/attendance_calendar_view.dart';

class RecentAttendanceCard extends StatefulWidget {
  final Size screenSize;
  final void Function(Future<void> Function())? onReloadCallbackSet;

  const RecentAttendanceCard({
    super.key,
    required this.screenSize,
    this.onReloadCallbackSet,
  });

  @override
  State<RecentAttendanceCard> createState() => _RecentAttendanceCardState();
}

class _RecentAttendanceCardState extends State<RecentAttendanceCard> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _recentNotifications = [];
  bool _isLoading = true;
  String? _error;
  bool _isInitialized = false;

  RealtimeChannel? _realtimeChannel;
  Timer? _debounceReloadTimer;
  String? _escuelaIdInUse;

  UserProvider? _userProvider;
  VoidCallback? _userProviderListener;

  /// Método público para forzar recarga desde componentes padre
  Future<void> forceReload() async {
    if (!mounted || _escuelaIdInUse == null || _escuelaIdInUse!.isEmpty) {
      return;
    }
    await _loadRecentNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;

      // Registrar callback de recarga si se proporciona
      if (widget.onReloadCallbackSet != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onReloadCallbackSet!(forceReload);
        });
      }

      _userProvider = Provider.of<UserProvider>(context, listen: false);

      _userProviderListener = () async {
        try {
          final newEscuelaId = _userProvider?.currentUser?.escuelaId;
          final isLoggedIn = _userProvider?.isLoggedIn ?? false;

          if (!isLoggedIn) {
            _escuelaIdInUse = null;
            _recentNotifications = [];
            _error = null;
            _isLoading = false;
            if (mounted) setState(() {});
            await _unsubscribeFromRealtime();
            return;
          }

          if (newEscuelaId != null &&
              newEscuelaId.isNotEmpty &&
              newEscuelaId != _escuelaIdInUse) {
            _escuelaIdInUse = newEscuelaId;
            if (mounted) setState(() => _isLoading = true);
            await _loadRecentNotifications();
            await _subscribeToRealtime();
          }
        } catch (_) {}
      };

      _userProvider?.addListener(_userProviderListener!);
      _setupAndLoad();
    }
  }

  Future<void> _setupAndLoad() async {
    final l10n = AppLocalizations.of(context);
    try {
      final escuelaId = await Provider.of<UserProvider>(context, listen: false)
          .ensureEscuelaIdOrThrow();

      _escuelaIdInUse = escuelaId;
      await _loadRecentNotifications();
      await _subscribeToRealtime();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = l10n.couldNotGetUserSchool;
        _isLoading = false;
      });
    }
  }

  Future<void> _unsubscribeFromRealtime() async {
    if (_realtimeChannel != null) {
      try {
        await _supabase.removeChannel(_realtimeChannel!);
      } catch (_) {}
      _realtimeChannel = null;
    }
  }

  Future<void> _subscribeToRealtime() async {
    await _unsubscribeFromRealtime();

    if (_escuelaIdInUse == null || _escuelaIdInUse!.isEmpty) {
      debugPrint(
          '🔄 RecentAttendanceCard: No escuelaId, skipping realtime subscription');
      return;
    }

    // 🔧 FIX: Mejorar suscripción realtime con canal único y filtros específicos
    final channelName =
        'notificaciones-recent-${_escuelaIdInUse!}-${DateTime.now().millisecondsSinceEpoch}';
    _realtimeChannel = _supabase.channel(channelName);

    // Escuchar cambios en notificaciones de asistencia
    _realtimeChannel!
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notificaciones',
        callback: (payload) {
          debugPrint('🔄 RecentAttendanceCard: INSERT detected');
          debugPrint('🔄 Payload: ${payload.newRecord}');

          // Verificar que sea de nuestra escuela y tipo relevante
          final record = payload.newRecord;
          final tipoNotif = record['tipo_notificacion']?.toString();
          if (['entrada', 'salida', 'retraso'].contains(tipoNotif)) {
            debugPrint(
                '🔄 RecentAttendanceCard: Relevant notification type: $tipoNotif');
            _triggerReload();
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'notificaciones',
        callback: (payload) {
          debugPrint('🔄 RecentAttendanceCard: UPDATE detected');
          final record = payload.newRecord;
          final tipoNotif = record['tipo_notificacion']?.toString();
          if (['entrada', 'salida', 'retraso'].contains(tipoNotif)) {
            _triggerReload();
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'notificaciones',
        callback: (payload) {
          debugPrint('🔄 RecentAttendanceCard: DELETE detected');
          _triggerReload();
        },
      )
      ..subscribe((status, [ref]) {
        debugPrint(
            '🔄 RecentAttendanceCard: Subscription status: $status for escuela: $_escuelaIdInUse');
        if (status == 'SUBSCRIBED') {
          debugPrint(
              '🔄 RecentAttendanceCard: Successfully subscribed to realtime updates');
        }
      });

    debugPrint(
        '🔄 RecentAttendanceCard: Realtime subscription configured for escuela: $_escuelaIdInUse');
  }

  void _triggerReload() {
    _debounceReloadTimer?.cancel();
    _debounceReloadTimer = Timer(
      const Duration(
          milliseconds: 100), // Reducir debounce para updates más rápidos
      () {
        debugPrint('🔄 RecentAttendanceCard: Executing reload...');
        if (mounted) _loadRecentNotifications();
      },
    );
  }

  Future<void> _loadRecentNotifications() async {
    final l10n = AppLocalizations.of(context);
    try {
      final escuelaId = _escuelaIdInUse;
      if (escuelaId == null || escuelaId.isEmpty) {
        setState(() {
          _error = l10n.couldNotGetUserSchool;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _supabase
          .from('notificaciones')
          .select('''
            id,
            tipo_notificacion,
            fecha_registro,
            alumnos!inner(
              id,
              nombre,
              matricula,
              grupos(
                id,
                grupo,
                nivel_educativo
              )
            )
          ''')
          .eq('alumnos.id_escuela', escuelaId)
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso'])
          .order('fecha_registro', ascending: false)
          .limit(3);

      if (!mounted) return;
      setState(() {
        _recentNotifications =
            List<Map<String, dynamic>>.from(response as List);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounceReloadTimer?.cancel();
    if (_userProviderListener != null) {
      _userProvider?.removeListener(_userProviderListener!);
    }
    _unsubscribeFromRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = AppTheme.getLargeRadius(widget.screenSize);
    final borderW = widget.screenSize.width * 0.0025;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con CTA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentAttendance,
              style: AppTheme.getH2(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AttendanceCalendarView(),
                  ),
                );
              },
              child: Text(
                l10n.viewAll,
                style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

        // Tarjeta estilo "capsule" sin sombras
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppTheme.getDividerColor(context),
              width: borderW,
            ),
          ),
          child: _buildContent(context, l10n),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: widget.screenSize.height * 0.05,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
            Text(
              l10n.errorLoadingData,
              style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                color: AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_recentNotifications.isEmpty) {
      return _EmptyState(screenSize: widget.screenSize, l10n: l10n);
    }

    return Column(
      children: _recentNotifications
          .asMap()
          .entries
          .map((entry) => _AttendanceItem(
                notification: entry.value,
                screenSize: widget.screenSize,
                isLast: entry.key == _recentNotifications.length - 1,
              ))
          .toList(),
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final Size screenSize;
  final bool isLast;

  const _AttendanceItem({
    required this.notification,
    required this.screenSize,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tipoNotificacion =
        (notification['tipo_notificacion'] ?? '') as String;

    final statusColor = _getStatusColor(tipoNotificacion);
    final statusIcon = _getStatusIcon(tipoNotificacion);

    // 🔧 FIX: Fecha segura usando TimeFormat.parseSupabaseDateTime para manejar timestamptz
    DateTime fechaRegistro;
    final rawFecha = notification['fecha_registro'];
    try {
      fechaRegistro = rawFecha is String
          ? TimeFormat.parseSupabaseDateTime(rawFecha)
          : (rawFecha is DateTime ? rawFecha : DateTime.now());
    } catch (_) {
      fechaRegistro = DateTime.now();
    }
    final timeAgo = _getTimeAgo(fechaRegistro, l10n);

    final alumno = Map<String, dynamic>.from(notification['alumnos'] ?? {});
    final alumnoNombre = (alumno['nombre'] ?? 'Estudiante') as String;

    final grupos = alumno['grupos'];
    String gradoGrupo;
    if (grupos is Map) {
      final g = Map<String, dynamic>.from(grupos);
      final nivel = (g['nivel_educativo'] ?? g['grado'] ?? '').toString();
      final grupoLetra = (g['grupo'] ?? '').toString();
      gradoGrupo = [
        if (nivel.isNotEmpty) nivel,
        if (grupoLetra.isNotEmpty) grupoLetra,
      ].join(' - ');
      if (gradoGrupo.isEmpty) gradoGrupo = 'Grupo';
    } else {
      gradoGrupo = 'Grupo';
    }

    final rowPad = AppTheme.getSmallPadding(screenSize);
    final badgeRad = AppTheme.getSmallRadius(screenSize) * 0.5;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono de estado (cápsula plana)
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: statusColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(screenSize),
              ),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: screenSize.width * 0.06,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre + tiempo (pill)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alumnoNombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: rowPad),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rowPad * 0.7,
                        vertical: rowPad * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getNeutralLightColor(context),
                        borderRadius: BorderRadius.circular(badgeRad),
                      ),
                      child: Text(
                        timeAgo,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: rowPad * 0.5),

                // Grado + descripción
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rowPad * 0.8,
                        vertical: rowPad * 0.25,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppTheme.accentBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(badgeRad),
                      ),
                      child: Text(
                        gradoGrupo,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: rowPad),
                    Expanded(
                      child: Text(
                        _getStatusText(tipoNotificacion, l10n),
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }

  Color _getStatusColor(String tipoNotificacion) {
    switch (tipoNotificacion) {
      case 'entrada':
        return AppTheme.successColor;
      case 'salida':
        return AppTheme.accentBlue;
      case 'retraso':
        return AppTheme.warningColor;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getStatusIcon(String tipoNotificacion) {
    switch (tipoNotificacion) {
      case 'entrada':
        return Icons.check_circle_rounded;
      case 'salida':
        return Icons.logout_rounded;
      case 'retraso':
        return Icons.schedule_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _getStatusText(String tipoNotificacion, AppLocalizations l10n) {
    switch (tipoNotificacion) {
      case 'entrada':
        return 'Entrada registrada';
      case 'salida':
        return 'Salida registrada';
      case 'retraso':
        return 'Llegada tardía';
      default:
        return 'Acceso registrado';
    }
  }

  String _getTimeAgo(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) return l10n.timeAgoNow;
    if (difference.inMinutes < 60) {
      return l10n.timeAgoMinutes(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.timeAgoHours(difference.inHours);
    } else {
      return l10n.timeAgoDays(difference.inDays);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final Size screenSize;
  final AppLocalizations l10n;

  const _EmptyState({
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: screenSize.height * 0.08,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noAttendanceRecords,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.startScanningToSeeRecords,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
