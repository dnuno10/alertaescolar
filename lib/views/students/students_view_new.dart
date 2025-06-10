import 'package:alertaescolar/components/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';
import 'add_student_view.dart';
import 'student_detail_view.dart';

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
                  _buildHeader(context, l10n, screenSize),
                  _buildStudentsSection(context, isWide, l10n, screenSize),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.getCardColor(context),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              children: [
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  l10n.myStudents,
                  style: AppTheme.getH1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
              return _buildLoadingState(context, l10n, screenSize);
            }

            if (studentProvider.error != null) {
              return _buildErrorState(
                  context, studentProvider, l10n, screenSize);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                _buildSectionTitle(
                    context, studentProvider.students.length, l10n, screenSize),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                if (studentProvider.students.isEmpty)
                  _buildEmptyState(context, l10n, screenSize)
                else
                  _buildStudentsList(
                      context, studentProvider.students, isWide, screenSize),
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

  Widget _buildSectionTitle(BuildContext context, int studentCount,
      AppLocalizations l10n, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.registeredStudents,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Text(
          studentCount > 0
              ? l10n.studentsLinked(studentCount)
              : l10n.noStudentsLinked,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList(BuildContext context, List<Alumno> students,
      bool isWide, Size screenSize) {
    if (isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
          mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
        ),
        itemCount: students.length,
        itemBuilder: (context, index) => StudentCard(
          student: students[index],
          screenSize: screenSize,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
      itemBuilder: (context, index) => StudentCard(
        student: students[index],
        screenSize: screenSize,
      ),
    );
  }

  Widget _buildLoadingState(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.accentPurple,
              strokeWidth: 3,
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              l10n.loadingStudents,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, StudentProvider studentProvider,
      AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      margin:
          EdgeInsets.symmetric(vertical: AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Container(
            width: screenSize.width * 0.16,
            height: screenSize.width * 0.16,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.error_outline,
              size: screenSize.width * 0.08,
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.errorLoadingStudents,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            studentProvider.error!,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => studentProvider.loadStudents(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: AppTheme.onPrimaryColor,
                padding: EdgeInsets.symmetric(
                    vertical: AppTheme.getSmallPadding(screenSize)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.refresh,
                size: screenSize.width * 0.05,
                color: AppTheme.onPrimaryColor,
              ),
              label: Text(
                l10n.retry,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Container(
            width: screenSize.width * 0.2,
            height: screenSize.width * 0.2,
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.width * 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noStudentsRegistered,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.addFirstStudentInstructions,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

class StudentCard extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const StudentCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor
    ];
    final color = colors[student.hashCode % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToStudentDetail(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              children: [
                Container(
                  width: screenSize.width * 0.14,
                  height: screenSize.width * 0.14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      student.nombre.isNotEmpty
                          ? student.nombre[0].toUpperCase()
                          : 'A',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onPrimaryColor,
                        letterSpacing: 0.1,
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
                        style: AppTheme.getSubtitle1(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        student.grado,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.02,
                          vertical: screenSize.height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: student.activo
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.warningColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize) * 0.7),
                        ),
                        child: Text(
                          student.activo ? l10n.active : l10n.inactive,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            fontWeight: FontWeight.w500,
                            color: student.activo
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: screenSize.width * 0.06,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStudentDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailView(student: student),
      ),
    );
  }
}
