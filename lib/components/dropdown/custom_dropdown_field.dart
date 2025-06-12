import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) getLabel;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.getLabel,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
        SizedBox(height: screenSize.height * 0.01),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize) * 0.3,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentPurple.withOpacity(0.0),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.05,
              ),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(getLabel(item)),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
