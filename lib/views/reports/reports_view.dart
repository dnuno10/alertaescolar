import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../managers/notification_provider.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';
import '../../components/loading_indicator.dart';
import '../../components/empty_state.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStudentId;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.reportsAndStatistics,
              style: AppTheme.getAppBarTitle(screenSize).copyWith(
                color: AppTheme.onPrimaryColor,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: AppTheme.onPrimaryColor,
              size: screenSize.width * 0.06,
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.onPrimaryColor,
              labelColor: AppTheme.onPrimaryColor,
              unselectedLabelColor: AppTheme.onPrimaryColor.withOpacity(0.7),
              labelStyle: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTheme.getCaption(screenSize),
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.analytics_outlined,
                    size: screenSize.width * 0.05,
                  ),
                  text: l10n.summary,
                ),
                Tab(
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    size: screenSize.width * 0.05,
                  ),
                  text: l10n.attendance,
                ),
                Tab(
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: screenSize.width * 0.05,
                  ),
                  text: l10n.activity,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Filtros
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getShadowColor(context),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StudentFilter(l10n: l10n, screenSize: screenSize),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child:
                          _DateRangeFilter(l10n: l10n, screenSize: screenSize),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ReportsSummary(l10n: l10n, screenSize: screenSize),
                    _AttendanceReport(l10n: l10n, screenSize: screenSize),
                    _ActivityReport(l10n: l10n, screenSize: screenSize),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _StudentFilter(
      {required AppLocalizations l10n, required Size screenSize}) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        return DropdownButtonFormField<String>(
          value: _selectedStudentId,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            labelText: l10n.student,
            labelStyle: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.05,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(color: AppTheme.accentPurple, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: screenSize.height * 0.01,
            ),
            fillColor: AppTheme.getInputFillColor(context),
            filled: true,
          ),
          dropdownColor: AppTheme.getSurfaceColor(context),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                l10n.allStudents,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ),
            ...studentProvider.students
                .map((student) => DropdownMenuItem<String>(
                      value: student.id,
                      child: Text(
                        student.nombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                    )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStudentId = value;
            });
          },
        );
      },
    );
  }

  Widget _DateRangeFilter(
      {required AppLocalizations l10n, required Size screenSize}) {
    return InkWell(
      onTap: () => _selectDateRange(l10n),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.period,
          labelStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
          prefixIcon: Icon(
            Icons.date_range_outlined,
            color: AppTheme.accentPurple,
            size: screenSize.width * 0.05,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(screenSize),
            vertical: screenSize.height * 0.01,
          ),
          fillColor: AppTheme.getInputFillColor(context),
          filled: true,
        ),
        child: Text(
          _selectedDateRange != null
              ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
              : l10n.selectPeriod,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange(AppLocalizations l10n) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.accentPurple,
                  onPrimary: AppTheme.onPrimaryColor,
                  surface: AppTheme.getSurfaceColor(context),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ReportsSummary extends StatelessWidget {
  final AppLocalizations l10n;
  final Size screenSize;

  const _ReportsSummary({required this.l10n, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generalSummary,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Métricas generales
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
            mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                title: l10n.attendance,
                value: '92%',
                subtitle: l10n.lastMonth,
                icon: Icons.check_circle_outline,
                color: AppTheme.successColor,
                screenSize: screenSize,
              ),
              _MetricCard(
                title: l10n.punctuality,
                value: '88%',
                subtitle: l10n.lastMonth,
                icon: Icons.schedule_outlined,
                color: AppTheme.warningColor,
                screenSize: screenSize,
              ),
              _MetricCard(
                title: l10n.notifications,
                value: '24',
                subtitle: l10n.thisWeek,
                icon: Icons.notifications_outlined,
                color: AppTheme.infoColor,
                screenSize: screenSize,
              ),
              _MetricCard(
                title: l10n.events,
                value: '5',
                subtitle: l10n.upcoming,
                icon: Icons.event_outlined,
                color: AppTheme.primaryColor,
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Gráfico de tendencias
          Card(
            color: AppTheme.getCardColor(context),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.attendanceTrend,
                    style: AppTheme.getSubtitle2(screenSize).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  Container(
                    height: screenSize.height * 0.25,
                    decoration: BoxDecoration(
                      color: AppTheme.getNeutralLightColor(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Center(
                      child: Text(
                        l10n.trendChartComingSoon,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceReport extends StatelessWidget {
  final AppLocalizations l10n;
  final Size screenSize;

  const _AttendanceReport({required this.l10n, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (studentProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (!studentProvider.hasStudents) {
          return EmptyState(
            icon: Icons.calendar_today_outlined,
            title: l10n.noAttendanceData,
            message: l10n.noStudentsForAttendanceReport,
          );
        }

        return ListView(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          children: [
            Text(
              l10n.attendanceReport,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            ...studentProvider.students.map((student) => Card(
                  color: AppTheme.getCardColor(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  margin: EdgeInsets.only(
                      bottom: AppTheme.getSmallPadding(screenSize)),
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              radius: screenSize.width * 0.06,
                              child: Text(
                                student.nombre.substring(0, 1).toUpperCase(),
                                style:
                                    AppTheme.getBodyMedium(screenSize).copyWith(
                                  color: AppTheme.onPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getSmallPadding(screenSize)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.nombre,
                                    style: AppTheme.getSubtitle2(screenSize)
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                    ),
                                  ),
                                  Text(
                                    student.grado,
                                    style: AppTheme.getCaption(screenSize)
                                        .copyWith(
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        // Estadísticas de asistencia para este estudiante
                        Row(
                          children: [
                            Expanded(
                              child: _AttendanceStatItem(
                                label: l10n.present,
                                value: '18',
                                color: AppTheme.successColor,
                                screenSize: screenSize,
                              ),
                            ),
                            Expanded(
                              child: _AttendanceStatItem(
                                label: l10n.absent,
                                value: '2',
                                color: AppTheme.errorColor,
                                screenSize: screenSize,
                              ),
                            ),
                            Expanded(
                              child: _AttendanceStatItem(
                                label: l10n.late,
                                value: '3',
                                color: AppTheme.warningColor,
                                screenSize: screenSize,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _ActivityReport extends StatelessWidget {
  final AppLocalizations l10n;
  final Size screenSize;

  const _ActivityReport({required this.l10n, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.isLoading) {
          return const LoadingIndicator();
        }

        final notifications = notificationProvider.notifications;

        if (notifications.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_outlined,
            title: l10n.noActivity,
            message: l10n.noNotificationsInSelectedPeriod,
          );
        }

        // Agrupar notificaciones por tipo
        final notificationsByType = <TipoNotificacion, List<Notificacion>>{};
        for (final notification in notifications) {
          notificationsByType
              .putIfAbsent(notification.tipo, () => [])
              .add(notification);
        }

        return ListView(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          children: [
            Text(
              l10n.activityReport,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Resumen por tipo de notificación
            Card(
              color: AppTheme.getCardColor(context),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.summaryByType,
                      style: AppTheme.getSubtitle2(screenSize).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    ...notificationsByType.entries.map((entry) => Padding(
                          padding:
                              EdgeInsets.only(bottom: screenSize.height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getNotificationTypeName(entry.key, l10n),
                                style:
                                    AppTheme.getBodyMedium(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.02,
                                  vertical: screenSize.height * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: _getNotificationTypeColor(entry.key)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getSmallRadius(screenSize)),
                                ),
                                child: Text(
                                  '${entry.value.length}',
                                  style:
                                      AppTheme.getCaption(screenSize).copyWith(
                                    color: _getNotificationTypeColor(entry.key),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Lista de actividad reciente
            Text(
              l10n.recentActivity,
              style: AppTheme.getSubtitle2(screenSize).copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),

            ...notifications.take(10).map((notification) => Card(
                  color: AppTheme.getCardColor(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                    leading: Container(
                      padding: EdgeInsets.all(screenSize.width * 0.02),
                      decoration: BoxDecoration(
                        color: _getNotificationTypeColor(notification.tipo)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                      child: Icon(
                        _getNotificationTypeIcon(notification.tipo),
                        color: _getNotificationTypeColor(notification.tipo),
                        size: screenSize.width * 0.05,
                      ),
                    ),
                    title: Text(
                      notification.titulo,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    subtitle: Text(
                      notification.mensaje,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    trailing: Text(
                      _formatNotificationDate(notification.fechaHora, l10n),
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  String _getNotificationTypeName(
      TipoNotificacion type, AppLocalizations l10n) {
    switch (type) {
      case TipoNotificacion.entrada:
        return l10n.entries;
      case TipoNotificacion.salida:
        return l10n.exits;
      case TipoNotificacion.retraso:
        return l10n.delays;
      case TipoNotificacion.ausencia:
        return l10n.absences;
      case TipoNotificacion.permisoEspecial:
        return l10n.permissions;
      case TipoNotificacion.alerta:
        return l10n.alerts;
      case TipoNotificacion.comunicado:
        return l10n.announcements;
    }
  }

  Color _getNotificationTypeColor(TipoNotificacion type) {
    switch (type) {
      case TipoNotificacion.entrada:
        return AppTheme.successColor;
      case TipoNotificacion.salida:
        return AppTheme.infoColor;
      case TipoNotificacion.retraso:
        return AppTheme.warningColor;
      case TipoNotificacion.ausencia:
        return AppTheme.errorColor;
      case TipoNotificacion.permisoEspecial:
        return AppTheme.infoColor;
      case TipoNotificacion.alerta:
        return AppTheme.errorColor;
      case TipoNotificacion.comunicado:
        return AppTheme.primaryColor;
    }
  }

  IconData _getNotificationTypeIcon(TipoNotificacion type) {
    switch (type) {
      case TipoNotificacion.entrada:
        return Icons.login_outlined;
      case TipoNotificacion.salida:
        return Icons.logout_outlined;
      case TipoNotificacion.retraso:
        return Icons.schedule_outlined;
      case TipoNotificacion.ausencia:
        return Icons.cancel_outlined;
      case TipoNotificacion.permisoEspecial:
        return Icons.verified_outlined;
      case TipoNotificacion.alerta:
        return Icons.warning_outlined;
      case TipoNotificacion.comunicado:
        return Icons.announcement_outlined;
    }
  }

  String _formatNotificationDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Size screenSize;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.getCardColor(context),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: screenSize.width * 0.08,
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              value,
              style: AppTheme.getH2(screenSize).copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Size screenSize;

  const _AttendanceStatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }
}
