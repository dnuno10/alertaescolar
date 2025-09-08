// lib/views/home/home_view.dart
import 'package:alertaescolar/components/headers/home_header.dart';
import 'package:alertaescolar/components/navigation/custom_bottom_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:alertaescolar/components/notifications/notification_detail_modal.dart';
import 'package:alertaescolar/components/notifications/recent_notifications_section.dart';
import 'package:alertaescolar/components/quick_actions_section.dart';
import 'package:alertaescolar/components/schedule/today_schedule_section.dart';
import 'package:alertaescolar/components/students/students_overview_section.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/views/user/students/students_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/notification_provider.dart';
import '../../user/notifications/notifications_view.dart';
import '../../user/profile/profile_view.dart';
import '../../../managers/schedule_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // ▶ Nuevos: control fino de recargas
  String? _lastUserId;
  TipoUsuario? _lastUserTipo;
  bool _isInitLoading = false;
  UserProvider? _userProv; // para administrar el listener

  late final VoidCallback _userListener = () {
    final u = _userProv?.currentUser;
    final newId = u?.id;
    final newTipo = u?.tipo;

    final changedUser = newId != _lastUserId;
    final changedRole = newTipo != _lastUserTipo;

    if (changedUser || changedRole) {
      _lastUserId = newId;
      _lastUserTipo = newTipo;
      // re-carga sólo si hay usuario y no es admin
      if (u != null && u.tipo != TipoUsuario.administrador) {
        _loadInitialData(); // protegido por _isInitLoading
      }
    }
  };

  @override
  void initState() {
    super.initState();
    // Primera carga diferida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primeAndLoad();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Conectar/desconectar listener de UserProvider cuando cambia el árbol
    final prov = Provider.of<UserProvider>(context);
    if (!identical(_userProv, prov)) {
      _userProv?.removeListener(_userListener);
      _userProv = prov;
      _userProv?.addListener(_userListener);
      // Actualiza memoria local de identidad/rol
      _lastUserId = prov.currentUser?.id;
      _lastUserTipo = prov.currentUser?.tipo;
    }
  }

  @override
  void dispose() {
    _userProv?.removeListener(_userListener);
    super.dispose();
  }

  Future<void> _primeAndLoad() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Guarda la identidad/rol actual para decisiones posteriores
    _lastUserId = userProvider.currentUser?.id;
    _lastUserTipo = userProvider.currentUser?.tipo;
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_isInitLoading || !mounted) return;
    _isInitLoading = true;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);

      final currentUser = userProvider.currentUser;

      // Si no hay usuario, o es admin, no cargamos módulos de tutor
      if (currentUser == null ||
          currentUser.tipo == TipoUsuario.administrador) {
        return;
      }

      // Cargas iniciales
      await Future.wait([
        notificationProvider.loadNotifications(),
        studentProvider.loadStudentsForUser(userId: currentUser.id),
      ]);

      // Realtime: notificaciones
      await notificationProvider.startRealtimeForCurrentUser();

      // Realtime: estudiantes (API explícita existente en tu StudentProvider)
      await studentProvider.startRealtimeForTutor(currentUser.id);

      // Realtime: horario (si existe el método en ScheduleProvider)
      try {
        final sch = scheduleProvider as dynamic;
        await (sch.startRealtimeForTutor?.call(currentUser.id) ??
            Future.value());
      } catch (_) {
        // noop
      }
    } finally {
      _isInitLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              HomeHeader(screenSize: screenSize),
              SliverToBoxAdapter(child: _buildMainContent(context, screenSize)),
            ],
          ),
          const StudentsView(),
          const NotificationsView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          HapticFeedback.mediumImpact();
          setState(() => _selectedIndex = index);
        },
        screenSize: screenSize,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RecentNotificationsSection ya se alimenta del Provider internamente.
          RecentNotificationsSection(
            screenSize: screenSize,
            onTapSeeAll: () {
              HapticFeedback.mediumImpact();
              setState(() => _selectedIndex = 2);
            },
            onNotificationTap: (String notificationId) async {
              final np = context.read<NotificationProvider>();
              await np.markAsRead(notificationId);

              // Cambia a la pestaña de notificaciones
              setState(() => _selectedIndex = 2);

              // Abre modal con el detalle (si sigue presente en memoria)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final notification = np.getNotificationById(notificationId);
                if (notification != null) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: NotificationDetailModal(
                          notification: notification,
                          screenSize: screenSize,
                        ),
                      ),
                    ),
                  );
                }
              });
            },
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
          StudentsOverviewSection(
            screenSize: screenSize,
            onTapViewAll: () {
              HapticFeedback.mediumImpact();
              setState(() => _selectedIndex = 1);
            },
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
          TodayScheduleSection(screenSize: screenSize),
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
          QuickActionsSection(
            screenSize: screenSize,
            onActionSelected: (index) {
              HapticFeedback.mediumImpact();
              setState(() => _selectedIndex = index);
            },
          ),
          SizedBox(height: screenSize.height * 0.12),
        ],
      ),
    );
  }
}
