import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

class StudentProfileCard extends StatelessWidget {
  final Alumno student;
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
              width: screenSize.width * 0.25,
              height: screenSize.width * 0.25,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  student.nombre.isNotEmpty
                      ? student.nombre[0].toUpperCase()
                      : 'A',
                  style: AppTheme.getH1(screenSize).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onPrimaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              student.nombre,
              style: AppTheme.getH1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.height * 0.01),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
                vertical: screenSize.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: student.vinculado
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Text(
                student.vinculado ? l10n.active : l10n.inactive,
                style: AppTheme.getCaption(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: student.vinculado
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
