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
    final l10n = AppLocalizations.of(context)!; // Added non-null assertion

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
            value: student.id_llave.isNotEmpty
                ? student.id_llave
                : l10n.notAssigned,
            iconColor: AppTheme.accentYellow,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.power_settings_new_rounded,
            label: l10n.status, // Replaced hardcoded 'Status'
            value: student.vinculado
                ? l10n.activated
                : l10n.deactivated, // Replaced hardcoded status values
            iconColor:
                student.vinculado ? AppTheme.successColor : AppTheme.errorColor,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.schedule_rounded,
            label: l10n.remainingTime, // Replaced hardcoded 'Tiempo restante'
            value: l10n.thirtyDays, // Replaced hardcoded '30 días'
            iconColor: AppTheme.accentBlue,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }
}
