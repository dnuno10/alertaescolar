import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';
import 'student_detail_row.dart';

class StudentKeyInfoCard extends StatelessWidget {
  final StudentDetails student;
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
            value: student.llaveCodigo?.isNotEmpty == true
                ? student.llaveCodigo!
                : l10n.notAssigned,
            iconColor: AppTheme.accentYellow,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.power_settings_new_rounded,
            label: l10n.status,
            value: _buildStatusText(l10n),
            iconColor: student.llaveActiva
                ? AppTheme.successColor
                : AppTheme.errorColor,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          StudentDetailRow(
            icon: Icons.schedule_rounded,
            label: l10n.remainingTime,
            value: _calculateRemainingTime(),
            iconColor: AppTheme.accentBlue,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }

  String _buildStatusText(AppLocalizations l10n) {
    if (!student.llaveActiva) {
      return l10n.deactivated;
    }

    final linkedTutorsCount = student.tutores.length;
    if (linkedTutorsCount == 0) {
      return l10n.activated;
    }

    return '${l10n.activated} ($linkedTutorsCount ${linkedTutorsCount == 1 ? 'tutor vinculado' : 'tutores vinculados'})';
  }

  String _calculateRemainingTime() {
    if (student.fechaRegistroLlave == null ||
        student.limiteVinculacion == null) {
      return 'Información no disponible';
    }

    // Calculate expiration date from key registration timestamp + limit in days
    final expirationDate = student.fechaRegistroLlave!
        .add(Duration(days: student.limiteVinculacion!.toInt()));

    final now = DateTime.now();
    final remainingDuration = expirationDate.difference(now);

    if (remainingDuration.isNegative) {
      return 'Expirado';
    }

    final remainingDays = remainingDuration.inDays;
    final remainingHours = remainingDuration.inHours % 24;

    if (remainingDays == 0) {
      if (remainingHours == 0) {
        final remainingMinutes = remainingDuration.inMinutes;
        return '$remainingMinutes minutos restantes';
      }
      return '$remainingHours horas restantes';
    } else if (remainingDays == 1) {
      return '1 día restante';
    } else {
      return '$remainingDays días restantes';
    }
  }
}
