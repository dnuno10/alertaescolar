import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';

class AdminActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Size screenSize;

  const AdminActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and action indicator
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getMediumPadding(screenSize) * 0.8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(screenSize)),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: screenSize.height * 0.032,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color,
                      size: screenSize.height * 0.018,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Title and description
              Text(
                title,
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                description,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  height: 1.3,
                ),
              ),

              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Action button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: color,
                      size: screenSize.height * 0.02,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      'Acceder',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
