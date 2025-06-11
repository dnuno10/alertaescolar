import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../components/headers/nav_header.dart';
import '../../components/admin/attendance_calendar.dart';
import '../../components/admin/enhanced_date_details.dart';

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
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize)),
                          border: Border.all(
                              color: AppTheme.accentBlue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.accentBlue,
                              size: screenSize.width * 0.06,
                            ),
                            SizedBox(
                                width: AppTheme.getMediumPadding(screenSize)),
                            Expanded(
                              child: Text(
                                'Selecciona un día en el calendario para ver los estudiantes escaneados con sus respectivos tipos de notificación',
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: AppTheme.accentBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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
