import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'status_chip.dart';

class AttendanceRecordItem extends StatelessWidget {
  final Map<String, dynamic> record;
  final bool isLast;
  final Size screenSize;

  const AttendanceRecordItem({
    super.key,
    required this.record,
    required this.isLast,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final date = record['date'] as DateTime;
    final status = record['status'] as String;
    final time = record['time'] as TimeOfDay?;
    final scannedBy = record['scannedBy'] as String;
    final location = record['location'] as String;
    final notes = record['notes'] as String?;

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(context, status);

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize),
      ),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: screenSize.height * 0.04,
                height: screenSize.height * 0.04,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: screenSize.height * 0.02,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (time != null)
                          Text(
                            time.format(context),
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.25),
                    Row(
                      children: [
                        StatusChip(
                          text: statusText,
                          color: statusColor,
                          screenSize: screenSize,
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Expanded(
                          flex: 2,
                          child: Text(
                            location,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Expanded(
                          flex: 2,
                          child: Text(
                            scannedBy,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (notes != null) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.75),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_rounded,
                    color: AppTheme.warningColor,
                    size: screenSize.height * 0.018,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Expanded(
                    child: Text(
                      notes,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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

  String _getStatusText(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);

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
