import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/user_provider.dart';
import '../../../views/admin/qr_and_notifications/attendance_calendar_view.dart';

class RecentAttendanceCard extends StatefulWidget {
  final Size screenSize;

  const RecentAttendanceCard({
    super.key,
    required this.screenSize,
  });

  @override
  State<RecentAttendanceCard> createState() => _RecentAttendanceCardState();
}

class _RecentAttendanceCardState extends State<RecentAttendanceCard> {
  List<Map<String, dynamic>> _recentNotifications = [];
  bool _isLoading = true;
  String? _error;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Don't load data here - move to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadRecentNotifications();
    }
  }

  Future<void> _loadRecentNotifications() async {
    final l10n = AppLocalizations.of(context);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final escuelaId = userProvider.currentUser?.escuelaId;

      if (escuelaId == null) {
        setState(() {
          _error = l10n.couldNotGetUserSchool;
          _isLoading = false;
        });
        return;
      }

      final supabase = Supabase.instance.client;

      // Get the last 3 attendance notifications
      final response = await supabase
          .from('notificaciones')
          .select('''
            *,
            alumnos!inner(
              id,
              nombre,
              matricula,
              grupos!inner(
                grupo,
                nivel_educativo
              )
            )
          ''')
          .eq('alumnos.id_escuela', escuelaId)
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso'])
          .order('fecha_registro', ascending: false)
          .limit(3);

      setState(() {
        _recentNotifications = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading recent notifications: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(
                AppTheme.getLargeRadius(widget.screenSize)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: widget.screenSize.height * 0.015,
                offset: Offset(0, widget.screenSize.height * 0.005),
              ),
            ],
          ),
          child: _buildContent(context, l10n),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: widget.screenSize.height * 0.05,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.errorLoadingData,
                style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
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
    final tipoNotificacion = notification['tipo_notificacion'] ?? '';
    final statusColor = _getStatusColor(tipoNotificacion);
    final statusIcon = _getStatusIcon(tipoNotificacion);
    final fechaRegistro = DateTime.parse(notification['fecha_registro']);
    final timeAgo = _getTimeAgo(fechaRegistro, l10n);
    final alumnoNombre = notification['alumnos']['nombre'] ?? 'Estudiante';
    final alumnoGrado =
        '${notification['alumnos']['grupos']['nivel_educativo']} - ${notification['alumnos']['grupos']['grupo']}';

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: screenSize.width * 0.06,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alumnoNombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      timeAgo,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Text(
                        alumnoGrado,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: Text(
                        _getStatusText(tipoNotificacion, l10n),
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
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

    if (difference.inMinutes < 1) {
      return l10n.timeAgoNow; // Replaced hardcoded text
    } else if (difference.inMinutes < 60) {
      return l10n
          .timeAgoMinutes(difference.inMinutes); // Replaced hardcoded text
    } else if (difference.inHours < 24) {
      return l10n.timeAgoHours(difference.inHours); // Replaced hardcoded text
    } else {
      return l10n.timeAgoDays(difference.inDays); // Replaced hardcoded text
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
    return Center(
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
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.startScanningToSeeRecords,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
