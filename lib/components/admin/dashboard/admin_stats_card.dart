import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/user_provider.dart';
import '../../../utils/time_format.dart';

class AdminStatsCard extends StatefulWidget {
  final Size screenSize;
  final void Function(Future<void> Function())? onReloadCallbackSet;

  const AdminStatsCard({
    super.key,
    required this.screenSize,
    this.onReloadCallbackSet,
  });

  @override
  State<AdminStatsCard> createState() => _AdminStatsCardState();
}

class _AdminStatsCardState extends State<AdminStatsCard> {
  final _supabase = Supabase.instance.client;

  int _totalScanned = 0;
  int _presentStudents = 0;
  int _lateStudents = 0;
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
    if (!mounted || _escuelaIdInUse == null || _escuelaIdInUse!.isEmpty) return;
    await _loadTodayStats();
  }

  ({DateTime startUtc, DateTime endUtc}) _todayUtcRangeFromLocal() {
    // 🔧 FIX: Usar TimeFormat.getDayUtcRangeFromLocal para manejar timezone correctamente
    return TimeFormat.getDayUtcRangeFromLocal();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;

      // Set up callback for parent
      widget.onReloadCallbackSet?.call(forceReload);

      _userProvider = Provider.of<UserProvider>(context, listen: false);

      _userProviderListener = () async {
        try {
          final newEscuelaId = _userProvider?.currentUser?.escuelaId;
          final isLoggedIn = _userProvider?.isLoggedIn ?? false;

          if (!isLoggedIn) {
            _escuelaIdInUse = null;
            _totalScanned = 0;
            _presentStudents = 0;
            _lateStudents = 0;
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
            await _loadTodayStats();
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
      await _loadTodayStats();
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
          '🔄 AdminStatsCard: No escuelaId, skipping realtime subscription');
      return;
    }

    // 🔧 FIX: Mejorar suscripción realtime con canal único y updates inmediatos
    final channelName =
        'notificaciones-stats-${_escuelaIdInUse!}-${DateTime.now().millisecondsSinceEpoch}';
    _realtimeChannel = _supabase.channel(channelName);

    // Escuchar cambios en notificaciones que afecten las estadísticas diarias
    _realtimeChannel!
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notificaciones',
        callback: (payload) {
          debugPrint('🔄 AdminStatsCard: INSERT detected');
          debugPrint('🔄 Stats payload: ${payload.newRecord}');

          final record = payload.newRecord;
          final tipoNotif = record['tipo_notificacion']?.toString();
          final fechaRegistro = record['fecha_registro']?.toString();

          // Solo actualizar si es una notificación de hoy y tipo relevante
          if (['entrada', 'salida', 'retraso'].contains(tipoNotif) &&
              fechaRegistro != null) {
            try {
              final notifTime = DateTime.parse(fechaRegistro);
              final todayRange = _todayUtcRangeFromLocal();

              if (notifTime.isAfter(todayRange.startUtc) &&
                  notifTime.isBefore(todayRange.endUtc)) {
                debugPrint(
                    '🔄 AdminStatsCard: Today notification detected, updating stats');
                _triggerStatsReload();
              }
            } catch (e) {
              debugPrint(
                  '🔄 AdminStatsCard: Error parsing notification date: $e');
              // Actualizar de todas formas por seguridad
              _triggerStatsReload();
            }
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'notificaciones',
        callback: (payload) {
          debugPrint('🔄 AdminStatsCard: UPDATE detected');
          final record = payload.newRecord;
          final tipoNotif = record['tipo_notificacion']?.toString();
          if (['entrada', 'salida', 'retraso'].contains(tipoNotif)) {
            _triggerStatsReload();
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'notificaciones',
        callback: (payload) {
          debugPrint('🔄 AdminStatsCard: DELETE detected');
          _triggerStatsReload();
        },
      )
      ..subscribe((status, [ref]) {
        debugPrint(
            '🔄 AdminStatsCard: Subscription status: $status for escuela: $_escuelaIdInUse');
        if (status == 'SUBSCRIBED') {
          debugPrint(
              '🔄 AdminStatsCard: Successfully subscribed to realtime stats updates');
        }
      });

    debugPrint(
        '🔄 AdminStatsCard: Realtime subscription configured for escuela: $_escuelaIdInUse');
  }

  void _triggerStatsReload() {
    _debounceReloadTimer?.cancel();
    _debounceReloadTimer = Timer(
      const Duration(milliseconds: 100), // Update rápido para estadísticas
      () {
        debugPrint('🔄 AdminStatsCard: Executing stats reload...');
        if (mounted) _loadTodayStats();
      },
    );
  }

  Future<void> _loadTodayStats() async {
    try {
      final escuelaId = _escuelaIdInUse;
      if (escuelaId == null || escuelaId.isEmpty) {
        setState(() {
          _error = 'No se pudo identificar la escuela';
          _isLoading = false;
        });
        return;
      }

      // 🔧 FIX: Usar TimeFormat.getDayUtcRangeFromLocal para cálculos correctos
      final todayRange = _todayUtcRangeFromLocal();
      debugPrint(
          '🔧 AdminStatsCard: Loading stats for UTC range: ${todayRange.startUtc} - ${todayRange.endUtc}');

      // Query para obtener estadísticas del día
      final response = await _supabase
          .from('notificaciones')
          .select('tipo_notificacion')
          .gte('fecha_registro', todayRange.startUtc.toIso8601String())
          .lt('fecha_registro', todayRange.endUtc.toIso8601String())
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso']);

      debugPrint(
          '🔧 AdminStatsCard: Raw query result: ${response.length} notifications');

      // Contar por tipo
      int totalScanned = 0;
      int presentStudents = 0;
      int lateStudents = 0;

      final countByType = <String, int>{};
      for (final notif in response) {
        final tipo = notif['tipo_notificacion']?.toString() ?? '';
        countByType[tipo] = (countByType[tipo] ?? 0) + 1;
      }

      totalScanned = countByType.values.fold(0, (sum, count) => sum + count);
      presentStudents = (countByType['entrada'] ?? 0);
      lateStudents = (countByType['retraso'] ?? 0);

      debugPrint(
          '🔧 AdminStatsCard: Calculated stats - Total: $totalScanned, Present: $presentStudents, Late: $lateStudents');
      debugPrint('🔧 AdminStatsCard: Count by type: $countByType');

      if (mounted) {
        setState(() {
          _totalScanned = totalScanned;
          _presentStudents = presentStudents;
          _lateStudents = lateStudents;
          _error = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔧 AdminStatsCard: Error loading stats: $e');
      if (mounted) {
        setState(() {
          _error = 'Error al cargar estadísticas: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceReloadTimer?.cancel();
    _unsubscribeFromRealtime();

    try {
      if (_userProviderListener != null) {
        _userProvider?.removeListener(_userProviderListener!);
      }
    } catch (_) {}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            offset:
                Offset(0, AppTheme.getSmallPadding(widget.screenSize) * 0.5),
            blurRadius: AppTheme.getSmallPadding(widget.screenSize),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estadísticas de hoy',
                style: AppTheme.getBodyLarge(widget.screenSize).copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: widget.screenSize.shortestSide * 0.04,
                  height: widget.screenSize.shortestSide * 0.04,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accentBlue,
                  ),
                ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          if (_error != null) ...[
            Text(
              _error!,
              style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ] else if (_isLoading) ...[
            Text(
              'Cargando estadísticas...',
              style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ] else ...[
            // Stats
            _buildStatRow(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Total escaneados',
              value: _totalScanned.toString(),
              color: AppTheme.accentBlue,
            ),
            _buildDivider(),
            _buildStatRow(
              icon: Icons.check_circle_outline_rounded,
              label: 'Estudiantes presentes',
              value: _presentStudents.toString(),
              color: AppTheme.successColor,
            ),
            _buildDivider(),
            _buildStatRow(
              icon: Icons.schedule_rounded,
              label: 'Estudiantes tarde',
              value: _lateStudents.toString(),
              color: AppTheme.warningColor,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: widget.screenSize.shortestSide * 0.05,
          ),
          SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
          Expanded(
            child: Text(
              label,
              style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.getBodyLarge(widget.screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.3,
      ),
      child: Divider(
        color: AppTheme.getBorderColor(context),
        thickness: 1,
        height: 1,
      ),
    );
  }
}
