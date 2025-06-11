import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ReportTypeSelector extends StatelessWidget {
  final Size screenSize;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const ReportTypeSelector({
    super.key,
    required this.screenSize,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final reportTypes = [
      {
        'value': 'attendance',
        'label': l10n.attendanceReport,
        'description': l10n.attendanceReportDesc ??
            'Reporte detallado de asistencia por período',
        'icon': Icons.fact_check_rounded,
        'color': AppTheme.accentBlue,
      },
      {
        'value': 'punctuality',
        'label': l10n.punctualityReport ?? 'Reporte de Puntualidad',
        'description':
            l10n.punctualityReportDesc ?? 'Análisis de tardanzas y puntualidad',
        'icon': Icons.schedule_rounded,
        'color': AppTheme.warningColor,
      },
      {
        'value': 'absence',
        'label': l10n.absenceReport ?? 'Reporte de Ausencias',
        'description':
            l10n.absenceReportDesc ?? 'Estadísticas de ausentismo escolar',
        'icon': Icons.event_busy_rounded,
        'color': AppTheme.errorColor,
      },
      {
        'value': 'summary',
        'label': l10n.summaryReport ?? 'Reporte Resumen',
        'description':
            l10n.summaryReportDesc ?? 'Vista general de todas las métricas',
        'icon': Icons.analytics_rounded,
        'color': AppTheme.accentPurple,
      },
    ];

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.assessment_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.selectReportType ?? 'Seleccionar tipo de reporte',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
            mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
            childAspectRatio: 1.2,
            children: reportTypes
                .map((type) => _ReportTypeCard(
                      type: type,
                      isSelected: selectedType == type['value'],
                      onTap: () => onTypeChanged(type['value'] as String),
                      screenSize: screenSize,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeCard extends StatelessWidget {
  final Map<String, dynamic> type;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;

  const _ReportTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = type['color'] as Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: isSelected ? color : AppTheme.getBorderColor(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.75),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  type['icon'] as IconData,
                  color: isSelected ? Colors.white : color,
                  size: screenSize.height * 0.03,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              Text(
                type['label'] as String,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: isSelected
                      ? color
                      : AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                type['description'] as String,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
