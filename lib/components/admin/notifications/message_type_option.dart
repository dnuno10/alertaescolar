import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';

class MessageTypeOption extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String description;
  final Size screenSize;
  final String selectedType;
  final Function(String) onSelect;

  const MessageTypeOption({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
    required this.screenSize,
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedType == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onSelect(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : AppTheme.getBackgroundColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: isSelected ? color : AppTheme.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getMediumPadding(screenSize) * 0.8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : AppTheme.getBorderColor(context).withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : AppTheme.getTextSecondaryColor(context),
                size: screenSize.height * 0.03,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getBodyLarge(screenSize).copyWith(
                      color: isSelected
                          ? color
                          : AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    description,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: screenSize.height * 0.018,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
