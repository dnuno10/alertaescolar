import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/tips_cards/student_edit_info_card.dart';
import 'package:alertaescolar/components/students/student_profile_card.dart';
import 'package:alertaescolar/components/students/student_academic_info_card.dart';
import 'package:alertaescolar/components/students/student_key_info_card.dart';
import 'package:alertaescolar/components/students/student_action_buttons.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../app/app_theme.dart';
import '../schedule/schedule_view.dart';
import '../school/school_info_view.dart';

class StudentDetailView extends StatelessWidget {
  final Alumno student;

  const StudentDetailView({
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
      AppTheme.warningColor
    ];
    final color = colors[student.hashCode % colors.length];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.details),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: AppTheme.getMediumPadding(screenSize),
                      right: AppTheme.getMediumPadding(screenSize),
                      bottom: AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
                      StudentProfileCard(
                        student: student,
                        color: color,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      SolidButton(
                          backgroundColor: AppTheme.accentBlue,
                          onPressed: () => _viewSchoolInfo(context),
                          label: l10n.schoolInfo,
                          width: double.infinity,
                          icon: Icons.school_rounded,
                          screenSize: screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      SolidButton(
                          backgroundColor: AppTheme.accentPurple,
                          onPressed: () => _viewSchedule(context),
                          label: l10n.viewSchedule,
                          width: double.infinity,
                          icon: Icons.schedule_rounded,
                          screenSize: screenSize),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      StudentAcademicInfoCard(
                        student: student,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      StudentKeyInfoCard(
                        student: student,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      StudentEditInfoCard(
                        l10n: l10n,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
                      StudentActionButtons(
                        student: student,
                        screenSize: screenSize,
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

  void _viewSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleView(student: student),
      ),
    );
  }

  void _viewSchoolInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SchoolInfoView(),
      ),
    );
  }
}
