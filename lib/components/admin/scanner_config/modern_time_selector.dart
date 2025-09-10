import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ModernTimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Function(TimeOfDay) onTimeChanged;
  final Color color;
  final Size screenSize;

  const ModernTimeSelector({
    super.key,
    required this.label,
    required this.time,
    required this.onTimeChanged,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showModernTimePicker(context, time, onTimeChanged);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: color,
                  size: screenSize.height * 0.022,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                Text(
                  time.format(context),
                  style: AppTheme.getH2(screenSize).copyWith(
                    fontSize: screenSize.height * 0.022,
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.8),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize) * 0.3,
                vertical: AppTheme.getSmallPadding(screenSize) * 0.4,
              ),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Text(
                l10n.tapToChange,
                textAlign: TextAlign.center,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModernTimePicker(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ModernTimePickerDialog(
        initialTime: initialTime,
        onTimeSelected: onChanged,
        accentColor: color,
      ),
    );
  }
}

class ModernTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final Color? accentColor;

  const ModernTimePickerDialog({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
    this.accentColor,
  });

  @override
  State<ModernTimePickerDialog> createState() => _ModernTimePickerDialogState();
}

class _ModernTimePickerDialogState extends State<ModernTimePickerDialog>
    with SingleTickerProviderStateMixin {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAm;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Convert 24-hour format to 12-hour format with AM/PM
    _isAm = widget.initialTime.hour < 12;
    _selectedHour = _isAm
        ? (widget.initialTime.hour == 0 ? 12 : widget.initialTime.hour)
        : (widget.initialTime.hour == 12 ? 12 : widget.initialTime.hour - 12);
    _selectedMinute = widget.initialTime.minute;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final accentColor = widget.accentColor ?? AppTheme.accentPurple;

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_animation),
        child: Container(
          padding: EdgeInsets.only(
            top: AppTheme.getMediumPadding(screenSize),
            bottom: MediaQuery.of(context).viewInsets.bottom +
                AppTheme.getMediumPadding(screenSize),
          ),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.getLargeRadius(screenSize)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: screenSize.height * 0.02,
                offset: Offset(0, -screenSize.height * 0.005),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getLargePadding(screenSize),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.selectTime,
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Time display
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: AppTheme.getMediumPadding(screenSize),
                  horizontal: AppTheme.getLargePadding(screenSize),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getMediumPadding(screenSize),
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.getMediumRadius(screenSize),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isAm ? 'AM' : 'PM'}',
                      style: AppTheme.getH1(screenSize).copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Time picker wheels
              Container(
                height: screenSize.height * 0.25,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getLargePadding(screenSize),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hour picker
                    Expanded(
                      flex: 1,
                      child: _buildNumberPicker(
                        context: context,
                        values: List.generate(12, (index) => (index + 1)),
                        selectedValue: _selectedHour,
                        onChanged: (value) {
                          setState(() {
                            _selectedHour = value;
                          });
                        },
                        label: l10n.hours,
                        accentColor: accentColor,
                      ),
                    ),

                    // Minute picker
                    Expanded(
                      flex: 1,
                      child: _buildNumberPicker(
                        context: context,
                        values: List.generate(60, (index) => index),
                        selectedValue: _selectedMinute,
                        onChanged: (value) {
                          setState(() {
                            _selectedMinute = value;
                          });
                        },
                        label: l10n.min,
                        accentColor: accentColor,
                      ),
                    ),

                    // AM/PM picker
                    Expanded(
                      flex: 1,
                      child: _buildAmPmPicker(
                        context: context,
                        isAm: _isAm,
                        onChanged: (value) {
                          setState(() {
                            _isAm = value;
                          });
                        },
                        label: 'AM/PM',
                        accentColor: accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(
                              AppTheme.getMediumPadding(screenSize)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize),
                            ),
                            side: BorderSide(
                              color: AppTheme.getBorderColor(context),
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Convert 12-hour format back to 24-hour format
                          final hour = _isAm
                              ? (_selectedHour == 12 ? 0 : _selectedHour)
                              : (_selectedHour == 12 ? 12 : _selectedHour + 12);

                          final selectedTime = TimeOfDay(
                            hour: hour,
                            minute: _selectedMinute,
                          );

                          widget.onTimeSelected(selectedTime);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: EdgeInsets.all(
                              AppTheme.getMediumPadding(screenSize)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize),
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.ok,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPicker({
    required BuildContext context,
    required List<int> values,
    required int selectedValue,
    required Function(int) onChanged,
    required String label,
    required Color accentColor,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
            child: ListWheelScrollView(
              controller: FixedExtentScrollController(
                initialItem: values.indexOf(selectedValue),
              ),
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 50,
              perspective: 0.005,
              diameterRatio: 1.5,
              useMagnifier: true,
              magnification: 1.2,
              onSelectedItemChanged: (index) {
                onChanged(values[index]);
              },
              children: values.map((value) {
                final isSelected = value == selectedValue;
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: AppTheme.getBodyLarge(screenSize).copyWith(
                      color: isSelected
                          ? accentColor
                          : AppTheme.getTextSecondaryColor(context),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmPmPicker({
    required BuildContext context,
    required bool isAm,
    required Function(bool) onChanged,
    required String label,
    required Color accentColor,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
            child: ListWheelScrollView(
              controller: FixedExtentScrollController(
                initialItem: isAm ? 0 : 1,
              ),
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 50,
              perspective: 0.005,
              diameterRatio: 1.5,
              useMagnifier: true,
              magnification: 1.2,
              onSelectedItemChanged: (index) {
                onChanged(index == 0);
              },
              children: ['AM', 'PM'].map((value) {
                final isSelected =
                    (value == 'AM' && isAm) || (value == 'PM' && !isAm);
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: AppTheme.getBodyLarge(screenSize).copyWith(
                      color: isSelected
                          ? accentColor
                          : AppTheme.getTextSecondaryColor(context),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
