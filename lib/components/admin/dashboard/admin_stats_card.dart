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
  int _totalScanned = 0;
  int _presentStudents = 0;
  int _lateStudents = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodayStats();
  }

  Future<void> _loadTodayStats() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final escuelaId = userProvider.currentUser?.escuelaId;

      if (escuelaId == null) {
        setState(() {
          _error = 'No se pudo obtener la escuela del usuario';
          _isLoading = false;
        });
        return;
      }

      final supabase = Supabase.instance.client;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get today's attendance notifications
      final response = await supabase
          .from('notificaciones')
          .select('''
            tipo_notificacion,
            alumnos!inner(
              id_escuela
            )
          ''')
          .eq('alumnos.id_escuela', escuelaId)
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso'])
          .gte('fecha_registro', startOfDay.toIso8601String())
          .lt('fecha_registro', endOfDay.toIso8601String());

      final notifications = List<Map<String, dynamic>>.from(response);

      // Count different types of notifications
      int totalScanned = notifications.length;
      int presentStudents = notifications
          .where((n) => n['tipo_notificacion'] == 'entrada')
          .length;
      int lateStudents = notifications
          .where((n) => n['tipo_notificacion'] == 'retraso')
          .length;

      setState(() {
        _totalScanned = totalScanned;
        _presentStudents = presentStudents;
        _lateStudents = lateStudents;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading today stats: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = DateTime.now();

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.1),
            blurRadius: widget.screenSize.height * 0.02,
            offset: Offset(0, widget.screenSize.height * 0.008),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with modern design
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize)),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Text(
                  today.day.toString(),
                  style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
              Text(
                l10n.todayAttendance,
                style: AppTheme.getH2(widget.screenSize).copyWith(
                  fontSize: MediaQuery.of(context).size.height * 0.023,
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Stats items with improved layout
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
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
                      'Error al cargar estadísticas',
                      style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ModernStatItem(
                    icon: Icons.qr_code_2_rounded,
                    color: AppTheme.accentBlue,
                    value: _totalScanned.toString(),
                    label: l10n.totalScanned,
                    screenSize: widget.screenSize,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: _ModernStatItem(
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.successColor,
                    value: _presentStudents.toString(),
                    label: l10n.presentStudents,
                    screenSize: widget.screenSize,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: _ModernStatItem(
                    icon: Icons.schedule_rounded,
                    color: AppTheme.warningColor,
                    value: _lateStudents.toString(),
                    label: l10n.lateStudents,
                    screenSize: widget.screenSize,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ModernStatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final Size screenSize;

  const _ModernStatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular icon container
        Container(
          width: screenSize.width * 0.15,
          height: screenSize.width * 0.15,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: screenSize.width * 0.07,
          ),
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Value with larger, bold typography
        Text(
          value,
          style: AppTheme.getH1(screenSize).copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),

        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

        // Label with proper spacing
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
