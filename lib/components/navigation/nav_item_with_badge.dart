import 'package:alertaescolar/managers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';
import 'package:provider/provider.dart';

class NavItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;

  const NavItemWithBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          // Mark all notifications as read when navigating to notifications view
          final provider =
              Provider.of<NotificationProvider>(context, listen: false);
          if (provider.unreadCount > 0) {
            provider.markAllAsRead();
          }
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.02,
            vertical: screenSize.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentPurple.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenSize.height * 0.006),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentPurple
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize) * 0.8),
                    ),
                    child: Icon(
                      icon,
                      size: screenSize.height * 0.025,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      final unreadCount = notificationProvider.unreadCount;
                      if (unreadCount > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(screenSize.height * 0.003),
                            decoration: const BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: screenSize.height * 0.018,
                              minHeight: screenSize.height * 0.018,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.003),
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: isSelected
                      ? AppTheme.accentPurple
                      : AppTheme.getTextSecondaryColor(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
