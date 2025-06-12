import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class StudentEditInfoCard extends StatelessWidget {
  final AppLocalizations l10n;
  final Size screenSize;

  const StudentEditInfoCard({
    super.key,
    required this.l10n,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_outlined,
                color: AppTheme.accentBlue,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.editInformation,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.editStudentInfoInstructions,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          SolidButton(
            backgroundColor: AppTheme.accentBlue,
            width: double.infinity,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.contactSchoolFeatureComingSoon,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.onPrimaryColor,
                    ),
                  ),
                  backgroundColor: AppTheme.accentBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                ),
              );
            },
            icon: Icons.contact_support_outlined,
            label: l10n.contactSchool,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }
}
