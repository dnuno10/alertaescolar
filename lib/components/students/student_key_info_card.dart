import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';
import 'student_detail_row.dart';

class StudentKeyInfoCard extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const StudentKeyInfoCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.keyInformation,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.key_rounded,
            label: l10n.keyCode,
            value: student.llave.isNotEmpty ? student.llave : l10n.notAssigned,
            iconColor: AppTheme.accentYellow,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.power_settings_new_rounded,
            label: 'Status', // TODO: Add to l10n
            value: student.activo
                ? 'Activada'
                : 'Desactivada', // TODO: Add to l10n
            iconColor:
                student.activo ? AppTheme.successColor : AppTheme.errorColor,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.schedule_rounded,
            label: 'Tiempo restante', // TODO: Add to l10n
            value: '30 días', // TODO: Calculate actual remaining time
            iconColor: AppTheme.accentBlue,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }
}
