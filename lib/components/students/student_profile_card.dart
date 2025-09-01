import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';

class StudentProfileCard extends StatelessWidget {
  final StudentDetails student;
  final Color color;
  final Size screenSize;

  const StudentProfileCard({
    super.key,
    required this.student,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(color: AppTheme.getBorderColor(context)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
                vertical: screenSize.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: student.llaveActiva
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.warningColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Text(
                student.llaveActiva ? l10n.active : l10n.inactive,
                style: AppTheme.getCaption(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: student.llaveActiva
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
