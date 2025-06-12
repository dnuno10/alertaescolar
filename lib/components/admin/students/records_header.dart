import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class RecordsHeader extends StatelessWidget {
  final int recordCount;
  final Size screenSize;

  const RecordsHeader({
    super.key,
    required this.recordCount,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.detailedRecords,
            style: AppTheme.getH2(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Text(
          l10n.recordCount(recordCount),
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }
}
