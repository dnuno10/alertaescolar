import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';
import '../../../views/admin/students/student_attendance_history_view.dart';

class StudentAttendanceHistoryCard extends StatefulWidget {
  final StudentDetails student;
  final Size screenSize;

  const StudentAttendanceHistoryCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  State<StudentAttendanceHistoryCard> createState() =>
      _StudentAttendanceHistoryCardState();
}

class _StudentAttendanceHistoryCardState
    extends State<StudentAttendanceHistoryCard> {
  List<Map<String, dynamic>> _recentNotifications = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentNotifications();
  }

  Future<void> _loadRecentNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Get last 5 notifications for this student
      final response = await supabase
          .from('notificaciones')
          .select('*')
          .eq('id_alumno', widget.student.id)
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso'])
          .order('fecha_registro', ascending: false)
          .limit(5);

      setState(() {
        _recentNotifications = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      debugPrint('Error loading recent notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, int> _calculateAttendanceStats() {
    // Calculate stats from real notification data
    final entrada = _recentNotifications
        .where((r) => r['tipo_notificacion'] == 'entrada')
        .length;
    final salida = _recentNotifications
        .where((r) => r['tipo_notificacion'] == 'salida')
        .length;
    final retraso = _recentNotifications
        .where((r) => r['tipo_notificacion'] == 'retraso')
        .length;
    final total = _recentNotifications.length;

    // Calculate attendance rate (entrada + retraso as present)
    final present = entrada + retraso;
    final rate = total > 0 ? ((present * 100) / total).round() : 0;

    return {
      'entrada': entrada,
      'salida': salida,
      'retraso': retraso,
      'total': total,
      'rate': rate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = _calculateAttendanceStats();

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withOpacity(0.1),
            blurRadius: widget.screenSize.height * 0.02,
            offset: Offset(0, widget.screenSize.height * 0.008),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                    AppTheme.getSmallPadding(widget.screenSize) * 0.6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.successColor.withOpacity(0.1),
                      AppTheme.successColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: AppTheme.successColor,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.attendanceHistory,
                      style: AppTheme.getH2(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Últimos 5 registros',
                      style:
                          AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      AppTheme.getSmallPadding(widget.screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Text(
                  '${stats['rate']}%',
                  style: AppTheme.getCaption(widget.screenSize).copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: widget.screenSize.height * 0.014,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),

          // Recent Records
          if (_isLoading)
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
              child: Column(
                children: [
                  Text('Error al cargar datos: $_error'),
                  ElevatedButton(
                    onPressed: _loadRecentNotifications,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else if (_recentNotifications.isEmpty)
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: widget.screenSize.height * 0.04,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(widget.screenSize)),
                    Text(
                      'No hay registros recientes',
                      style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _recentNotifications.take(3).map((notification) {
                return _buildRecentRecord(context, notification);
              }).toList(),
            ),

          // Statistics Grid
          if (_recentNotifications.isNotEmpty) ...[
            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.getBackgroundColor(context),
                    AppTheme.getBackgroundColor(context).withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                    AppTheme.getMediumRadius(widget.screenSize)),
                border: Border.all(
                  color: AppTheme.getBorderColor(context).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.login_rounded,
                      color: AppTheme.successColor,
                      value: stats['entrada'].toString(),
                      label: 'Entradas',
                      screenSize: widget.screenSize,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: widget.screenSize.height * 0.04,
                    color: AppTheme.getBorderColor(context).withOpacity(0.3),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.schedule_rounded,
                      color: AppTheme.warningColor,
                      value: stats['retraso'].toString(),
                      label: 'Retrasos',
                      screenSize: widget.screenSize,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: widget.screenSize.height * 0.04,
                    color: AppTheme.getBorderColor(context).withOpacity(0.3),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.logout_rounded,
                      color: AppTheme.errorColor,
                      value: stats['salida'].toString(),
                      label: 'Salidas',
                      screenSize: widget.screenSize,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // View All Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentAttendanceHistoryView(
                      student: widget.student,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getMediumPadding(widget.screenSize),
                ),
                backgroundColor: AppTheme.getCardColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(widget.screenSize)),
                  side: BorderSide(
                      color: AppTheme.getBorderColor(context), width: 1),
                ),
              ),
              child: Text(
                l10n.viewAllRecords,
                style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecord(
      BuildContext context, Map<String, dynamic> notification) {
    final tipoNotificacion = notification['tipo_notificacion'] ?? '';
    final fechaRegistro = DateTime.parse(notification['fecha_registro']);
    final titulo = notification['titulo'] ?? '';

    Color typeColor;
    IconData typeIcon;
    String typeText;

    switch (tipoNotificacion) {
      case 'entrada':
        typeColor = AppTheme.successColor;
        typeIcon = Icons.login_rounded;
        typeText = 'Entrada';
        break;
      case 'salida':
        typeColor = AppTheme.errorColor;
        typeIcon = Icons.logout_rounded;
        typeText = 'Salida';
        break;
      case 'retraso':
        typeColor = AppTheme.warningColor;
        typeIcon = Icons.schedule_rounded;
        typeText = 'Retraso';
        break;
      default:
        typeColor = AppTheme.getTextSecondaryColor(context);
        typeIcon = Icons.notifications_rounded;
        typeText = tipoNotificacion;
    }

    return Container(
      margin:
          EdgeInsets.only(bottom: AppTheme.getSmallPadding(widget.screenSize)),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        border: Border.all(
          color: typeColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Type indicator
          Container(
            padding: EdgeInsets.all(
                AppTheme.getSmallPadding(widget.screenSize) * 0.6),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
            ),
            child: Icon(
              typeIcon,
              color: typeColor,
              size: widget.screenSize.height * 0.02,
            ),
          ),

          SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),

          // Notification info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeText,
                  style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                if (titulo.isNotEmpty) ...[
                  SizedBox(
                      height:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.3),
                  Text(
                    titulo,
                    style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Date and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${fechaRegistro.day}/${fechaRegistro.month}/${fechaRegistro.year}',
                style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${fechaRegistro.hour.toString().padLeft(2, '0')}:${fechaRegistro.minute.toString().padLeft(2, '0')}',
                style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final Size screenSize;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: screenSize.height * 0.025,
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        Text(
          value,
          style: AppTheme.getH2(screenSize).copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
