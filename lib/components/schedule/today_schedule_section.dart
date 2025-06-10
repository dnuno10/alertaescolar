import 'package:alertaescolar/components/schedule/schedule_card.dart';
import 'package:alertaescolar/components/students/student_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../models/models.dart'; // Asegúrate que contenga `Alumno`

class TodayScheduleSection extends StatelessWidget {
  final Size screenSize;
  final String? selectedStudentId;
  final ValueChanged<String> onStudentSelected;

  const TodayScheduleSection({
    super.key,
    required this.screenSize,
    required this.selectedStudentId,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.todaysSchedule,
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            Text(
              formattedDate,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Selector de estudiante
        Consumer<StudentProvider>(
          builder: (context, studentProvider, child) {
            final students = studentProvider.students;
            if (students.isEmpty) return const SizedBox.shrink();

            final selectedId = selectedStudentId ?? students.first.id;
            final selectedStudent = students.firstWhere(
              (s) => s.id == selectedId,
              orElse: () => students.first,
            );

            return Container(
              margin: EdgeInsets.only(
                  bottom: AppTheme.getMediumPadding(screenSize)),
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: screenSize.height * 0.02,
                    color: AppTheme.accentBlue,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    '${l10n.todaysSchedule} de: ',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => StudentSelectorModal(
                          students: students,
                          selectedStudentId: selectedStudentId,
                          onStudentSelected: (id) {
                            onStudentSelected(id); // Callback externo
                          },
                          screenSize: screenSize,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              AppTheme.getSmallPadding(screenSize) * 0.75,
                          vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize) * 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                selectedStudent.nombre,
                                style: AppTheme.getCaption(screenSize).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                                width:
                                    AppTheme.getSmallPadding(screenSize) * 0.5),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: screenSize.height * 0.018,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Horarios
        ScheduleCard(
          screenSize: screenSize,
          time: '08:00 - 12:00',
          title: l10n.morningClasses,
          subject: l10n.mathSpanishSciences,
          color: AppTheme.accentBlue,
          isActive: true,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        ScheduleCard(
          screenSize: screenSize,
          time: '14:00 - 16:30',
          title: l10n.afternoonClasses,
          subject: l10n.historyPhysicalEducation,
          color: AppTheme.successColor,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        ScheduleCard(
          screenSize: screenSize,
          time: '17:00 - 18:00',
          title: l10n.extracurricularActivities,
          subject: l10n.chessClub,
          color: AppTheme.accentPurple,
        ),
      ],
    );
  }
}
