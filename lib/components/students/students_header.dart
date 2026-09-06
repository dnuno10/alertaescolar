import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_theme.dart';

class StudentsHeader extends StatelessWidget {
  final Size screenSize;

  const StudentsHeader({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final smallPad = AppTheme.getSmallPadding(screenSize);

    return Column(
      children: [
        // Banner estático para "deslizar para refrescar"
        SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: smallPad,
              horizontal: AppTheme.getMediumPadding(screenSize),
            ),
            color: AppTheme.getBackgroundColor(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.arrowDownCircle,
                  size: screenSize.height * 0.022,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                SizedBox(width: smallPad),
                Text(
                  "Desliza hacia abajo para actualizar",
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: smallPad),
      ],
    );
  }
}
