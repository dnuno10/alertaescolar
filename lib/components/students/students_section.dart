import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../models/models.dart';
import 'students_section_title.dart';
import 'students_list.dart';
import 'students_loading_state.dart';
import 'students_error_state.dart';
import 'students_empty_state.dart';

class StudentsSection extends StatefulWidget {
  final bool isWide;
  final Size screenSize;
  final VoidCallback?
      onAddStudent; // Make this optional since we'll use floating button

  const StudentsSection({
    super.key,
    required this.isWide,
    required this.screenSize,
    this.onAddStudent, // Make optional
  });

  @override
  State<StudentsSection> createState() => _StudentsSectionState();
}

class _StudentsSectionState extends State<StudentsSection> {
  late List<Alumno> filteredStudents;

  @override
  void initState() {
    super.initState();
    // Initialize with empty list, will be populated in build when provider is available
    filteredStudents = [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer2<StudentProvider, UserProvider>(
      builder: (context, studentProvider, userProvider, child) {
        // Convert StudentDetails to Alumno using the provider's method
        final alumnosList = studentProvider.getAlumnosFromStudents();

        // Update filtered students with the converted list
        if (filteredStudents.isEmpty ||
            filteredStudents.length != alumnosList.length) {
          filteredStudents = List.from(alumnosList);
        }

        if (studentProvider.isLoading) {
          return Container(
            height: widget.screenSize.height * 0.4,
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.accentPurple,
                    strokeWidth: 3,
                  ),
                  SizedBox(
                      height: AppTheme.getMediumPadding(widget.screenSize)),
                  Text(
                    l10n.loadingStudents,
                    style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (studentProvider.error != null) {
          return StudentsErrorState(
            studentProvider: studentProvider,
            screenSize: widget.screenSize,
          );
        }

        // Check if there are no students at all
        if (alumnosList.isEmpty) {
          return StudentsEmptyState(
            screenSize: widget.screenSize,
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getMediumPadding(widget.screenSize),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),

              // Title and student count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.myStudents,
                    style: AppTheme.getH1(widget.screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(widget.screenSize),
                      vertical:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize),
                      ),
                    ),
                    child: Text(
                      '${filteredStudents.length} ${l10n.students}',
                      style:
                          AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

              // Students list
              StudentsList(
                students: filteredStudents,
                isWide: widget.isWide,
                screenSize: widget.screenSize,
              ),
            ],
          ),
        );
      },
    );
  }
}
