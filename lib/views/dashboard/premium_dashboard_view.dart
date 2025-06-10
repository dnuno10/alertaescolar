// 🚀 Premium Dashboard View - Following Fintech/EdTech Design References
import 'package:alertaescolar/views/notifications/notifications_view.dart';
import 'package:alertaescolar/views/students/students_view_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/user_provider.dart';
import '../../managers/student_provider.dart';
import '../../managers/notification_provider.dart';
import '../../app/app_theme.dart';
import '../../components/dashboard_components.dart';
import '../../components/premium_notification_card.dart';
import '../../components/custom_button.dart';
import '../../models/notificacion.dart';
import '../reports/reports_view.dart';

class PremiumDashboardView extends StatefulWidget {
  const PremiumDashboardView({super.key});

  @override
  State<PremiumDashboardView> createState() => _PremiumDashboardViewState();
}

class _PremiumDashboardViewState extends State<PremiumDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<NotificationProvider>().loadNotifications();
    context.read<StudentProvider>().loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 🎨 Premium App Bar with Gradient
          _buildPremiumAppBar(context),

          // 📊 Stats Cards Section
          SliverToBoxAdapter(
            child: _buildStatsSection(),
          ),

          // 🔥 Latest Notifications - PRIORITY SECTION
          SliverToBoxAdapter(
            child: _buildLatestNotificationsSection(context),
          ),

          // 🚀 Quick Actions Grid
          SliverToBoxAdapter(
            child: _buildQuickActionsSection(context),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                Color(0xFF333333),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return Row(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: userProvider.currentUser?.fotoUrl != null
                                  ? Image.network(
                                      userProvider.currentUser!.fotoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Greeting and Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${userProvider.currentUser?.nombre ?? ''} ${userProvider.currentUser?.apellido ?? ''}'
                                          .trim()
                                          .isEmpty
                                      ? 'Usuario'
                                      : '${userProvider.currentUser?.nombre ?? ''} ${userProvider.currentUser?.apellido ?? ''}'
                                          .trim(),
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Notification Bell
                          Consumer<NotificationProvider>(
                            builder: (context, notificationProvider, child) {
                              final unreadCount = notificationProvider
                                  .notifications
                                  .where((n) =>
                                      n.estado != EstadoNotificacion.leida)
                                  .length;

                              return Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              unreadCount > 9
                                                  ? '9+'
                                                  : unreadCount.toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Consumer2<StudentProvider, NotificationProvider>(
        builder: (context, studentProvider, notificationProvider, child) {
          final totalStudents = studentProvider.students.length;
          final activeStudents =
              studentProvider.students.where((s) => s.activo).length;
          final unreadNotifications = notificationProvider.notifications
              .where((n) => n.estado != EstadoNotificacion.leida)
              .length;
          final todayNotifications = notificationProvider.notifications
              .where((n) => _isToday(n.fechaHora))
              .length;

          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              StatsCard(
                label: 'Total Estudiantes',
                value: totalStudents.toString(),
                icon: Icons.group_outlined,
                color: AppTheme.accentBlue,
                trend: '+2',
                isPositiveTrend: true,
              ),
              StatsCard(
                label: 'Estudiantes Activos',
                value: activeStudents.toString(),
                icon: Icons.school_outlined,
                color: AppTheme.successColor,
                trend: '98%',
                isPositiveTrend: true,
              ),
              StatsCard(
                label: 'Sin Leer',
                value: unreadNotifications.toString(),
                icon: Icons.notifications_active_outlined,
                color: AppTheme.warningColor,
              ),
              StatsCard(
                label: 'Hoy',
                value: todayNotifications.toString(),
                icon: Icons.today_outlined,
                color: AppTheme.accentPurple,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLatestNotificationsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Text(
                '🔥 Últimas Notificaciones',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimaryLight,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Ver todas',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsView(),
                    ),
                  );
                },
                variant: ButtonVariant.ghost,
                size: ButtonSize.small,
                customColor: AppTheme.primaryColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Latest Notifications List
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }

              final latestNotifications =
                  notificationProvider.notifications.take(3).toList();

              if (latestNotifications.isEmpty) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusLarge),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 32,
                          color: AppTheme.textSecondaryLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No hay notificaciones',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: latestNotifications.map((notification) {
                  return PremiumNotificationCard(
                    title: notification.titulo,
                    message: notification.mensaje,
                    studentName:
                        null, // We can fetch student name by alumnoId if needed
                    timestamp: notification.fechaHora,
                    type: notification.tipo.name,
                    isUnread: notification.estado != EstadoNotificacion.leida,
                    showDismiss: false,
                    onTap: () {
                      // Mark as read and navigate to detail
                      notificationProvider.markAsRead(notification.id);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryLight,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              DashboardSectionCard(
                title: 'Estudiantes',
                subtitle: 'Gestionar estudiantes',
                icon: Icons.group_outlined,
                backgroundColor: AppTheme.accentBlue.withOpacity(0.1),
                foregroundColor: AppTheme.accentBlue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StudentsView(),
                    ),
                  );
                },
              ),
              DashboardSectionCard(
                title: 'Reportes',
                subtitle: 'Ver estadísticas',
                icon: Icons.analytics_outlined,
                backgroundColor: AppTheme.accentPurple.withOpacity(0.1),
                foregroundColor: AppTheme.accentPurple,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReportsView(),
                    ),
                  );
                },
              ),
              DashboardSectionCard(
                title: 'Asistencia',
                subtitle: 'Control de asistencia',
                icon: Icons.calendar_month_outlined,
                backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                foregroundColor: AppTheme.warningColor,
                onTap: () {
                  Navigator.pushNamed(context, '/attendance');
                },
              ),
              DashboardSectionCard(
                title: 'Configuración',
                subtitle: 'Ajustes del sistema',
                icon: Icons.settings_outlined,
                backgroundColor: AppTheme.textSecondaryLight.withOpacity(0.1),
                foregroundColor: AppTheme.textSecondaryLight,
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
