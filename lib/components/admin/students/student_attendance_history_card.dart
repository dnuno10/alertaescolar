import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../views/admin/students/student_attendance_history_view.dart';

class StudentAttendanceHistoryCard extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const StudentAttendanceHistoryCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final attendanceRecords = _generateMockAttendanceHistory();
    final stats = _calculateAttendanceStats(attendanceRecords);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.1),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, screenSize.height * 0.008),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.successColor.withValues(alpha: 0.1),
                      AppTheme.successColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: AppTheme.successColor,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.attendanceHistory,
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.last30Days,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick stats indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Text(
                  '${stats['rate']}%',
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Modern Statistics Grid
          Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getBackgroundColor(context),
                  AppTheme.getBackgroundColor(context).withValues(alpha: 0.5),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModernStatItem(
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.successColor,
                    value: stats['present'].toString(),
                    label: l10n.present,
                    screenSize: screenSize,
                  ),
                ),
                Container(
                  width: 1,
                  height: screenSize.height * 0.06,
                  color:
                      AppTheme.getBorderColor(context).withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _ModernStatItem(
                    icon: Icons.schedule_rounded,
                    color: AppTheme.warningColor,
                    value: stats['late'].toString(),
                    label: l10n.late,
                    screenSize: screenSize,
                  ),
                ),
                Container(
                  width: 1,
                  height: screenSize.height * 0.06,
                  color:
                      AppTheme.getBorderColor(context).withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _ModernStatItem(
                    icon: Icons.cancel_rounded,
                    color: AppTheme.errorColor,
                    value: stats['absent'].toString(),
                    label: l10n.absent,
                    screenSize: screenSize,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Section Header with count
          Row(
            children: [
              Text(
                l10n.recentRecords,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.6,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(screenSize) * 0.6,
                  ),
                ),
                child: Text(
                  '${attendanceRecords.take(5).length}',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Enhanced Records List
          ...attendanceRecords
              .take(5)
              .map((record) => _ModernAttendanceRecordItem(
                    record: record,
                    screenSize: screenSize,
                    l10n: l10n,
                  )),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Enhanced Action Button
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFullAttendanceHistory(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppTheme.getMediumPadding(screenSize),
                    horizontal: AppTheme.getLargePadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.successColor.withValues(alpha: 0.1),
                        AppTheme.successColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        color: AppTheme.successColor,
                        size: screenSize.height * 0.022,
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Text(
                        l10n.viewAllRecords,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppTheme.successColor,
                        size: screenSize.height * 0.018,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockAttendanceHistory() {
    final records = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday <= 5) {
        // Only weekdays
        final status =
            i % 10 == 0 ? 'absent' : (i % 8 == 0 ? 'late' : 'present');
        final time = status == 'late'
            ? TimeOfDay(hour: 7, minute: 45 + (i % 20))
            : TimeOfDay(hour: 7, minute: 20 + (i % 15));

        records.add({
          'date': date,
          'status': status,
          'time': time,
          'scannedBy': ['María López', 'Juan Hernández', 'Ana García'][i % 3],
        });
      }
    }

    return records.reversed.toList();
  }

  Map<String, int> _calculateAttendanceStats(
      List<Map<String, dynamic>> records) {
    final present = records.where((r) => r['status'] == 'present').length;
    final late = records.where((r) => r['status'] == 'late').length;
    final absent = records.where((r) => r['status'] == 'absent').length;
    final total = records.length;
    final rate = total > 0 ? ((present + late) * 100 / total).round() : 0;

    return {
      'present': present,
      'late': late,
      'absent': absent,
      'rate': rate,
    };
  }

  void _showFullAttendanceHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentAttendanceHistoryView(
          student: student,
        ),
      ),
    );
  }
}

class _ModernStatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final Size screenSize;

  const _ModernStatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(screenSize) * 0.8),
          ),
          child: Icon(
            icon,
            color: color,
            size: screenSize.height * 0.022,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.6),
        Text(
          value,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.2),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ModernAttendanceRecordItem extends StatelessWidget {
  final Map<String, dynamic> record;
  final Size screenSize;
  final AppLocalizations l10n;

  const _ModernAttendanceRecordItem({
    required this.record,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final date = record['date'] as DateTime;
    final status = record['status'] as String;
    final time = record['time'] as TimeOfDay?;
    final scannedBy = record['scannedBy'] as String;

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(status);

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Could add detail view
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: screenSize.height * 0.04,
                  height: screenSize.height * 0.04,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    statusIcon,
                    color: Colors.white,
                    size: screenSize.height * 0.02,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${date.day}/${date.month}/${date.year}',
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (time != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppTheme.getSmallPadding(screenSize) * 0.5,
                                vertical:
                                    AppTheme.getSmallPadding(screenSize) * 0.2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.getTextSecondaryColor(context)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.getSmallRadius(screenSize) * 0.5,
                                ),
                              ),
                              child: Text(
                                time.format(context),
                                style: AppTheme.getCaptionSmall(screenSize)
                                    .copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  AppTheme.getSmallPadding(screenSize) * 0.6,
                              vertical:
                                  AppTheme.getSmallPadding(screenSize) * 0.25,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(screenSize) * 0.6,
                              ),
                            ),
                            child: Text(
                              statusText,
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: screenSize.height * 0.012,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            scannedBy,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppTheme.successColor;
      case 'late':
        return AppTheme.warningColor;
      case 'absent':
        return AppTheme.errorColor;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_rounded;
      case 'late':
        return Icons.schedule_rounded;
      case 'absent':
        return Icons.close_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return l10n.present;
      case 'late':
        return l10n.late;
      case 'absent':
        return l10n.absent;
      default:
        return l10n.unknown;
    }
  }
}
