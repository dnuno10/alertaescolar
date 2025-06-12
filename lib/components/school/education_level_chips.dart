import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class EducationLevelChips extends StatelessWidget {
  final List<String> levels;
  final Size screenSize;

  const EducationLevelChips({
    super.key,
    required this.levels,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.7),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: screenSize.height * 0.02,
                  color: AppTheme.accentPurple,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Text(
                l10n.educationalLevels,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Wrap(
            spacing: AppTheme.getSmallPadding(screenSize),
            children: levels.map((level) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(screenSize)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  level,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
