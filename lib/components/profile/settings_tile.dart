import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Size screenSize;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.screenSize,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Row(
            children: [
              Container(
                width: screenSize.width * 0.1,
                height: screenSize.width * 0.1,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentPurple,
                  size: screenSize.width * 0.05,
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
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: screenSize.width * 0.04,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
