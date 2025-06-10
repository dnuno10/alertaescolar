import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../models/models.dart';
import '../../components/custom_card.dart';
import '../../components/empty_state.dart';
import '../../components/loading_indicator.dart';
import '../../app/app_theme.dart';

class AttendanceView extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const AttendanceView({super.key, this.arguments});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? selectedStudentId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Check if student ID was passed from navigation
    if (widget.arguments != null && widget.arguments!['studentId'] != null) {
      selectedStudentId = widget.arguments!['studentId'];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadStudents();
    });
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

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isMobile = constraints.maxWidth <= 600;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: screenSize.height * 0.25, // Dynamic height
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: AppTheme.onPrimaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      l10n.attendance,
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.onPrimaryColor,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accentPurple,
                            AppTheme.accentBlue,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(isMobile
                              ? AppTheme.getSmallPadding(screenSize)
                              : AppTheme.getMediumPadding(screenSize)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenSize.height * 0.05),
                              Text(
                                _formatDateFull(_selectedDay),
                                style:
                                    AppTheme.getBodyMedium(screenSize).copyWith(
                                  color: AppTheme.getOnPrimarySecondaryColor(
                                      context),
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.005),
                              Consumer<StudentProvider>(
                                builder: (context, provider, child) {
                                  final attendanceToday =
                                      _getAttendanceForDate(_selectedDay);
                                  return Text(
                                    attendanceToday.isNotEmpty
                                        ? l10n.attendanceRecordsCount(
                                            attendanceToday.length)
                                        : l10n.noAttendanceRecords,
                                    style: AppTheme.getCaption(screenSize)
                                        .copyWith(
                                      color:
                                          AppTheme.getOnPrimarySecondaryColor(
                                              context),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(screenSize.height * 0.06),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              AppTheme.getLargeRadius(screenSize)),
                          topRight: Radius.circular(
                              AppTheme.getLargeRadius(screenSize)),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.getTextPrimaryColor(context),
                        unselectedLabelColor:
                            AppTheme.getTextSecondaryColor(context),
                        indicatorColor: AppTheme.accentPurple,
                        indicatorWeight: 3,
                        labelStyle: AppTheme.getCaption(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: AppTheme.getCaption(screenSize),
                        tabs: [
                          Tab(
                            icon: const Icon(Icons.calendar_month),
                            text: l10n.calendar,
                          ),
                          Tab(
                            icon: const Icon(Icons.list_alt),
                            text: l10n.list,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                if (studentProvider.isLoading) {
                  return const LoadingIndicator();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCalendarView(
                        studentProvider, l10n, isWide, isMobile, screenSize),
                    _buildListView(
                        studentProvider, l10n, isWide, isMobile, screenSize),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarView(StudentProvider studentProvider,
      AppLocalizations l10n, bool isWide, bool isMobile, Size screenSize) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile
          ? AppTheme.getSmallPadding(screenSize)
          : AppTheme.getMediumPadding(screenSize)),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildStudentFilter(
                          studentProvider.students, l10n, isMobile, screenSize),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      _buildSelectedDayDetails(l10n, isMobile, screenSize),
                    ],
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  flex: 2,
                  child: _buildCalendarWidget(l10n, isMobile, screenSize),
                ),
              ],
            )
          : Column(
              children: [
                _buildStudentFilter(
                    studentProvider.students, l10n, isMobile, screenSize),
                SizedBox(height: AppTheme.paddingMedium),
                _buildCalendarWidget(l10n, isMobile, screenSize),
                SizedBox(height: AppTheme.paddingMedium),
                _buildSelectedDayDetails(l10n, isMobile, screenSize),
              ],
            ),
    );
  }

  Widget _buildCalendarWidget(
      AppLocalizations l10n, bool isMobile, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<Asistencia>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getAttendanceForDate,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
          holidayTextStyle: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.errorColor,
          ),
          defaultTextStyle: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.accentPurple,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.accentPurple.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.accentBlue,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSizeScale: 0.2,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          titleTextStyle: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
          formatButtonDecoration: BoxDecoration(
            color: AppTheme.accentPurple.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          formatButtonTextStyle: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.accentPurple,
            fontWeight: FontWeight.w500,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppTheme.accentPurple,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppTheme.accentPurple,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w500,
          ),
          weekdayStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildListView(StudentProvider studentProvider, AppLocalizations l10n,
      bool isWide, bool isMobile, Size screenSize) {
    return RefreshIndicator(
      onRefresh: () async {
        await studentProvider.loadStudents();
      },
      color: AppTheme.accentPurple,
      backgroundColor: AppTheme.getSurfaceColor(context),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile
            ? AppTheme.getSmallPadding(screenSize)
            : AppTheme.getMediumPadding(screenSize)),
        child: Column(
          children: [
            _buildStudentFilter(
                studentProvider.students, l10n, isMobile, screenSize),
            SizedBox(height: AppTheme.paddingMedium),
            _buildDateSelector(l10n, isMobile, screenSize),
            SizedBox(height: AppTheme.paddingMedium),
            _buildAttendanceList(
                studentProvider.students, l10n, isWide, isMobile, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentFilter(List<Alumno> students, AppLocalizations l10n,
      bool isMobile, Size screenSize) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile
            ? AppTheme.getSmallPadding(screenSize)
            : AppTheme.getMediumPadding(screenSize)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenSize.width * 0.02),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: AppTheme.accentPurple,
                    size: screenSize.width * 0.05,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  l10n.filterByStudent,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            DropdownButtonFormField<String?>(
              value: selectedStudentId,
              dropdownColor: AppTheme.getSurfaceColor(context),
              decoration: InputDecoration(
                hintText: l10n.allStudents,
                hintStyle: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  borderSide:
                      BorderSide(color: AppTheme.getBorderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  borderSide:
                      BorderSide(color: AppTheme.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  borderSide: const BorderSide(color: AppTheme.accentPurple),
                ),
                prefixIcon: Icon(Icons.person_outline,
                    color: AppTheme.getTextSecondaryColor(context)),
                fillColor: AppTheme.getInputFillColor(context),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize)),
              ),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    l10n.allStudents,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                ),
                ...students.map((student) => DropdownMenuItem<String?>(
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
                  selectedStudentId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
      AppLocalizations l10n, bool isMobile, Size screenSize) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile
            ? AppTheme.getSmallPadding(screenSize)
            : AppTheme.getMediumPadding(screenSize)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenSize.width * 0.02),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: AppTheme.accentBlue,
                    size: screenSize.width * 0.05,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  l10n.selectDate,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            InkWell(
              onTap: _selectDate,
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize)),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  color: AppTheme.getInputFillColor(context),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: AppTheme.accentBlue,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      _formatDate(_selectedDay),
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetails(
      AppLocalizations l10n, bool isMobile, Size screenSize) {
    final attendanceRecords = _getAttendanceForDate(_selectedDay);

    if (attendanceRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile
            ? AppTheme.getMediumPadding(screenSize)
            : AppTheme.getLargePadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getInputFillColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: screenSize.height * 0.06,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.noRecordsForDate(_formatDate(_selectedDay)),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile
                ? AppTheme.getSmallPadding(screenSize)
                : AppTheme.getMediumPadding(screenSize)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenSize.width * 0.02),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.event_available,
                    color: AppTheme.accentBlue,
                    size: screenSize.width * 0.05,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Flexible(
                  child: Text(
                    l10n.attendanceForDate(_formatDate(_selectedDay)),
                    style: AppTheme.getSubtitle1(screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile
                  ? AppTheme.getSmallPadding(screenSize)
                  : AppTheme.getMediumPadding(screenSize),
              0,
              isMobile
                  ? AppTheme.getSmallPadding(screenSize)
                  : AppTheme.getMediumPadding(screenSize),
              isMobile
                  ? AppTheme.getSmallPadding(screenSize)
                  : AppTheme.getMediumPadding(screenSize),
            ),
            child: Column(
              children: attendanceRecords.map((record) {
                return _buildAttendanceRecord(record, l10n, screenSize);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(List<Alumno> students, AppLocalizations l10n,
      bool isWide, bool isMobile, Size screenSize) {
    final filteredStudents = selectedStudentId != null
        ? students.where((s) => s.id == selectedStudentId).toList()
        : students;

    if (filteredStudents.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_outlined,
        title: l10n.noAttendanceData,
        message: l10n.noAttendanceDataSubtitle,
      );
    }

    if (isWide) {
      // Grid layout for wide screens
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
          mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
          childAspectRatio: 1.2,
        ),
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          final student = filteredStudents[index];
          final attendanceRecords = _getAttendanceForStudent(student.id);
          return _buildStudentAttendanceCard(
              student, attendanceRecords, l10n, isMobile, screenSize);
        },
      );
    }

    return Column(
      children: filteredStudents.map((student) {
        final attendanceRecords = _getAttendanceForStudent(student.id);
        return Padding(
          padding:
              EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
          child: _buildStudentAttendanceCard(
              student, attendanceRecords, l10n, isMobile, screenSize),
        );
      }).toList(),
    );
  }

  Widget _buildStudentAttendanceCard(
    Alumno student,
    List<Asistencia> attendanceRecords,
    AppLocalizations l10n,
    bool isMobile,
    Size screenSize,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile
            ? AppTheme.getSmallPadding(screenSize)
            : AppTheme.getMediumPadding(screenSize)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: screenSize.width * 0.12,
                  height: screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentPurple,
                        AppTheme.accentBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                  ),
                  child: Center(
                    child: Text(
                      student.nombre.isNotEmpty
                          ? student.nombre[0].toUpperCase()
                          : 'E',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.onPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.nombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      Text(
                        l10n.gradeLabel(student.grado),
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAttendanceStats(attendanceRecords, l10n, screenSize),
              ],
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            if (attendanceRecords.isNotEmpty) ...[
              Text(
                l10n.recentAttendance,
                style: AppTheme.getCaption(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              ...attendanceRecords.take(5).map(
                    (record) =>
                        _buildAttendanceRecord(record, l10n, screenSize),
                  ),
            ] else
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    vertical: AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: AppTheme.getInputFillColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      color: AppTheme.getTextSecondaryColor(context),
                      size: screenSize.height * 0.04,
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Text(
                      l10n.noAttendanceRecords,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStats(
      List<Asistencia> records, AppLocalizations l10n, Size screenSize) {
    if (records.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(screenSize),
            vertical: screenSize.height * 0.008),
        decoration: BoxDecoration(
          color: AppTheme.getInputFillColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
        child: Text(
          l10n.noData,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      );
    }

    final present =
        records.where((r) => r.estado == EstadoAsistencia.presente).length;
    final total = records.length;
    final percentage = (present / total * 100).round();

    Color backgroundColor;
    String text;

    if (percentage >= 90) {
      backgroundColor = AppTheme.successColor;
      text = l10n.excellent;
    } else if (percentage >= 75) {
      backgroundColor = AppTheme.warningColor;
      text = l10n.good;
    } else {
      backgroundColor = AppTheme.errorColor;
      text = l10n.needsImprovement;
    }

    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(screenSize),
            vertical: screenSize.height * 0.008),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
        child: Text(
          l10n.attendancePercentage(percentage, text),
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.onErrorColor,
            fontWeight: FontWeight.w600,
          ),
        ));
  }

  Widget _buildAttendanceRecord(
      Asistencia record, AppLocalizations l10n, Size screenSize) {
    IconData icon;
    Color color;
    String status;

    switch (record.estado) {
      case EstadoAsistencia.presente:
        icon = Icons.check_circle;
        color = AppTheme.successColor;
        status = l10n.present;
        break;
      case EstadoAsistencia.ausente:
        icon = Icons.cancel;
        color = AppTheme.errorColor;
        status = l10n.absent;
        break;
      case EstadoAsistencia.tarde:
        icon = Icons.access_time;
        color = AppTheme.warningColor;
        status = l10n.late;
        break;
      case EstadoAsistencia.permisoEspecial:
        icon = Icons.verified_user;
        color = AppTheme.infoColor;
        status = l10n.specialPermission;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: screenSize.height * 0.01),
      child: Row(
        children: [
          Icon(icon, color: color, size: screenSize.width * 0.05),
          SizedBox(width: screenSize.width * 0.02),
          Text(
            status,
            style: AppTheme.getCaption(screenSize).copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            _formatTime(record.horaEntrada ?? record.fecha),
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.accentPurple,
                  surface: AppTheme.getSurfaceColor(context),
                  onSurface: AppTheme.getTextPrimaryColor(context),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        _focusedDay = picked;
      });
    }
  }

  List<Asistencia> _getAttendanceForDate(DateTime date) {
    // Mock data - replace with actual data fetching
    return [];
  }

  List<Asistencia> _getAttendanceForStudent(String studentId) {
    // Mock data - replace with actual data fetching
    return [];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateFull(DateTime date) {
    final l10n = AppLocalizations.of(context);
    return l10n.fullDateFormat(date.day, l10n.monthName(date.month), date.year);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
