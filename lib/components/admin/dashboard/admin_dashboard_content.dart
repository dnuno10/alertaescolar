import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../../app/app_theme.dart';
import '../../headers/home_header.dart';
import 'admin_main_actions.dart';
import 'admin_stats_card.dart';
import 'recent_attendance_card.dart';

class AdminDashboardContent extends StatefulWidget {
  final Size screenSize;

  const AdminDashboardContent({
    super.key,
    required this.screenSize,
  });

  @override
  State<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<AdminDashboardContent> {
  // Callbacks para forzar recarga de componentes hijos
  Future<void> Function()? _recentAttendanceReload;
  Future<void> Function()? _adminStatsReload;

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.getMediumPadding(widget.screenSize);
    final gap = AppTheme.getLargePadding(widget.screenSize);

    Future<void> onRefresh() async {
      // Forzar recarga de los componentes hijos
      final futures = <Future>[];

      // Recargar RecentAttendanceCard
      if (_recentAttendanceReload != null) {
        futures.add(_recentAttendanceReload!());
      }

      // Recargar AdminStatsCard
      if (_adminStatsReload != null) {
        futures.add(_adminStatsReload!());
      }

      // Esperar a que ambos componentes terminen de cargar
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      // Pequeño delay para mejor UX
      await Future.delayed(const Duration(milliseconds: 300));
    }

    return LiquidPullToRefresh(
      onRefresh: onRefresh,
      color: AppTheme.accentPurple,
      backgroundColor: AppTheme.getBackgroundColor(context),
      height: 120,
      animSpeedFactor: 9.0,
      showChildOpacityTransition: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          HomeHeader(screenSize: widget.screenSize),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecentAttendanceCard(
                    screenSize: widget.screenSize,
                    onReloadCallbackSet: (callback) {
                      _recentAttendanceReload = callback;
                    },
                  ),
                  SizedBox(height: gap),
                  AdminMainActions(screenSize: widget.screenSize),
                  SizedBox(height: gap),
                  AdminStatsCard(
                    screenSize: widget.screenSize,
                    onReloadCallbackSet: (callback) {
                      _adminStatsReload = callback;
                    },
                  ),
                  SizedBox(height: gap * 0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
