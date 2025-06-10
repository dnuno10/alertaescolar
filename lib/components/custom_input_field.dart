import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Size screenSize;
  final bool isPassword;
  final IconData? icon; // ahora opcional
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.screenSize,
    this.isPassword = false,
    this.icon,
    this.validator,
    this.keyboardType,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final themeTextColor = AppTheme.getTextPrimaryColor(context);
    final hintText = widget.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: themeTextColor,
          ),
        ),
        SizedBox(height: widget.screenSize.height * 0.01),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? _obscureText : false,
          style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: themeTextColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            labelText: widget.isPassword ? widget.label : null,
            labelStyle: AppTheme.getCaption(widget.screenSize).copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            hintStyle: AppTheme.getBodyMedium(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            prefixIcon: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: AppTheme.accentPurple,
                    size: widget.screenSize.width * 0.05,
                  )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.getTextSecondaryColor(context),
                      size: widget.screenSize.width * 0.05,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: widget.isPassword
                ? Colors.transparent
                : AppTheme.getInputFillColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentPurple
                    .withOpacity(widget.isPassword ? 0.2 : 0.0),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentPurple
                    .withOpacity(widget.isPassword ? 0.2 : 0.0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: const BorderSide(
                color: AppTheme.accentPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(widget.screenSize),
              vertical: AppTheme.getSmallPadding(widget.screenSize),
            ),
          ),
        ),
      ],
    );
  }
}
