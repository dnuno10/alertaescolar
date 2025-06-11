import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class TimeSettingsCard extends StatefulWidget {
  final Size screenSize;

  const TimeSettingsCard({
    super.key,
    required this.screenSize,
  });

  @override
  State<TimeSettingsCard> createState() => _TimeSettingsCardState();
}

class _TimeSettingsCardState extends State<TimeSettingsCard> {
  TimeOfDay _morningEntryTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _morningExitTime = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay _afternoonEntryTime = const TimeOfDay(hour: 13, minute: 30);
  TimeOfDay _afternoonExitTime = const TimeOfDay(hour: 18, minute: 30);
  int _entryTolerance = 15; // minutes
  int _lateTolerance = 30; // minutes
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: widget.screenSize.height * 0.015,
            offset: Offset(0, widget.screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                    AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.accentBlue,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Expanded(
                child: Text(
                  l10n.timeSettings ?? 'Configuración de horarios',
                  style: AppTheme.getH2(widget.screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                  color: AppTheme.accentBlue,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Morning Shift
          _ShiftTimeCard(
            title: l10n.morningShift,
            entryTime: _morningEntryTime,
            exitTime: _morningExitTime,
            onEntryTimeChanged: (time) {
              setState(() {
                _morningEntryTime = time;
              });
            },
            onExitTimeChanged: (time) {
              setState(() {
                _morningExitTime = time;
              });
            },
            isEditing: _isEditing,
            screenSize: widget.screenSize,
            l10n: l10n,
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Afternoon Shift
          _ShiftTimeCard(
            title: l10n.afternoonShift,
            entryTime: _afternoonEntryTime,
            exitTime: _afternoonExitTime,
            onEntryTimeChanged: (time) {
              setState(() {
                _afternoonEntryTime = time;
              });
            },
            onExitTimeChanged: (time) {
              setState(() {
                _afternoonExitTime = time;
              });
            },
            isEditing: _isEditing,
            screenSize: widget.screenSize,
            l10n: l10n,
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Tolerance Settings
          _ToleranceSettings(
            entryTolerance: _entryTolerance,
            lateTolerance: _lateTolerance,
            onEntryToleranceChanged: (value) {
              setState(() {
                _entryTolerance = value;
              });
            },
            onLateToleranceChanged: (value) {
              setState(() {
                _lateTolerance = value;
              });
            },
            isEditing: _isEditing,
            screenSize: widget.screenSize,
            l10n: l10n,
          ),

          if (_isEditing) ...[
            SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),
            SolidButton(
              backgroundColor: AppTheme.accentBlue,
              onPressed: _saveSettings,
              label: l10n.saveChanges,
              icon: Icons.save_rounded,
              screenSize: widget.screenSize,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  void _saveSettings() {
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).settingsUpdated,
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(widget.screenSize)),
        ),
      ),
    );
  }
}

class _ShiftTimeCard extends StatelessWidget {
  final String title;
  final TimeOfDay entryTime;
  final TimeOfDay exitTime;
  final ValueChanged<TimeOfDay> onEntryTimeChanged;
  final ValueChanged<TimeOfDay> onExitTimeChanged;
  final bool isEditing;
  final Size screenSize;
  final AppLocalizations l10n;

  const _ShiftTimeCard({
    required this.title,
    required this.entryTime,
    required this.exitTime,
    required this.onEntryTimeChanged,
    required this.onExitTimeChanged,
    required this.isEditing,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: _TimeButton(
                  label: l10n.entryTime,
                  time: entryTime,
                  onTimeChanged: onEntryTimeChanged,
                  isEditing: isEditing,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: _TimeButton(
                  label: l10n.exitTime,
                  time: exitTime,
                  onTimeChanged: onExitTimeChanged,
                  isEditing: isEditing,
                  screenSize: screenSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool isEditing;
  final Size screenSize;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTimeChanged,
    required this.isEditing,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditing ? () => _selectTime(context) : null,
      child: Container(
        padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          border: Border.all(
            color: isEditing
                ? AppTheme.accentBlue.withOpacity(0.3)
                : AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.02,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                Text(
                  time.format(context),
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEditing) ...[
                  const Spacer(),
                  Icon(
                    Icons.edit_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.height * 0.018,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.accentBlue,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      onTimeChanged(selectedTime);
    }
  }
}

class _ToleranceSettings extends StatelessWidget {
  final int entryTolerance;
  final int lateTolerance;
  final ValueChanged<int> onEntryToleranceChanged;
  final ValueChanged<int> onLateToleranceChanged;
  final bool isEditing;
  final Size screenSize;
  final AppLocalizations l10n;

  const _ToleranceSettings({
    required this.entryTolerance,
    required this.lateTolerance,
    required this.onEntryToleranceChanged,
    required this.onLateToleranceChanged,
    required this.isEditing,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_rounded,
                color: AppTheme.warningColor,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.toleranceSettings ?? 'Configuración de tolerancias',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: _ToleranceSlider(
                  label: l10n.entryTolerance,
                  value: entryTolerance,
                  onChanged: onEntryToleranceChanged,
                  isEditing: isEditing,
                  screenSize: screenSize,
                  l10n: l10n,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: _ToleranceSlider(
                  label: l10n.lateTolerance,
                  value: lateTolerance,
                  onChanged: onLateToleranceChanged,
                  isEditing: isEditing,
                  screenSize: screenSize,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToleranceSlider extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final bool isEditing;
  final Size screenSize;
  final AppLocalizations l10n;

  const _ToleranceSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isEditing,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Text(
          '$value ${l10n.minutes ?? 'minutos'}',
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.warningColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (isEditing) ...[
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.warningColor,
              inactiveTrackColor: AppTheme.warningColor.withOpacity(0.3),
              thumbColor: AppTheme.warningColor,
              overlayColor: AppTheme.warningColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 60,
              divisions: 12,
              onChanged: (newValue) => onChanged(newValue.round()),
            ),
          ),
        ],
      ],
    );
  }
}
