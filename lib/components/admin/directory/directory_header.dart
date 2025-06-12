import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class DirectoryHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const DirectoryHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            AppTheme.getSmallPadding(screenSize),
        left: AppTheme.getMediumPadding(screenSize),
        right: AppTheme.getMediumPadding(screenSize),
        bottom: AppTheme.getLargePadding(screenSize),
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Actions Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.getH1(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      subtitle,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
