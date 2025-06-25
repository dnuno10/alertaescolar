import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';

class NotificationSettingToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Size screenSize;

  const NotificationSettingToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: screenSize.width * 0.12,
          height: screenSize.width * 0.12,
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentPurple,
            size: screenSize.width * 0.06,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(context),
                  height: 1.4,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (value) {
            HapticFeedback.mediumImpact();
            onChanged(value);
          },
          activeColor: AppTheme.accentPurple,
          activeTrackColor: AppTheme.accentPurple.withOpacity(0.3),
          inactiveThumbColor: AppTheme.getTextSecondaryColor(context),
          inactiveTrackColor:
              AppTheme.getTextSecondaryColor(context).withOpacity(0.3),
        ),
      ],
    );
  }
}
