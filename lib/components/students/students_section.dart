import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../models/models.dart';
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
  late List<Alumno> filteredStudents;

  @override
  void initState() {
    super.initState();
    filteredStudents = [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer2<StudentProvider, UserProvider>(
      builder: (context, studentProvider, userProvider, child) {
        // Convert StudentDetails to Alumno using the provider's method
        final alumnosList = studentProvider.getAlumnosFromStudents();

        // Sin loader local: sólo sincronizamos la lista mostrada
        if (filteredStudents.isEmpty ||
            filteredStudents.length != alumnosList.length) {
          filteredStudents = List.from(alumnosList);
        }

        // Errores -> estado de error
        if (studentProvider.error != null) {
          return StudentsErrorState(
            studentProvider: studentProvider,
            screenSize: widget.screenSize,
          );
        }

        // Sin alumnos -> estado vacío (el overlay global de StudentsView cubre la carga inicial)
        if (alumnosList.isEmpty) {
          return Center(
            child: Column(
              children: [
                SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
                StudentsEmptyState(
                  screenSize: widget.screenSize,
                ),
              ],
            ),
          );
        }

        // Lista de alumnos
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
