import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/students/students_section_title.dart';
import 'package:alertaescolar/components/students/students_list.dart';
import 'package:alertaescolar/components/students/students_loading_state.dart';
import 'package:alertaescolar/components/students/students_error_state.dart';
import 'package:alertaescolar/components/students/students_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../providers/theme_provider.dart';
import '../../app/app_theme.dart';
import 'add_student_view.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getShadowColor(context),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(
                              AppTheme.getMediumPadding(screenSize)),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                    AppTheme.getSmallPadding(screenSize)),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentPurple
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getMediumRadius(screenSize)),
                                ),
                                child: Icon(
                                  Icons.school_rounded,
                                  color: AppTheme.accentPurple,
                                  size: screenSize.height * 0.03,
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.myStudents,
                                      style:
                                          AppTheme.getH1(screenSize).copyWith(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      'Visualiza y gestiona tus estudiantes',
                                      style: AppTheme.getCaption(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildStudentsSection(context, isWide, l10n, screenSize),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentsSection(BuildContext context, bool isWide,
      AppLocalizations l10n, Size screenSize) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getMediumPadding(screenSize)),
        child: Consumer<StudentProvider>(
          builder: (context, studentProvider, child) {
            if (studentProvider.isLoading) {
              return StudentsLoadingState(screenSize: screenSize);
            }

            if (studentProvider.error != null) {
              return StudentsErrorState(
                studentProvider: studentProvider,
                screenSize: screenSize,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                StudentsSectionTitle(
                  studentCount: studentProvider.students.length,
                  screenSize: screenSize,
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                if (studentProvider.students.isEmpty)
                  StudentsEmptyState(screenSize: screenSize)
                else
                  StudentsList(
                    students: studentProvider.students,
                    isWide: isWide,
                    screenSize: screenSize,
                  ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                SolidButton(
                    width: double.infinity,
                    icon: Icons.person_add_rounded,
                    onPressed: () => _navigateToAddStudent(context),
                    label: l10n.addStudent,
                    screenSize: screenSize),
                SizedBox(height: AppTheme.getLargePadding(screenSize)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToAddStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStudentView(),
      ),
    );
  }
}
