import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class StudentsLoadingState extends StatelessWidget {
  final Size screenSize;

  const StudentsLoadingState({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: screenSize.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.accentPurple,
              strokeWidth: 3,
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              l10n.loadingStudents,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
