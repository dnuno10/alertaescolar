import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';

class PersonalDataNavigationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Size screenSize;

  const PersonalDataNavigationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, route);
        },
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Row(
            children: [
              Container(
                width: screenSize.width * 0.1,
                height: screenSize.width * 0.1,
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
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
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
