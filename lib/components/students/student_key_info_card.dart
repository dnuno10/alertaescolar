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
            value: _calculateRemainingTime(context),
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

    return '${l10n.activated} (${linkedTutorsCount} ${linkedTutorsCount == 1 ? l10n.linkedTutor : l10n.linkedTutors})';
  }

  String _calculateRemainingTime(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Check if we have the required data from the llaves table
    if (student.fechaRegistroLlave == null) {
      return l10n.informationNotAvailable;
    }

    // Get the current time
    final now = DateTime.now();

    // If fechaDesactivacionLlave is null, the key doesn't expire
    if (student.fechaDesactivacionLlave == null) {
      return l10n.noTimeLimit;
    }

    // The remaining time is the difference between now and fecha_desactivacion
    final expirationDate = student.fechaDesactivacionLlave!;

    // Check if already expired
    if (expirationDate.isBefore(now)) {
      return l10n.expired;
    }

    // Calculate remaining time
    final difference = expirationDate.difference(now);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;

      if (days > 0) {
        return days == 1 ? l10n.oneDayRemaining : l10n.daysRemaining(days);
      } else if (hours > 0) {
        return hours == 1 ? l10n.oneHourRemaining : l10n.hoursRemaining(hours);
      } else if (difference.inMinutes > 0) {
        final minutes = difference.inMinutes;
        return minutes == 1
            ? l10n.oneMinuteRemaining
            : l10n.minutesRemaining(minutes);
      } else {
        return l10n.lessThanOneMinuteRemaining;
      }
    }

    if (difference.inHours > 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return hours == 1 ? l10n.oneHourRemaining : l10n.hoursRemaining(hours);
      } else if (minutes > 0) {
        return minutes == 1
            ? l10n.oneMinuteRemaining
            : l10n.minutesRemaining(minutes);
      } else {
        return l10n.lessThanOneMinuteRemaining;
      }
    }

    if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return minutes == 1
          ? l10n.oneMinuteRemaining
          : l10n.minutesRemaining(minutes);
    }

    return l10n.lessThanOneMinuteRemaining;
  }
}
