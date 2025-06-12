import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'schedule_header.dart';
import 'modern_shift_section.dart';

class ScheduleStepCard extends StatelessWidget {
  final TimeOfDay morningStartTime;
  final TimeOfDay morningEndTime;
  final TimeOfDay afternoonStartTime;
  final TimeOfDay afternoonEndTime;
  final Function(TimeOfDay) onMorningStartChanged;
  final Function(TimeOfDay) onMorningEndChanged;
  final Function(TimeOfDay) onAfternoonStartChanged;
  final Function(TimeOfDay) onAfternoonEndChanged;
  final Size screenSize;

  const ScheduleStepCard({
    super.key,
    required this.morningStartTime,
    required this.morningEndTime,
    required this.afternoonStartTime,
    required this.afternoonEndTime,
    required this.onMorningStartChanged,
    required this.onMorningEndChanged,
    required this.onAfternoonStartChanged,
    required this.onAfternoonEndChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduleHeader(screenSize: screenSize),
              SizedBox(height: AppTheme.getLargePadding(screenSize)),
              ModernShiftSection(
                title: l10n.morningShift,
                icon: Icons.wb_sunny_rounded,
                color: AppTheme.accentBlue,
                startTime: morningStartTime,
                endTime: morningEndTime,
                onStartChanged: onMorningStartChanged,
                onEndChanged: onMorningEndChanged,
                screenSize: screenSize,
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              ModernShiftSection(
                title: l10n.afternoonShift,
                icon: Icons.wb_twilight_rounded,
                color: AppTheme.accentOrange,
                startTime: afternoonStartTime,
                endTime: afternoonEndTime,
                onStartChanged: onAfternoonStartChanged,
                onEndChanged: onAfternoonEndChanged,
                screenSize: screenSize,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
