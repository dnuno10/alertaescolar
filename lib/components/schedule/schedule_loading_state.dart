import 'package:alertaescolar/components/loading_dialog.dart';
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

    return SizedBox(
      height: screenSize.height * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.getTextPrimaryColor(context),
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

  // Static method for showing loading dialog instead of this widget
  static void showDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    LoadingDialog.show(
      context,
      message: l10n.loadingSchedule,
    );
  }

  // Static method for hiding loading dialog
  static void hideDialog(BuildContext context) {
    LoadingDialog.hide(context);
  }
}
