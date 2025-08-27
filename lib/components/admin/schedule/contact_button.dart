import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Size screenSize;
  final VoidCallback onTap;

  const ContactButton({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.screenSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: screenSize.height * 0.025,
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                label,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.25),
              Text(
                subtitle,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
