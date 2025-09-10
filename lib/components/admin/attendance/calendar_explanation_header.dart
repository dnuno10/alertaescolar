import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class CalendarExplanationHeader extends StatelessWidget {
  final Size screenSize;

  const CalendarExplanationHeader({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppTheme.accentBlue.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        // ignore: deprecated_member_use
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppTheme.accentBlue,
            size: screenSize.width * 0.06,
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Text(
              l10n.calendarExplanationText,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
