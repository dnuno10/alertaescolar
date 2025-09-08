import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/user_provider.dart';

class AdminStatsCard extends StatefulWidget {
  final Size screenSize;

  const AdminStatsCard({
    super.key,
    required this.screenSize,
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

  ({DateTime startUtc, DateTime endUtc}) _todayUtcRangeFromLocal() {
    final nowLocal = DateTime.now();
    final startOfDayLocal =
        DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final endOfDayLocal = startOfDayLocal.add(const Duration(days: 1));
    return (startUtc: startOfDayLocal.toUtc(), endUtc: endOfDayLocal.toUtc());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _userProvider = Provider.of<UserProvider>(context, listen: false);

      _userProviderListener = () async {
        try {
          final isLoggedIn = _userProvider?.isLoggedIn ?? false;
          final newEscuelaId = _userProvider?.currentUser?.escuelaId ?? '';

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

          if (newEscuelaId.isNotEmpty && newEscuelaId != _escuelaIdInUse) {
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
    _realtimeChannel = _supabase.channel('rt-notificaciones-stats-card')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notificaciones',
        callback: (_) {
          _debounceReloadTimer?.cancel();
          _debounceReloadTimer = Timer(
            Duration(
                milliseconds: (widget.screenSize.shortestSide * 0.4).round()),
            () {
              if (mounted) _loadTodayStats();
            },
          );
        },
      )
      ..subscribe();
  }

  Future<void> _loadTodayStats() async {
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

      final range = _todayUtcRangeFromLocal();
      final startIso = range.startUtc.toIso8601String();
      final endIso = range.endUtc.toIso8601String();

      final totalRows = await _supabase
          .from('notificaciones')
          .select('id, tipo_notificacion, alumnos!inner(id_escuela)')
          .eq('alumnos.id_escuela', escuelaId)
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso'])
          .gte('fecha_registro', startIso)
          .lt('fecha_registro', endIso);

      final entradasRows = await _supabase
          .from('notificaciones')
          .select('id, alumnos!inner(id_escuela)')
          .eq('alumnos.id_escuela', escuelaId)
          .eq('tipo_notificacion', 'entrada')
          .gte('fecha_registro', startIso)
          .lt('fecha_registro', endIso);

      final retrasosRows = await _supabase
          .from('notificaciones')
          .select('id, alumnos!inner(id_escuela)')
          .eq('alumnos.id_escuela', escuelaId)
          .eq('tipo_notificacion', 'retraso')
          .gte('fecha_registro', startIso)
          .lt('fecha_registro', endIso);

      if (!mounted) return;
      setState(() {
        _totalScanned = (totalRows as List).length;
        _presentStudents = (entradasRows as List).length;
        _lateStudents = (retrasosRows as List).length;
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
    final today = DateTime.now();

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header simple sin icono
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todayAttendance,
                style: AppTheme.getH2(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Hoy, ${today.day}',
                style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (_isLoading)
            Container(
              height: widget.screenSize.height * 0.12,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: widget.screenSize.width * 0.05,
                      height: widget.screenSize.width * 0.05,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                    SizedBox(
                        height:
                            AppTheme.getSmallPadding(widget.screenSize) * 0.8),
                    Text(
                      'Cargando...',
                      style:
                          AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_error != null)
            Container(
              padding: EdgeInsets.all(
                  AppTheme.getSmallPadding(widget.screenSize) * 1.5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: widget.screenSize.width * 0.04,
                    color: Colors.red,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
                  Expanded(
                    child: Text(
                      'Error al cargar datos',
                      style: AppTheme.getCaption(widget.screenSize).copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Diseño tipo transacciones de la imagen
            Column(
              children: [
                _buildStatRow(
                  context: context,
                  icon: Icons.qr_code_2_rounded,
                  title: 'Total escaneados',
                  value: _totalScanned.toString(),
                  color: AppTheme.accentBlue,
                  isFirst: true,
                ),
                _buildDivider(),
                _buildStatRow(
                  context: context,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Presentes',
                  value: _presentStudents.toString(),
                  color: Colors.green,
                ),
                _buildDivider(),
                _buildStatRow(
                  context: context,
                  icon: Icons.schedule_rounded,
                  title: 'Tardanzas',
                  value: _lateStudents.toString(),
                  color: Colors.orange,
                  isLast: true,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    // Calcular tamaño de font basado en la longitud del número
    double fontSize;
    int valueLength = value.length;
    if (valueLength <= 1) {
      fontSize = widget.screenSize.height * 0.032;
    } else if (valueLength <= 2) {
      fontSize = widget.screenSize.height * 0.028;
    } else if (valueLength <= 3) {
      fontSize = widget.screenSize.height * 0.024;
    } else if (valueLength <= 4) {
      fontSize = widget.screenSize.height * 0.020;
    } else if (valueLength <= 5) {
      fontSize = widget.screenSize.height * 0.017;
    } else if (valueLength <= 6) {
      fontSize = widget.screenSize.height * 0.015;
    } else {
      fontSize = widget.screenSize.height * 0.013;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.getSmallPadding(widget.screenSize) * 1.2,
        horizontal: AppTheme.getSmallPadding(widget.screenSize) * 0.8,
      ),
      child: Row(
        children: [
          // Icono con fondo de color
          Container(
            width: widget.screenSize.width * 0.11,
            height: widget.screenSize.width * 0.11,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(widget.screenSize.width * 0.022),
            ),
            child: Icon(
              icon,
              color: color,
              size: widget.screenSize.width * 0.05,
            ),
          ),

          SizedBox(width: AppTheme.getSmallPadding(widget.screenSize) * 1.5),

          // Contenido principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: widget.screenSize.height * 0.002),
                Text(
                  'Registros de hoy',
                  style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Valor
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.screenSize.width * 0.02,
      ),
      height: 1,
      color: AppTheme.getTextSecondaryColor(context).withOpacity(0.08),
    );
  }
}
