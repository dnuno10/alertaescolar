import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class SentAnnouncementsList extends StatelessWidget {
  final Size screenSize;

  const SentAnnouncementsList({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Mock data for sent announcements
    final announcements = [
      {
        'id': '1',
        'title': 'Reunión de Padres de Familia',
        'content':
            'Se les convoca a la reunión programada para el próximo viernes...',
        'recipients': 'Grado 3°A',
        'priority': 'high',
        'sentDate': DateTime.now().subtract(const Duration(hours: 2)),
        'sentBy': 'María López',
        'status': 'delivered',
        'readCount': 25,
        'totalRecipients': 28,
      },
      {
        'id': '2',
        'title': 'Cambio de Horario',
        'content':
            'Debido a actividades especiales, el horario de mañana será modificado...',
        'recipients': 'Todos los grados',
        'priority': 'urgent',
        'sentDate': DateTime.now().subtract(const Duration(hours: 5)),
        'sentBy': 'Juan Hernández',
        'status': 'delivered',
        'readCount': 180,
        'totalRecipients': 200,
      },
      {
        'id': '3',
        'title': 'Permiso Especial - Ana García',
        'content': 'Se autoriza la salida temprana de la estudiante...',
        'recipients': 'Ana García Martínez (3°A)',
        'priority': 'medium',
        'sentDate': DateTime.now().subtract(const Duration(days: 1)),
        'sentBy': 'María López',
        'status': 'read',
        'readCount': 1,
        'totalRecipients': 1,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.025,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    l10n.totalAnnouncementsSent,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Announcements List
          if (announcements.isEmpty)
            _EmptyState(screenSize: screenSize, l10n: l10n)
          else
            Expanded(
              child: ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return _AnnouncementItem(
                    announcement: announcement,
                    screenSize: screenSize,
                    isLast: index == announcements.length - 1,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AnnouncementItem extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final Size screenSize;
  final bool isLast;

  const _AnnouncementItem({
    required this.announcement,
    required this.screenSize,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final priority = announcement['priority'] as String;
    final priorityColor = _getPriorityColor(priority);
    final status = announcement['status'] as String;
    final statusColor = _getStatusColor(status);
    final readRate = (announcement['readCount'] as int) /
        (announcement['totalRecipients'] as int);

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: screenSize.height * 0.003,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.5),
                ),
                child: Text(
                  _getPriorityText(priority, l10n),
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _getTimeAgo(announcement['sentDate'] as DateTime, l10n),
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Title
          Text(
            announcement['title'] as String,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          // Content preview
          Text(
            announcement['content'] as String,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Recipients and stats
          Row(
            children: [
              Icon(
                Icons.people_rounded,
                color: AppTheme.getTextSecondaryColor(context),
                size: screenSize.height * 0.018,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Expanded(
                child: Text(
                  announcement['recipients'] as String,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          // Status and read rate
          Row(
            children: [
              Container(
                width: screenSize.height * 0.008,
                height: screenSize.height * 0.008,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                _getStatusText(status, l10n),
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${announcement['readCount']}/${announcement['totalRecipients']} ${l10n.read}',
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          // Read rate bar
          Container(
            height: screenSize.height * 0.004,
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(screenSize.height * 0.002),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: readRate,
              child: Container(
                decoration: BoxDecoration(
                  color: readRate > 0.8
                      ? AppTheme.successColor
                      : readRate > 0.5
                          ? AppTheme.warningColor
                          : AppTheme.errorColor,
                  borderRadius:
                      BorderRadius.circular(screenSize.height * 0.002),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppTheme.errorColor;
      case 'high':
        return AppTheme.warningColor;
      case 'medium':
        return AppTheme.accentBlue;
      case 'low':
        return AppTheme.successColor;
      default:
        return AppTheme.accentBlue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppTheme.successColor;
      case 'read':
        return AppTheme.accentBlue;
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
        return AppTheme.errorColor;
      default:
        return AppTheme.accentBlue;
    }
  }

  String _getPriorityText(String priority, AppLocalizations l10n) {
    switch (priority) {
      case 'urgent':
        return l10n.urgent;
      case 'high':
        return l10n.high;
      case 'medium':
        return l10n.medium;
      case 'low':
        return l10n.low;
      default:
        return l10n.medium;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'delivered':
        return l10n.delivered;
      case 'read':
        return l10n.read;
      case 'pending':
        return l10n.pending;
      case 'failed':
        return l10n.failed;
      default:
        return l10n.unknown;
    }
  }

  String _getTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.now;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final Size screenSize;
  final AppLocalizations l10n;

  const _EmptyState({
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: screenSize.height * 0.08,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.noAnnouncementsSent,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.createFirstAnnouncement,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
