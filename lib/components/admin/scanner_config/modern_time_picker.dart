import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class ModernTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;
  final Size screenSize;
  final Color accentColor;

  const ModernTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
    required this.screenSize,
    required this.accentColor,
  }) : super(key: key);

  @override
  _ModernTimePickerState createState() => _ModernTimePickerState();
}

class _ModernTimePickerState extends State<ModernTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  late bool isAM;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided initial time
    selectedHour = widget.initialTime.hourOfPeriod == 0
        ? 12
        : widget.initialTime.hourOfPeriod;
    selectedMinute = widget.initialTime.minute;
    isAM = widget.initialTime.period == DayPeriod.am;
  }

  void _updateTime() {
    final hour = isAM
        ? (selectedHour == 12 ? 0 : selectedHour)
        : (selectedHour == 12 ? 12 : selectedHour + 12);

    final newTime = TimeOfDay(hour: hour, minute: selectedMinute);
    widget.onTimeChanged(newTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(
                AppTheme.getMediumRadius(widget.screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour picker
                  Expanded(
                    child: _buildWheelPicker(
                      items: List.generate(12,
                          (index) => (index + 1).toString().padLeft(2, '0')),
                      initialIndex: selectedHour - 1,
                      onChanged: (index) {
                        setState(() {
                          selectedHour = index + 1;
                          _updateTime();
                        });
                      },
                    ),
                  ),

                  Text(":",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                  // Minute picker
                  Expanded(
                    child: _buildWheelPicker(
                      items: List.generate(
                          60, (index) => index.toString().padLeft(2, '0')),
                      initialIndex: selectedMinute,
                      onChanged: (index) {
                        setState(() {
                          selectedMinute = index;
                          _updateTime();
                        });
                      },
                    ),
                  ),

                  // AM/PM picker
                  Expanded(
                    child: _buildWheelPicker(
                      items: ["AM", "PM"],
                      initialIndex: isAM ? 0 : 1,
                      onChanged: (index) {
                        setState(() {
                          isAM = index == 0;
                          _updateTime();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWheelPicker({
    required List<String> items,
    required int initialIndex,
    required Function(int) onChanged,
  }) {
    // Fixed height for the wheel picker to solve the infinite size issue
    const double pickerHeight = 120.0;
    const double itemHeight = 40.0;

    return SizedBox(
      height: pickerHeight,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: initialIndex),
        itemExtent: itemHeight,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            final isSelected = index == initialIndex;
            return Container(
              alignment: Alignment.center,
              child: Text(
                items[index],
                style: TextStyle(
                  fontSize: isSelected ? 22 : 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? widget.accentColor
                      : AppTheme.getPrimaryLightColor(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
