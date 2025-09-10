import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- necesario para TextInputFormatter

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Size screenSize;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;

  final Widget? suffixIcon;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final bool? enableSuggestions;
  final bool? autocorrect;

  /// NUEVO: API moderna
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  /// COMPAT: para no romper llamadas existentes
  final bool? enabled; // si viene false => readOnly efectivo
  final ValueChanged<String>? onFieldSubmitted; // alias del nuevo onSubmitted

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.screenSize,
    this.icon,
    this.validator,
    this.keyboardType,
    this.focusNode,
    this.suffixIcon,
    this.textCapitalization,
    this.textInputAction,
    this.autofillHints,
    this.enableSuggestions,
    this.autocorrect,
    // nuevos
    this.onSubmitted,
    this.readOnly = false,
    this.inputFormatters,
    // compat
    this.enabled,
    this.onFieldSubmitted,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeTextColor = AppTheme.getTextPrimaryColor(context);

    // Compat: si enabled == false, forzamos readOnly efectivo
    final bool effectiveReadOnly = widget.readOnly || (widget.enabled == false);

    // Compat: priorizamos el nuevo onSubmitted y si no, usamos onFieldSubmitted
    final ValueChanged<String>? effectiveOnSubmitted =
        widget.onSubmitted ?? widget.onFieldSubmitted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label externo
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
          focusNode: widget.focusNode,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          enableSuggestions: widget.enableSuggestions ?? true,
          autocorrect: widget.autocorrect ?? true,
          autofillHints: widget.autofillHints,
          readOnly: effectiveReadOnly, // <— nuevo/compat
          inputFormatters: widget.inputFormatters, // <— nuevo
          keyboardAppearance: theme.brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
          style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: themeTextColor,
          ),
          onFieldSubmitted: (value) {
            // <— nuevo/compat
            if (effectiveOnSubmitted != null) {
              effectiveOnSubmitted(value);
            } else if (widget.textInputAction == TextInputAction.next) {
              FocusScope.of(context).nextFocus();
            }
          },
          cursorColor: AppTheme.accentBlue,
          decoration: InputDecoration(
            hintText: null, // evita duplicar label
            hintStyle: AppTheme.getBodyMedium(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            prefixIcon: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: AppTheme.accentBlue,
                    size: widget.screenSize.width * 0.05,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize),
              ),
              borderSide: BorderSide(
                // ignore: deprecated_member_use
                color: AppTheme.accentBlue.withOpacity(0.25),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize),
              ),
              borderSide: BorderSide(
                // ignore: deprecated_member_use
                color: AppTheme.accentBlue.withOpacity(0.25),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize),
              ),
              borderSide: BorderSide(
                color: AppTheme.accentBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize),
              ),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(widget.screenSize),
              vertical: AppTheme.getSmallPadding(widget.screenSize),
            ),
            isDense: true,
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
      ],
    );
  }
}
