import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class EmptyRecordsState extends StatelessWidget {
  final Size screenSize;

  const EmptyRecordsState({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: screenSize.width * 0.15,
            color:
                AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noRecordsFound,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.tryAdjustingFilters,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
