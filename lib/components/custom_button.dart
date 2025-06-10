// 🚀 Premium Custom Button Component - Fintech Style
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/app_theme.dart';

enum ButtonVariant { filled, outline, ghost, icon }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Color? customColor;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.customColor,
    this.isLoading = false,
    this.fullWidth = false,
  });

  // Factory constructors for common button types
  factory CustomButton.primary({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) =>
      CustomButton(
        text: text,
        onPressed: onPressed,
        variant: ButtonVariant.filled,
        size: size,
        customColor: AppTheme.primaryColor,
        isLoading: isLoading,
        fullWidth: fullWidth,
      );

  factory CustomButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) =>
      CustomButton(
        text: text,
        onPressed: onPressed,
        variant: ButtonVariant.filled,
        size: size,
        customColor: AppTheme.secondaryColor,
        isLoading: isLoading,
        fullWidth: fullWidth,
      );

  factory CustomButton.outline({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    Color? color,
    bool fullWidth = false,
  }) =>
      CustomButton(
        text: text,
        onPressed: onPressed,
        variant: ButtonVariant.outline,
        size: size,
        customColor: color ?? AppTheme.primaryColor,
        fullWidth: fullWidth,
      );

  factory CustomButton.icon({
    required IconData icon,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    Color? color,
  }) =>
      CustomButton(
        icon: icon,
        onPressed: onPressed,
        variant: ButtonVariant.icon,
        size: size,
        customColor: color ?? AppTheme.primaryColor,
      );

  @override
  Widget build(BuildContext context) {
    final buttonColor = customColor ?? AppTheme.primaryColor;
    final isDisabled = onPressed == null || isLoading;

    // Size configurations
    final sizeConfig = _getSizeConfig();

    Widget child = _buildButtonChild();

    if (variant == ButtonVariant.icon) {
      return _buildIconButton(buttonColor, isDisabled, child);
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: sizeConfig.height,
      child: _buildRegularButton(buttonColor, isDisabled, child, sizeConfig),
    );
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.filled
                ? Colors.white
                : customColor ?? AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getSizeConfig().iconSize),
          const SizedBox(width: 8),
          Text(text!),
        ],
      );
    }

    if (icon != null) {
      return Icon(icon, size: _getSizeConfig().iconSize);
    }

    return Text(text ?? '');
  }

  Widget _buildRegularButton(Color buttonColor, bool isDisabled, Widget child,
      _ButtonSizeConfig sizeConfig) {
    final backgroundColor = _getBackgroundColor(buttonColor, isDisabled);
    final foregroundColor = _getForegroundColor(buttonColor);
    final borderColor = _getBorderColor(buttonColor, isDisabled);

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: variant == ButtonVariant.filled ? (isDisabled ? 0 : 2) : 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
          side: BorderSide(
            color: borderColor,
            width: variant == ButtonVariant.outline ? 1.5 : 0,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sizeConfig.horizontalPadding,
          vertical: sizeConfig.verticalPadding,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: sizeConfig.fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildIconButton(Color buttonColor, bool isDisabled, Widget child) {
    final sizeConfig = _getSizeConfig();

    return Container(
      width: sizeConfig.height,
      height: sizeConfig.height,
      decoration: BoxDecoration(
        color: _getBackgroundColor(buttonColor, isDisabled),
        borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
        border: variant == ButtonVariant.outline
            ? Border.all(
                color: _getBorderColor(buttonColor, isDisabled), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
          child: Center(child: child),
        ),
      ),
    );
  }

  Color _getBackgroundColor(Color buttonColor, bool isDisabled) {
    if (isDisabled) {
      return variant == ButtonVariant.filled
          ? AppTheme.textSecondaryLight.withOpacity(0.3)
          : Colors.transparent;
    }

    switch (variant) {
      case ButtonVariant.filled:
        return buttonColor;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.icon:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(Color buttonColor) {
    switch (variant) {
      case ButtonVariant.filled:
        return Colors.white;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.icon:
        return buttonColor;
    }
  }

  Color _getBorderColor(Color buttonColor, bool isDisabled) {
    if (isDisabled) {
      return AppTheme.textSecondaryLight.withOpacity(0.3);
    }
    return buttonColor;
  }

  _ButtonSizeConfig _getSizeConfig() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonSizeConfig(
          height: 36,
          fontSize: 14,
          iconSize: 16,
          horizontalPadding: 16,
          verticalPadding: 8,
          borderRadius: AppTheme.borderRadiusSmall,
        );
      case ButtonSize.medium:
        return _ButtonSizeConfig(
          height: 48,
          fontSize: 16,
          iconSize: 18,
          horizontalPadding: 24,
          verticalPadding: 12,
          borderRadius: AppTheme.borderRadiusMedium,
        );
      case ButtonSize.large:
        return _ButtonSizeConfig(
          height: 56,
          fontSize: 18,
          iconSize: 20,
          horizontalPadding: 32,
          verticalPadding: 16,
          borderRadius: AppTheme.borderRadiusMedium,
        );
    }
  }
}

class _ButtonSizeConfig {
  final double height;
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;

  _ButtonSizeConfig({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
  });
}
