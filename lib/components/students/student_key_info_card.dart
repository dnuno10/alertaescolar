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
    // Check if we have the required data from the llaves table
    if (student.fechaRegistroLlave == null) {
      return 'Información no disponible';
    }

    // Get the current time
    final now = DateTime.now();

    // If fechaDesactivacionLlave is null, the key doesn't expire
    if (student.fechaDesactivacionLlave == null) {
      return 'Sin límite de tiempo';
    }

    // The remaining time is the difference between now and fecha_desactivacion
    final expirationDate = student.fechaDesactivacionLlave!;

    // Check if already expired
    if (expirationDate.isBefore(now)) {
      return 'Expirado';
    }

    // Calculate remaining time
    final difference = expirationDate.difference(now);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;

      if (days > 1) {
        return '$days días restantes';
      } else if (days == 1) {
        if (hours > 0) {
          return '1 día y $hours horas restantes';
        } else {
          return '1 día restante';
        }
      }
    }

    if (difference.inHours > 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 1) {
        return '$hours horas restantes';
      } else {
        if (minutes > 0) {
          return '1 hora y $minutes minutos restantes';
        } else {
          return '1 hora restante';
        }
      }
    }

    if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return '$minutes minutos restantes';
    }

    return 'Menos de 1 minuto restante';
  }
}
