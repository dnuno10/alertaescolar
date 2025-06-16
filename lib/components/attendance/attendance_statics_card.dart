import 'package:alertaescolar/components/students/student_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';

class AttendanceStatisticsCard extends StatelessWidget {
  final Size screenSize;
  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;
  final String? selectedStudentId;
  final ValueChanged<String> onStudentSelected;

  const AttendanceStatisticsCard({
    super.key,
    required this.screenSize,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.selectedStudentId,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.statistics,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PeriodButton(
                      text: l10n.sevenDays,
                      index: 0,
                      isSelected: selectedPeriod == 0,
                      onTap: () => onPeriodChanged(0),
                      screenSize: screenSize,
                    ),
                    SizedBox(width: screenSize.height * 0.005),
                    _PeriodButton(
                      text: l10n.oneMonth,
                      index: 1,
                      isSelected: selectedPeriod == 1,
                      onTap: () => onPeriodChanged(1),
                      screenSize: screenSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Student selector
          Consumer<StudentProvider>(
            builder: (context, studentProvider, child) {
              final students = studentProvider.getAlumnosFromStudents();
              if (students.isEmpty) return const SizedBox.shrink();

              final selectedStudent = students.firstWhere(
                (s) => s.id == selectedStudentId,
                orElse: () => students.first,
              );

              return GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => StudentSelectorModal(
                    students: students,
                    selectedStudentId: selectedStudentId,
                    onStudentSelected: (id) {
                      onStudentSelected(id);
                    },
                    screenSize: screenSize,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.accentPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded,
                          size: screenSize.height * 0.02,
                          color: AppTheme.accentPurple),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Text(
                        l10n.statisticsFor, // Replaced hardcoded text '${l10n.statistics} de: '
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppTheme.getSmallPadding(screenSize) * 0.75,
                            vertical:
                                AppTheme.getSmallPadding(screenSize) * 0.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple,
                            borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize) * 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedStudent.nombre,
                                  style:
                                      AppTheme.getCaption(screenSize).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize) *
                                      0.5),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  size: screenSize.height * 0.018,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Stats content
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Text(
                selectedPeriod == 0 ? '98%' : '94%',
                style: AppTheme.getH1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedPeriod == 0
                          ? l10n.weeklyAttendance
                          : l10n.monthlyAttendance,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenSize.height * 0.005),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.height * 0.008,
                        vertical: screenSize.height * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius:
                            BorderRadius.circular(screenSize.height * 0.008),
                      ),
                      child: Text(
                        selectedPeriod == 0
                            ? l10n.plusFivePercent
                            : l10n.plusTwoPercent,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Wrap each child in Flexible to allow them to resize based on available space
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: screenSize.height * 0.06,
                      height: screenSize.height * 0.06,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius:
                            BorderRadius.circular(screenSize.height * 0.015),
                      ),
                      child: const Padding(padding: EdgeInsets.zero),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) / 1.2),
                    Text(
                      selectedPeriod == 0 ? '7' : '28',
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.attendances,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: screenSize.height * 0.06,
                      height: screenSize.height * 0.06,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDCB5A),
                        borderRadius:
                            BorderRadius.circular(screenSize.height * 0.015),
                      ),
                      child: const Padding(padding: EdgeInsets.zero),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) / 1.2),
                    Text(
                      selectedPeriod == 0 ? '0' : '3',
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.lateArrivals,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: screenSize.height * 0.06,
                      height: screenSize.height * 0.06,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4757),
                        borderRadius:
                            BorderRadius.circular(screenSize.height * 0.015),
                      ),
                      child: const Padding(padding: EdgeInsets.zero),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) / 1.2),
                    Text(
                      selectedPeriod == 0 ? '0' : '2',
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.absences,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;

  const _PeriodButton({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.height * 0.015,
          vertical: screenSize.height * 0.008,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(screenSize.height * 0.01),
        ),
        child: Text(
          text,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: isSelected
                ? Colors.white
                : AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
