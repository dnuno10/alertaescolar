import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/admin/attendance/attendance_calendar.dart';
import '../../../components/admin/attendance/enhanced_date_details.dart';
import '../../../components/admin/attendance/calendar_explanation_header.dart';

class AttendanceCalendarView extends StatefulWidget {
  const AttendanceCalendarView({super.key});

  @override
  State<AttendanceCalendarView> createState() => _AttendanceCalendarViewState();
}

class _AttendanceCalendarViewState extends State<AttendanceCalendarView> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.attendanceCalendar),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar Header with explanation
                      CalendarExplanationHeader(screenSize: screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Attendance Calendar
                      AttendanceCalendar(
                        screenSize: screenSize,
                        selectedDay: selectedDate,
                        focusedDay: focusedDay,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            selectedDate = selectedDay;
                            this.focusedDay = focusedDay;
                          });
                        },
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Enhanced Date Details with filters
                      // This component is now safe as it handles localization properly
                      EnhancedDateDetails(
                        screenSize: screenSize,
                        selectedDate: selectedDate,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
