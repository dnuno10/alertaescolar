import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class AttendanceListCard extends StatelessWidget {
  final Size screenSize;
  final List<Map<String, dynamic>> attendanceRecords;

  const AttendanceListCard({
    super.key,
    required this.screenSize,
    required this.attendanceRecords,
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
              Icon(
                Icons.list_alt_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.scannedStudents,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              if (attendanceRecords.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize) * 0.5),
                  ),
                  child: Text(
                    attendanceRecords.length.toString(),
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.accentPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Attendance Records List
          if (attendanceRecords.isEmpty)
            _buildEmptyState(context, l10n)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = attendanceRecords[index];
                return _buildAttendanceItem(context, record, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: screenSize.width * 0.15,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noStudentsScanned,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            l10n.startScanningToSeeRecords,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(
      BuildContext context, Map<String, dynamic> record, int index) {
    final l10n = AppLocalizations.of(context);
    final isLast = index == attendanceRecords.length - 1;

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record['status']) {
      case 'present':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle_rounded;
        statusText = l10n.present;
        break;
      case 'late':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule_rounded;
        statusText = l10n.late;
        break;
      default:
        statusColor = AppTheme.accentBlue;
        statusIcon = Icons.info_rounded;
        statusText = l10n.present;
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize),
      ),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          // Student Avatar
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Center(
              child: Text(
                record['studentName']?[0]?.toUpperCase() ?? 'S',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(width: AppTheme.getMediumPadding(screenSize)),

          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['studentName'] ?? l10n.unknown,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.003),
                Text(
                  '${record['studentId'] ?? 'N/A'} • ${record['grade'] ?? 'N/A'}',
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),

          // Status and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: screenSize.width * 0.035,
                      color: statusColor,
                    ),
                    SizedBox(width: screenSize.width * 0.01),
                    Text(
                      statusText,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * 0.003),
              Text(
                record['scanTime'] ?? l10n.now,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
