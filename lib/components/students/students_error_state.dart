import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';

class StudentsErrorState extends StatelessWidget {
  final StudentProvider studentProvider;
  final Size screenSize;

  const StudentsErrorState({
    super.key,
    required this.studentProvider,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      margin:
          EdgeInsets.symmetric(vertical: AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Container(
            width: screenSize.width * 0.16,
            height: screenSize.width * 0.16,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.error_outline,
              size: screenSize.width * 0.08,
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.errorLoadingStudents,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            studentProvider.error!,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => studentProvider.loadStudents(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: AppTheme.onPrimaryColor,
                padding: EdgeInsets.symmetric(
                    vertical: AppTheme.getSmallPadding(screenSize)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.refresh,
                size: screenSize.width * 0.05,
                color: AppTheme.onPrimaryColor,
              ),
              label: Text(
                l10n.retry,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
