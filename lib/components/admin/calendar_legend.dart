import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class CalendarLegend extends StatelessWidget {
  final Size screenSize;

  const CalendarLegend({
    super.key,
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
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.01,
            offset: Offset(0, screenSize.height * 0.003),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.calendarLegend ?? 'Leyenda del calendario',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Wrap(
            spacing: AppTheme.getMediumPadding(screenSize),
            runSpacing: AppTheme.getSmallPadding(screenSize),
            children: [
              _LegendItem(
                color: AppTheme.successColor,
                label: l10n.fullAttendance ?? 'Asistencia completa',
                icon: Icons.check_circle_rounded,
                screenSize: screenSize,
              ),
              _LegendItem(
                color: AppTheme.warningColor,
                label: l10n.partialAttendance ?? 'Asistencia parcial',
                icon: Icons.schedule_rounded,
                screenSize: screenSize,
              ),
              _LegendItem(
                color: AppTheme.errorColor,
                label: l10n.lowAttendance ?? 'Baja asistencia',
                icon: Icons.cancel_rounded,
                screenSize: screenSize,
              ),
              _LegendItem(
                color: AppTheme.getTextSecondaryColor(context),
                label: l10n.noClasses ?? 'Sin clases',
                icon: Icons.event_busy_rounded,
                screenSize: screenSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  final Size screenSize;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenSize.height * 0.02,
          height: screenSize.height * 0.02,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: screenSize.height * 0.012,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }
}
