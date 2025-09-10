import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import 'students_list.dart';
import 'students_error_state.dart';
import 'students_empty_state.dart';

class StudentsSection extends StatefulWidget {
  final bool isWide;
  final Size screenSize;
  final VoidCallback? onAddStudent;

  const StudentsSection({
    super.key,
    required this.isWide,
    required this.screenSize,
    this.onAddStudent,
  });

  @override
  State<StudentsSection> createState() => _StudentsSectionState();
}

class _StudentsSectionState extends State<StudentsSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer2<StudentProvider, UserProvider>(
      builder: (context, studentProvider, userProvider, child) {
        // ¡Usa directamente el provider!
        final alumnosList = studentProvider.getAlumnosFromStudents();

        if (studentProvider.error != null) {
          return StudentsErrorState(
            studentProvider: studentProvider,
            screenSize: widget.screenSize,
          );
        }

        if (alumnosList.isEmpty) {
          return Center(
            child: Column(
              children: [
                SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
                StudentsEmptyState(screenSize: widget.screenSize),
              ],
            ),
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
                      // ignore: deprecated_member_use
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize),
                      ),
                    ),
                    child: Text(
                      '${alumnosList.length} ${l10n.students}',
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
              StudentsList(
                students: alumnosList, // <- ya no usamos estado local
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
