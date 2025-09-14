import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'custom_alert_dialog.dart';
import '../buttons/dialog_action_button.dart';

class AboutAppDialog extends StatelessWidget {
  final Size screenSize;

  const AboutAppDialog({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomAlertDialog(
      title: l10n.aboutAlertaEscolar,
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentPurple.withOpacity(0.1),
              AppTheme.accentPurple.withOpacity(0.05),
            ],
          ),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: AppTheme.accentPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo y versión
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.school,
                    color: AppTheme.accentPurple,
                    size: screenSize.width * 0.08,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alerta Escolar',
                        style: AppTheme.getSubtitle1(screenSize).copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      Text(
                        l10n.version,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Descripción
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Text(
                l10n.aboutDescription,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        DialogActionButton(
          label: l10n.understood,
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: AppTheme.primaryColor,
          screenSize: screenSize,
        ),
      ],
      screenSize: screenSize,
    );
  }

  static void show(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AboutAppDialog(screenSize: screenSize),
    );
  }
}
