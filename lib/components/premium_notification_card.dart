// 🎯 Premium Notification Card Component - Following Design References
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/app_theme.dart';

class PremiumNotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String? studentName;
  final DateTime timestamp;
  final String type;
  final bool isUnread;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showDismiss;

  const PremiumNotificationCard({
    super.key,
    required this.title,
    required this.message,
    this.studentName,
    required this.timestamp,
    required this.type,
    this.isUnread = false,
    this.onTap,
    this.onDismiss,
    this.showDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium, vertical: 8),
      decoration: BoxDecoration(
        color: isUnread
            ? _getTypeColor().withOpacity(0.03)
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: isUnread
              ? _getTypeColor().withOpacity(0.2)
              : AppTheme.borderLight,
          width: isUnread ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Row(
              children: [
                // 🎨 Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // 📝 Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Unread Indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppTheme.textPrimaryLight,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) _buildUnreadBadge(),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Student Name (if provided)
                      if (studentName != null) ...[
                        Text(
                          studentName!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _getTypeColor(),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Message
                      Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondaryLight,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Timestamp
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: AppTheme.textSecondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatTimestamp(timestamp),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Wrap with Dismissible if dismiss is enabled
    if (showDismiss && onDismiss != null) {
      return Dismissible(
        key: Key('notification_${title}_${timestamp.toString()}'),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        onDismissed: (_) => onDismiss?.call(),
        child: card,
      );
    }

    return card;
  }

  Widget _buildUnreadBadge() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _getTypeColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getTypeColor().withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        gradient: LinearGradient(
          colors: [
            AppTheme.errorColor.withOpacity(0.8),
            AppTheme.errorColor,
          ],
        ),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            'Eliminar',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (type.toLowerCase()) {
      case 'academic':
      case 'academico':
        return AppTheme.accentBlue;
      case 'event':
      case 'evento':
        return AppTheme.accentPurple;
      case 'alert':
      case 'alerta':
        return AppTheme.errorColor;
      case 'general':
        return AppTheme.successColor;
      case 'attendance':
      case 'asistencia':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'academic':
      case 'academico':
        return Icons.school_outlined;
      case 'event':
      case 'evento':
        return Icons.event_outlined;
      case 'alert':
      case 'alerta':
        return Icons.warning_amber_outlined;
      case 'general':
        return Icons.info_outline;
      case 'attendance':
      case 'asistencia':
        return Icons.person_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
      }
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}
