import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'status_card.dart';

class ShiftSummary extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int tolerance; // minutos
  final bool aplicarTolerancia; // Si FALSE, no se aplica tolerancia
  final Size screenSize;

  const ShiftSummary({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.tolerance,
    required this.aplicarTolerancia,
    required this.screenSize,
  });

  // ===== Utils de tiempo (12h + AM/PM) =====
  String _format12WithAmPm(TimeOfDay t) {
    final hour12 = (t.hourOfPeriod == 0) ? 12 : t.hourOfPeriod; // 0 -> 12
    final hh = hour12.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final suffix = (t.period == DayPeriod.am) ? 'AM' : 'PM';
    return '$hh:$mm $suffix';
  }

  /// Suma minutos a un TimeOfDay y regresa la hora normalizada (0..23h).
  /// Devuelve además si se cruzó al día siguiente.
  ({TimeOfDay time, bool nextDay}) _addMinutes(TimeOfDay t, int minutes) {
    final total = t.hour * 60 + t.minute + minutes;
    const minutesPerDay = 24 * 60;
    final normalized =
        ((total % minutesPerDay) + minutesPerDay) % minutesPerDay;
    final nextDay = total >= minutesPerDay;
    return (
      time: TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60),
      nextDay: nextDay
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final padXS = AppTheme.getSmallPadding(screenSize) * 0.75;
    final padS = AppTheme.getSmallPadding(screenSize);
    final padM = AppTheme.getMediumPadding(screenSize);
    final radS = AppTheme.getSmallRadius(screenSize);
    final radM = AppTheme.getMediumRadius(screenSize);

    final toleranceCalc = _addMinutes(startTime, tolerance);
    final toleranceEnd = toleranceCalc.time;

    final scheduleText =
        '${_format12WithAmPm(startTime)} - ${_format12WithAmPm(endTime)}';
    final presentWindowText =
        '${_format12WithAmPm(startTime)} - ${_format12WithAmPm(toleranceEnd)}';
    final lateFromText = '${l10n.after} ${_format12WithAmPm(toleranceEnd)}'
        '${toleranceCalc.nextDay ? " (+1 día)" : ""}';

    return Container(
      padding: EdgeInsets.all(padM),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(radM),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        // 🚫 Sin sombras
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header =====
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(padXS),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(radS),
                  // ignore: deprecated_member_use
                  border: Border.all(color: color.withOpacity(0.35), width: 1),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: screenSize.height * 0.024,
                ),
              ),
              SizedBox(width: padS),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // Chip de tolerancia
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: padS, vertical: padXS * 0.9),
                decoration: BoxDecoration(
                  color: AppTheme.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(radS),
                  border: Border.all(
                      color: AppTheme.getBorderColor(context), width: 1),
                ),
                child: Text(
                  '${l10n.tolerance}: ${tolerance}m',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: padM),

          // ===== Estado: Presente / Tarde (columna full-width) =====
          if (aplicarTolerancia)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatusCard(
                  title: l10n.present,
                  time: presentWindowText,
                  color: AppTheme.successColor,
                  icon: Icons.check_circle_rounded,
                  screenSize: screenSize,
                ),
                SizedBox(height: padS),
                StatusCard(
                  title: l10n.late,
                  time: lateFromText,
                  color: AppTheme.warningColor,
                  icon: Icons.schedule_rounded,
                  screenSize: screenSize,
                ),
              ],
            )
          else
            // Si no se aplica tolerancia, mostrar solo mensaje informativo
            Container(
              padding: EdgeInsets.all(padM),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(radS),
                border: Border.all(
                  color: AppTheme.accentBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.height * 0.025,
                  ),
                  SizedBox(width: padS),
                  Expanded(
                    child: Text(
                      'Tolerancia desactivada: Todas las entradas se registran como a tiempo',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: padS),

          // ===== Línea informativa inferior =====
          Container(
            padding: EdgeInsets.all(padS),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(radS),
              border:
                  Border.all(color: AppTheme.getBorderColor(context), width: 1),
              // 🚫 Sin sombras
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.018,
                ),
                SizedBox(width: padS * 0.5),
                Expanded(
                  child: Text(
                    '${l10n.schedule}: $scheduleText',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
