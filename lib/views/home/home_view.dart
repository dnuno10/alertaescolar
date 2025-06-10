import 'package:alertaescolar/views/students/students_view_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../../managers/user_provider.dart';
import '../../managers/student_provider.dart';
import '../../managers/notification_provider.dart';
import '../../models/models.dart';
import '../notifications/notifications_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  int _selectedPeriod = 0; // 0: 7 días, 1: 1 mes
  String? _selectedStudentIdForStats; // For statistics
  String? _selectedStudentIdForSchedule; // For schedule

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    await Future.wait([
      userProvider.loadCurrentUser(),
      studentProvider.loadStudents(),
      notificationProvider.loadNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(context, screenSize),
          const StudentsView(),
          const NotificationsView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(l10n, screenSize),
    );
  }

  Widget _buildHomeContent(BuildContext context, Size screenSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= screenSize.width * 2.25;
        final isTablet = constraints.maxWidth >= screenSize.width * 1.5;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context, screenSize),
            _buildMainContent(context, isWide, isTablet, screenSize),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.getCardColor(context),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                final firstName = user?.nombre?.split(' ').first ?? l10n.user;

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeBack,
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                          SizedBox(
                              height:
                                  AppTheme.getSmallPadding(screenSize) * 0.5),
                          Text(
                            firstName,
                            style: AppTheme.getH1(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenSize.height * 0.06,
                      height: screenSize.height * 0.06,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple,
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentPurple.withValues(alpha: 0.2),
                            blurRadius: screenSize.height * 0.01,
                            offset: Offset(0, screenSize.height * 0.005),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          firstName[0].toUpperCase(),
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, bool isWide, bool isTablet, Size screenSize) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentNotificationsSection(context, screenSize),
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            _buildAttendanceStatistics(context, screenSize),
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            _buildStudentsOverview(context, screenSize),
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            _buildTodaySchedule(context, screenSize),
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 1.5),
            _buildQuickActions(context, screenSize),
            SizedBox(
                height:
                    screenSize.height * 0.12), // Bottom padding for navigation
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotificationsSection(
      BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.recentNotifications,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                final unreadCount = provider.unreadCount;
                if (unreadCount > 0) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.warningColor.withValues(alpha: 0.25),
                            blurRadius: screenSize.height * 0.008,
                            offset: Offset(0, screenSize.height * 0.003),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: screenSize.height * 0.008,
                            height: screenSize.height * 0.008,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(
                              width:
                                  AppTheme.getSmallPadding(screenSize) * 0.5),
                          Text(
                            '$unreadCount ${l10n.newNotifications}',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 2),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Text(
                      l10n.viewAll,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.accentPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        SizedBox(
          height: screenSize.height * 0.2,
          child: Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final recentNotifications =
                  provider.notifications.take(5).toList();

              if (recentNotifications.isEmpty) {
                return _buildEmptyNotifications(context, screenSize);
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: recentNotifications.length,
                itemBuilder: (context, index) {
                  final notification = recentNotifications[index];
                  return _buildEnhancedNotificationCard(
                      notification, index, context, screenSize);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedNotificationCard(Notificacion notification, int index,
      BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
      AppTheme.accentYellow
    ];
    final color = colors[index % colors.length];
    final isUnread = notification.estado != EstadoNotificacion.leida;

    IconData notificationIcon;
    String statusText;
    Color statusColor;

    switch (notification.tipo) {
      case TipoNotificacion.entrada:
        notificationIcon = Icons.login_rounded;
        statusText = l10n.entryRegistered;
        statusColor = AppTheme.successColor;
        break;
      case TipoNotificacion.salida:
        notificationIcon = Icons.logout_rounded;
        statusText = l10n.exitRegistered;
        statusColor = AppTheme.accentBlue;
        break;
      case TipoNotificacion.retraso:
        notificationIcon = Icons.schedule_rounded;
        statusText = l10n.arrivedLate;
        statusColor = AppTheme.warningColor;
        break;
      case TipoNotificacion.ausencia:
        notificationIcon = Icons.cancel_rounded;
        statusText = l10n.absent;
        statusColor = AppTheme.errorColor;
        break;
      case TipoNotificacion.permisoEspecial:
        notificationIcon = Icons.event_available_rounded;
        statusText = l10n.specialPermission;
        statusColor = AppTheme.accentPurple;
        break;
      case TipoNotificacion.alerta:
        notificationIcon = Icons.warning_rounded;
        statusText = l10n.alert;
        statusColor = AppTheme.errorColor;
        break;
      case TipoNotificacion.comunicado:
        notificationIcon = Icons.announcement_rounded;
        statusText = l10n.announcement;
        statusColor = AppTheme.accentBlue;
        break;
      default:
        notificationIcon = Icons.notifications_rounded;
        statusText = l10n.notifications;
        statusColor = color;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        width: screenSize.width * 0.75,
        margin: EdgeInsets.only(right: AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
          border: isUnread
              ? Border.all(color: statusColor, width: 2)
              : Border.all(color: AppTheme.getBorderColor(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? statusColor.withValues(alpha: 0.12)
                  : AppTheme.getShadowColor(context),
              blurRadius: isUnread
                  ? screenSize.height * 0.015
                  : screenSize.height * 0.01,
              offset: Offset(0, screenSize.height * 0.004),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: screenSize.height * 0.05,
                    height: screenSize.height * 0.05,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      notificationIcon,
                      color: Colors.white,
                      size: screenSize.height * 0.025,
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.height * 0.008,
                              vertical: screenSize.height * 0.003),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                screenSize.height * 0.008),
                          ),
                          child: Text(
                            statusText,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.003),
                        Text(
                          _formatTime(notification.fechaHora),
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: screenSize.height * 0.008,
                      height: screenSize.height * 0.008,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  notification.mensaje,
                  style: AppTheme.getSubtitle2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: screenSize.height * 0.015,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  SizedBox(width: screenSize.height * 0.005),
                  Flexible(
                    child: Text(
                      l10n.tapToViewDetails,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildAttendanceStatistics(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.statistics,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodButton(l10n.sevenDays, 0, context, screenSize),
                    SizedBox(width: screenSize.height * 0.005),
                    _buildPeriodButton(l10n.oneMonth, 1, context, screenSize),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          // Student selector for statistics
          Consumer<StudentProvider>(
            builder: (context, studentProvider, child) {
              final students = studentProvider.students;
              if (students.isEmpty) {
                return const SizedBox.shrink();
              }

              // Set default selected student if none selected
              if (_selectedStudentIdForStats == null && students.isNotEmpty) {
                _selectedStudentIdForStats = students.first.id;
              }

              final selectedStudent = students.firstWhere(
                (s) => s.id == _selectedStudentIdForStats,
                orElse: () => students.first,
              );

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  border: Border.all(
                    color: AppTheme.accentPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: screenSize.height * 0.02,
                      color: AppTheme.accentPurple,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      '${l10n.statistics} de: ',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showStudentSelector(
                          context,
                          students,
                          _selectedStudentIdForStats,
                          (studentId) {
                            setState(() {
                              _selectedStudentIdForStats = studentId;
                            });
                          },
                          screenSize,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppTheme.getSmallPadding(screenSize) * 0.75,
                            vertical:
                                AppTheme.getSmallPadding(screenSize) * 0.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple,
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(screenSize) * 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedStudent.nombre,
                                  style:
                                      AppTheme.getCaption(screenSize).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize) *
                                      0.5),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: screenSize.height * 0.018,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Text(
                _selectedPeriod == 0 ? '98%' : '94%',
                style: AppTheme.getH1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPeriod == 0
                          ? l10n.weeklyAttendance
                          : l10n.monthlyAttendance,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenSize.height * 0.005),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.height * 0.008,
                          vertical: screenSize.height * 0.004),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius:
                            BorderRadius.circular(screenSize.height * 0.008),
                      ),
                      child: Text(
                        _selectedPeriod == 0
                            ? l10n.plusFivePercent
                            : l10n.plusTwoPercent,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.check_circle_rounded,
                color: AppTheme.successColor,
                value: _selectedPeriod == 0 ? '7' : '28',
                label: l10n.attendances,
                context: context,
                screenSize: screenSize,
              ),
              _buildStatItem(
                icon: Icons.schedule_rounded,
                color: AppTheme.warningColor,
                value: _selectedPeriod == 0 ? '0' : '3',
                label: l10n.lateArrivals,
                context: context,
                screenSize: screenSize,
              ),
              _buildStatItem(
                icon: Icons.cancel_rounded,
                color: AppTheme.errorColor,
                value: _selectedPeriod == 0 ? '0' : '2',
                label: l10n.absences,
                context: context,
                screenSize: screenSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
      String text, int index, BuildContext context, Size screenSize) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: screenSize.height * 0.015,
            vertical: screenSize.height * 0.008),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(screenSize.height * 0.01),
        ),
        child: Text(
          text,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: isSelected
                ? Colors.white
                : AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsOverview(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myStudents,
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              child: Text(
                l10n.viewAll,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Consumer<StudentProvider>(
          builder: (context, provider, child) {
            final students = provider.students;

            if (students.isEmpty) {
              return _buildEmptyStudents(context, screenSize);
            }

            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: screenSize.height * 0.015,
                    offset: Offset(0, screenSize.height * 0.005),
                  ),
                ],
              ),
              child: Column(
                children: students.take(3).map((student) {
                  final index = students.indexOf(student);
                  return _buildStudentListItem(student, index,
                      students.take(3).length, context, screenSize);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentListItem(Alumno student, int index, int totalVisible,
      BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor
    ];
    final color = colors[index % colors.length];
    final isLast = index == totalVisible - 1;

    return Container(
      margin: EdgeInsets.only(
          bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize)),
      child: Row(
        children: [
          Container(
            width: screenSize.height * 0.06,
            height: screenSize.height * 0.06,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: screenSize.height * 0.008,
                  offset: Offset(0, screenSize.height * 0.003),
                ),
              ],
            ),
            child: Center(
              child: Text(
                student.nombre[0].toUpperCase(),
                style: AppTheme.getH2(screenSize).copyWith(
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nombre,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenSize.height * 0.005),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.height * 0.008,
                          vertical: screenSize.height * 0.003),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(screenSize.height * 0.008),
                      ),
                      child: Text(
                        student.grado,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Container(
                      width: screenSize.height * 0.005,
                      height: screenSize.height * 0.005,
                      decoration: const BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: screenSize.height * 0.005),
                    Text(
                      l10n.active,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.getTextSecondaryColor(context),
            size: screenSize.height * 0.023,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.todaysSchedule,
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            Text(
              DateTime.now().day.toString().padLeft(2, '0') +
                  '/' +
                  DateTime.now().month.toString().padLeft(2, '0'),
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        // Student selector for schedule
        Consumer<StudentProvider>(
          builder: (context, studentProvider, child) {
            final students = studentProvider.students;
            if (students.isEmpty) {
              return const SizedBox.shrink();
            }

            // Set default selected student if none selected
            if (_selectedStudentIdForSchedule == null && students.isNotEmpty) {
              _selectedStudentIdForSchedule = students.first.id;
            }

            final selectedStudent = students.firstWhere(
              (s) => s.id == _selectedStudentIdForSchedule,
              orElse: () => students.first,
            );

            return Container(
              margin: EdgeInsets.only(
                  bottom: AppTheme.getMediumPadding(screenSize)),
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: screenSize.height * 0.02,
                    color: AppTheme.accentBlue,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    '${l10n.todaysSchedule} de: ',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showStudentSelector(
                        context,
                        students,
                        _selectedStudentIdForSchedule,
                        (studentId) {
                          setState(() {
                            _selectedStudentIdForSchedule = studentId;
                          });
                        },
                        screenSize,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              AppTheme.getSmallPadding(screenSize) * 0.75,
                          vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize) * 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                selectedStudent.nombre,
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                                width:
                                    AppTheme.getSmallPadding(screenSize) * 0.5),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: screenSize.height * 0.018,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        _buildScheduleCard(
          time: '08:00 - 12:00',
          title: l10n.morningClasses,
          subject: l10n.mathSpanishSciences,
          color: AppTheme.accentBlue,
          isActive: true,
          context: context,
          screenSize: screenSize,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        _buildScheduleCard(
          time: '14:00 - 16:30',
          title: l10n.afternoonClasses,
          subject: l10n.historyPhysicalEducation,
          color: AppTheme.successColor,
          context: context,
          screenSize: screenSize,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        _buildScheduleCard(
          time: '17:00 - 18:00',
          title: l10n.extracurricularActivities,
          subject: l10n.chessClub,
          color: AppTheme.accentPurple,
          context: context,
          screenSize: screenSize,
        ),
      ],
    );
  }

  Widget _buildScheduleCard({
    required String time,
    required String title,
    required String subject,
    required Color color,
    bool isActive = false,
    required BuildContext context,
    required Size screenSize,
  }) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: isActive ? color : AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: isActive
            ? null
            : Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: screenSize.height * 0.015,
                  offset: Offset(0, screenSize.height * 0.005),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: AppTheme.getSubtitle2(screenSize).copyWith(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.height * 0.01,
                      vertical: screenSize.height * 0.005),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor,
                    borderRadius:
                        BorderRadius.circular(screenSize.height * 0.01),
                  ),
                  child: Text(
                    l10n.inProgress,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            title,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: isActive
                  ? Colors.white
                  : AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            subject,
            style: AppTheme.getSubtitle2(screenSize).copyWith(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.9)
                  : AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: AppTheme.getH2(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: l10n.viewHistory,
                icon: Icons.history_rounded,
                color: AppTheme.accentBlue,
                onTap: () => setState(() => _selectedIndex = 2),
                context: context,
                screenSize: screenSize,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
            Expanded(
              child: _buildActionButton(
                title: l10n.addStudent,
                icon: Icons.person_add_rounded,
                color: AppTheme.successColor,
                onTap: () => setState(() => _selectedIndex = 1),
                context: context,
                screenSize: screenSize,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            title: l10n.myProfile,
            icon: Icons.account_circle_rounded,
            color: AppTheme.accentPurple,
            onTap: () => setState(() => _selectedIndex = 3),
            context: context,
            screenSize: screenSize,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
    required Size screenSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(color: AppTheme.getBorderColor(context)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: screenSize.height * 0.015,
              offset: Offset(0, screenSize.height * 0.005),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: screenSize.height * 0.07,
              height: screenSize.height * 0.07,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: screenSize.height * 0.035,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              title,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required BuildContext context,
    required Size screenSize,
  }) {
    return Column(
      children: [
        Container(
          width: screenSize.height * 0.06,
          height: screenSize.height * 0.06,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: screenSize.height * 0.03,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Text(
          value,
          style: AppTheme.getH2(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(AppLocalizations l10n, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.getLargeRadius(screenSize))),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.06),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, -screenSize.height * 0.008),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: screenSize.width * 0.03,
            right: screenSize.width * 0.03,
            top: screenSize.height * 0.008,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: l10n.homeTitle,
                index: 0,
                isSelected: _selectedIndex == 0,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.people_rounded,
                label: l10n.students,
                index: 1,
                isSelected: _selectedIndex == 1,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItemWithBadge(
                icon: Icons.notifications_rounded,
                label: l10n.notifications,
                index: 2,
                isSelected: _selectedIndex == 2,
                context: context,
                screenSize: screenSize,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                index: 3,
                isSelected: _selectedIndex == 3,
                context: context,
                screenSize: screenSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required BuildContext context,
    required Size screenSize,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.02,
              vertical: screenSize.height * 0.01),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentPurple.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenSize.height * 0.006),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.accentPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.8),
                ),
                child: Icon(
                  icon,
                  size: screenSize.height * 0.025,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.getTextSecondaryColor(context),
                ),
              ),
              SizedBox(height: screenSize.height * 0.003),
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: isSelected
                      ? AppTheme.accentPurple
                      : AppTheme.getTextSecondaryColor(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required BuildContext context,
    required Size screenSize,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.02,
              vertical: screenSize.height * 0.01),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentPurple.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenSize.height * 0.006),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentPurple
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize) * 0.8),
                    ),
                    child: Icon(
                      icon,
                      size: screenSize.height * 0.025,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      final unreadCount = notificationProvider.unreadCount;
                      if (unreadCount > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(screenSize.height * 0.003),
                            decoration: const BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: screenSize.height * 0.018,
                              minHeight: screenSize.height * 0.018,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.003),
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: isSelected
                      ? AppTheme.accentPurple
                      : AppTheme.getTextSecondaryColor(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenSize.height * 0.06,
            height: screenSize.height * 0.06,
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.03,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.noNotifications,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            l10n.notificationsWillAppearHere,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStudents(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: screenSize.height * 0.08,
            height: screenSize.height * 0.08,
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.04,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noStudentsRegistered,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            l10n.addStudentToStart,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: Colors.white,
                padding:
                    EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_rounded,
                      size: screenSize.height * 0.025),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    l10n.addStudent,
                    style: AppTheme.getSubtitle2(screenSize).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  void _showStudentSelector(
    BuildContext context,
    List<Alumno> students,
    String? currentSelectedId,
    Function(String) onStudentSelected,
    Size screenSize,
  ) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.getLargeRadius(screenSize)),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                child: Row(
                  children: [
                    Text(
                      l10n.selectStudent,
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(screenSize.height * 0.008),
                        decoration: BoxDecoration(
                          color: AppTheme.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: screenSize.height * 0.025,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isSelected = student.id == currentSelectedId;
                    final colors = [
                      AppTheme.accentBlue,
                      AppTheme.successColor,
                      AppTheme.accentPurple,
                      AppTheme.warningColor
                    ];
                    final color = colors[index % colors.length];

                    return GestureDetector(
                      onTap: () {
                        onStudentSelected(student.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: AppTheme.getMediumPadding(screenSize),
                          vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                        ),
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.1)
                              : AppTheme.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize)),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : AppTheme.getBorderColor(context),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: screenSize.height * 0.05,
                              height: screenSize.height * 0.05,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(screenSize)),
                              ),
                              child: Center(
                                child: Text(
                                  student.nombre[0].toUpperCase(),
                                  style: AppTheme.getSubtitle1(screenSize)
                                      .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getMediumPadding(screenSize)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.nombre,
                                    style: AppTheme.getBodyMedium(screenSize)
                                        .copyWith(
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: screenSize.height * 0.003),
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
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: color,
                                size: screenSize.height * 0.025,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }
}
