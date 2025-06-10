import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class ScheduleLoadingState extends StatelessWidget {
  final Size screenSize;

  const ScheduleLoadingState({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: screenSize.height * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.loadingSchedule,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
