import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class CustomTextAreaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const CustomTextAreaField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.validator,
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            prefixIcon: Icon(
              icon,
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.05,
            ),
            filled: true,
            fillColor: AppTheme.getInputFillColor(context),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentPurple.withOpacity(0.0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: const BorderSide(
                color: AppTheme.accentPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
          ),
        ),
      ],
    );
  }
}
