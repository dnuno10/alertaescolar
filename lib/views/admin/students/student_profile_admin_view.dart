import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../models/models.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/students/student_profile_card.dart';
import '../../../components/students/student_academic_info_card.dart';
import '../../../components/students/student_key_info_card.dart';
import '../../../components/admin/students/student_family_info_card.dart';
import '../../../components/admin/students/student_attendance_history_card.dart';

class StudentProfileAdminView extends StatelessWidget {
  final Alumno student;

  const StudentProfileAdminView({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
    ];
    final color = colors[student.hashCode % colors.length];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.studentProfile),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student Profile Card
                      StudentProfileCard(
                        student: student,
                        color: color,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Academic Information
                      StudentAcademicInfoCard(
                        student: student,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Key Information
                      StudentKeyInfoCard(
                        student: student,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Family Information
                      StudentFamilyInfoCard(
                        student: student,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Attendance History
                      StudentAttendanceHistoryCard(
                        student: student,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
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
