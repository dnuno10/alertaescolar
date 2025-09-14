import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class StudentsHeader extends StatelessWidget {
  final Size screenSize;

  const StudentsHeader({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final outerPad = AppTheme.getLargePadding(screenSize);
    final innerPad = AppTheme.getMediumPadding(screenSize);
    final smallPad = AppTheme.getSmallPadding(screenSize);
    final borderW = screenSize.width * 0.0025;
    final radius = AppTheme.getLargeRadius(screenSize);
    final iconSize = screenSize.height * 0.03;

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

        // Contenedor principal del header
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: outerPad * 0.5,
            vertical: smallPad * 0.6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppTheme.getDividerColor(context),
              width: borderW,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(innerPad),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(smallPad),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize),
                    ),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: AppTheme.accentPurple,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: smallPad),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.myStudents,
                        style: AppTheme.getH1(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        l10n.manageAndViewYourStudents,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
