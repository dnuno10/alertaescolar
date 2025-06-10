import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class OptionDivider extends StatelessWidget {
  final Size screenSize;

  const OptionDivider({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize)),
          child: Text(
            l10n.or,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
        ),
      ],
    );
  }
}
