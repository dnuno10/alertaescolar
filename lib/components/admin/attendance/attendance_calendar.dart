import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class AttendanceCalendar extends StatelessWidget {
  final Size screenSize;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const AttendanceCalendar({
    super.key,
    required this.screenSize,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Mock attendance data for calendar
    final attendanceData = _generateMockAttendanceData();

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.01,
            offset: Offset(0, screenSize.height * 0.003),
          ),
        ],
      ),
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: (day) {
          final key = _getDateKey(day);
          return attendanceData[key] != null ? [attendanceData[key]!] : [];
        },
        onDaySelected: onDaySelected,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: AppTheme.getTextPrimaryColor(context),
            size: screenSize.height * 0.03,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.getTextPrimaryColor(context),
            size: screenSize.height * 0.03,
          ),
          headerPadding: EdgeInsets.symmetric(
            vertical: AppTheme.getSmallPadding(screenSize),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
            fontSize: screenSize.height * 0.014,
          ),
          weekendStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
            fontSize: screenSize.height * 0.014,
          ),
          dowTextFormatter: (date, locale) {
            // Use abbreviated day names to prevent cutoff
            const dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
            return dayNames[date.weekday - 1];
          },
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
          defaultTextStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
          selectedDecoration: BoxDecoration(
            color: AppTheme.accentPurple,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTheme.getCaption(screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.accentPurple.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.accentPurple,
            fontWeight: FontWeight.w600,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.successColor,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          canMarkersOverflow: false,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              final attendanceRate = _getAttendanceRate(day, attendanceData);
              return Positioned(
                bottom: screenSize.height * 0.003,
                child: Container(
                  width: screenSize.height * 0.008,
                  height: screenSize.height * 0.008,
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(attendanceRate),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Map<String, Map<String, dynamic>> _generateMockAttendanceData() {
    final data = <String, Map<String, dynamic>>{};
    final now = DateTime.now();

    // Generate data for the current month
    for (int i = 1; i <= 30; i++) {
      final date = DateTime(now.year, now.month, i);
      if (date.isAfter(now)) continue; // Don't generate future dates

      final attendanceRate = 0.7 + (i % 3) * 0.1; // Mock attendance rate
      final totalStudents = 250;
      final presentStudents = (totalStudents * attendanceRate).round();
      final lateStudents = (totalStudents * 0.05).round();

      data[_getDateKey(date)] = {
        'date': date,
        'totalStudents': totalStudents,
        'presentStudents': presentStudents,
        'lateStudents': lateStudents,
        'absentStudents': totalStudents - presentStudents - lateStudents,
        'attendanceRate': attendanceRate,
      };
    }

    return data;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double _getAttendanceRate(
      DateTime day, Map<String, Map<String, dynamic>> data) {
    final key = _getDateKey(day);
    return data[key]?['attendanceRate'] ?? 0.0;
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 0.9) return AppTheme.successColor;
    if (rate >= 0.7) return AppTheme.warningColor;
    if (rate >= 0.5) return AppTheme.errorColor;
    return AppTheme.getTextSecondaryColor(null!);
  }
}
