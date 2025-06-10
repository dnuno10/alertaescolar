import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class StudentsHeader extends StatelessWidget {
  final Size screenSize;

  const StudentsHeader({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.getCardColor(context),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              children: [
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  l10n.myStudents,
                  style: AppTheme.getH1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
