import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
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

class StudentsSection extends StatelessWidget {
  final bool isWide;
  final Size screenSize;
  final Function() onAddStudent;

  const StudentsSection({
    super.key,
    required this.isWide,
    required this.screenSize,
    required this.onAddStudent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize)),
      child: Consumer<StudentProvider>(
        builder: (context, studentProvider, child) {
          if (studentProvider.isLoading) {
            // Show LoadingDialog when loading students
            WidgetsBinding.instance.addPostFrameCallback((_) {
              LoadingDialog.show(
                context,
                message: l10n.loadingStudents,
              );
            });

            // Return a minimal placeholder while the dialog is showing
            return Container(
              height: screenSize.height * 0.3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      l10n.loadingStudents,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Hide LoadingDialog when not loading
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                if (Navigator.of(context).canPop()) {
                  LoadingDialog.hide(context);
                }
              } catch (e) {
                // LoadingDialog might not be showing, ignore error
              }
            });
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
                  students: studentProvider.getAlumnosFromStudents(),
                  isWide: isWide,
                  screenSize: screenSize,
                ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              SolidButton(
                  width: double.infinity,
                  icon: Icons.person_add_rounded,
                  onPressed: onAddStudent,
                  label: l10n.addStudent,
                  screenSize: screenSize),
              SizedBox(height: AppTheme.getLargePadding(screenSize)),
            ],
          );
        },
      ),
    );
  }
}
