import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ReportChart extends StatelessWidget {
  final Size screenSize;
  final String reportType;
  final String period;
  final String grade;
  final String group;

  const ReportChart({
    super.key,
    required this.screenSize,
    required this.reportType,
    required this.period,
    required this.grade,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          // Header
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.successColor,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  _getChartTitle(reportType, l10n),
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              _buildFilterSummary(context, l10n),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Chart Area
          SizedBox(
            height: screenSize.height * 0.35,
            child: _buildChart(context, l10n),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Statistics Summary
          _buildStatsSummary(context, l10n),
        ],
      ),
    );
  }

  Widget _buildFilterSummary(BuildContext context, AppLocalizations l10n) {
    final filters = <String>[];

    if (grade.isNotEmpty) filters.add(grade);
    if (group.isNotEmpty) filters.add(group);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize) * 0.5),
      ),
      child: Text(
        filters.isEmpty ? l10n.allStudents : filters.join(' - '),
        style: AppTheme.getCaptionSmall(screenSize).copyWith(
          color: AppTheme.accentBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, AppLocalizations l10n) {
    switch (reportType) {
      case 'attendance':
        return _buildAttendanceChart(context, l10n);
      case 'punctuality':
        return _buildPunctualityChart(context, l10n);
      case 'absence':
        return _buildAbsenceChart(context, l10n);
      case 'summary':
        return _buildSummaryChart(context, l10n);
      default:
        return _buildAttendanceChart(context, l10n);
    }
  }

  Widget _buildAttendanceChart(BuildContext context, AppLocalizations l10n) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.getBorderColor(context),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels = _getPeriodLabels();
                if (value.toInt() < labels.length) {
                  return Text(
                    labels[value.toInt()],
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _getAttendanceData(),
            isCurved: true,
            color: AppTheme.successColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.successColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.successColor.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  Widget _buildPunctualityChart(BuildContext context, AppLocalizations l10n) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: _getPunctualityData(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels = _getPeriodLabels();
                if (value.toInt() < labels.length) {
                  return Text(
                    labels[value.toInt()],
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.getBorderColor(context),
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAbsenceChart(BuildContext context, AppLocalizations l10n) {
    return PieChart(
      PieChartData(
        sections: _getAbsenceData(),
        centerSpaceRadius: screenSize.height * 0.08,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildSummaryChart(BuildContext context, AppLocalizations l10n) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: _getSummaryData(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels = [l10n.present, l10n.late, l10n.absent];
                if (value.toInt() < labels.length) {
                  return Text(
                    labels[value.toInt()],
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        maxY: 100,
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, AppLocalizations l10n) {
    final stats = _generateStats();

    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: l10n.attendanceRate,
              value: '${stats['attendanceRate']}%',
              color: AppTheme.successColor,
              screenSize: screenSize,
            ),
          ),
          Expanded(
            child: _StatItem(
              label: l10n.punctualityRate,
              value: '${stats['punctualityRate']}%',
              color: AppTheme.accentBlue,
              screenSize: screenSize,
            ),
          ),
          Expanded(
            child: _StatItem(
              label: l10n.absenceRate,
              value: '${stats['absenceRate']}%',
              color: AppTheme.errorColor,
              screenSize: screenSize,
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTitle(String type, AppLocalizations l10n) {
    switch (type) {
      case 'attendance':
        return l10n.attendanceReport;
      case 'punctuality':
        return l10n.punctualityReport ?? 'Reporte de Puntualidad';
      case 'absence':
        return l10n.absenceReport ?? 'Reporte de Ausencias';
      case 'summary':
        return l10n.summaryReport ?? 'Reporte Resumen';
      default:
        return l10n.attendanceReport;
    }
  }

  List<String> _getPeriodLabels() {
    switch (period) {
      case 'daily':
        return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
      case 'weekly':
        return ['S1', 'S2', 'S3', 'S4'];
      case 'monthly':
        return ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
      default:
        return ['P1', 'P2', 'P3', 'P4', 'P5'];
    }
  }

  List<FlSpot> _getAttendanceData() {
    // Mock data
    return [
      const FlSpot(0, 85),
      const FlSpot(1, 92),
      const FlSpot(2, 88),
      const FlSpot(3, 95),
      const FlSpot(4, 90),
      const FlSpot(5, 87),
    ];
  }

  List<BarChartGroupData> _getPunctualityData() {
    return [
      BarChartGroupData(
          x: 0,
          barRods: [BarChartRodData(toY: 25, color: AppTheme.warningColor)]),
      BarChartGroupData(
          x: 1,
          barRods: [BarChartRodData(toY: 18, color: AppTheme.warningColor)]),
      BarChartGroupData(
          x: 2,
          barRods: [BarChartRodData(toY: 30, color: AppTheme.warningColor)]),
      BarChartGroupData(
          x: 3,
          barRods: [BarChartRodData(toY: 15, color: AppTheme.warningColor)]),
      BarChartGroupData(
          x: 4,
          barRods: [BarChartRodData(toY: 22, color: AppTheme.warningColor)]),
    ];
  }

  List<PieChartSectionData> _getAbsenceData() {
    return [
      PieChartSectionData(
        color: AppTheme.successColor,
        value: 85,
        title: '85%',
        radius: screenSize.height * 0.05,
        titleStyle: AppTheme.getCaption(screenSize).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AppTheme.warningColor,
        value: 10,
        title: '10%',
        radius: screenSize.height * 0.04,
        titleStyle: AppTheme.getCaption(screenSize).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AppTheme.errorColor,
        value: 5,
        title: '5%',
        radius: screenSize.height * 0.04,
        titleStyle: AppTheme.getCaption(screenSize).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  List<BarChartGroupData> _getSummaryData() {
    return [
      BarChartGroupData(
          x: 0,
          barRods: [BarChartRodData(toY: 85, color: AppTheme.successColor)]),
      BarChartGroupData(
          x: 1,
          barRods: [BarChartRodData(toY: 10, color: AppTheme.warningColor)]),
      BarChartGroupData(
          x: 2, barRods: [BarChartRodData(toY: 5, color: AppTheme.errorColor)]),
    ];
  }

  Map<String, int> _generateStats() {
    return {
      'attendanceRate': 89,
      'punctualityRate': 78,
      'absenceRate': 11,
    };
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Size screenSize;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.getH2(screenSize).copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
