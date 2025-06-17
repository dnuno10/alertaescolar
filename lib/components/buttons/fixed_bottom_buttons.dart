import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class FixedBottomButtons extends StatelessWidget {
  final List<Widget> buttons;
  final EdgeInsets? padding;
  final bool showBorder;
  final bool showShadow;

  const FixedBottomButtons({
    super.key,
    required this.buttons,
    this.padding,
    this.showBorder = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: padding ??
            EdgeInsets.only(
              left: AppTheme.getMediumPadding(screenSize),
              right: AppTheme.getMediumPadding(screenSize),
              top: AppTheme.getMediumPadding(screenSize),
              bottom: MediaQuery.of(context).padding.bottom +
                  AppTheme.getMediumPadding(screenSize),
            ),
        decoration: BoxDecoration(
          color: AppTheme.getBackgroundColor(context),
          border: showBorder
              ? Border(
                  top: BorderSide(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                )
              : null,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: _buildButtonsWithSpacing(),
        ),
      ),
    );
  }

  List<Widget> _buildButtonsWithSpacing() {
    final List<Widget> result = [];
    for (int i = 0; i < buttons.length; i++) {
      result.add(buttons[i]);
      if (i < buttons.length - 1) {
        result.add(const SizedBox(width: 16));
      }
    }
    return result;
  }
}
