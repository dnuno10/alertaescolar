import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class PersonalDataInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Size screenSize;

  const PersonalDataInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
              vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(screenSize) * 0.5),
            ),
            child: Text(
              value,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
