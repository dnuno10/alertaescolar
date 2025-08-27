import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class RecipientOption extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String description;
  final Size screenSize;
  final String selectedRecipient;
  final Function(String) onSelect;

  const RecipientOption({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.description,
    required this.screenSize,
    required this.selectedRecipient,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedRecipient == value;

    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentOrange.withOpacity(0.1)
              : AppTheme.getBackgroundColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentOrange
                : AppTheme.getBorderColor(context),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentOrange.withOpacity(0.2)
                    : AppTheme.getBorderColor(context).withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.accentOrange
                    : AppTheme.getTextSecondaryColor(context),
                size: screenSize.height * 0.022,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: isSelected
                          ? AppTheme.accentOrange
                          : AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
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
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accentOrange,
                size: screenSize.height * 0.025,
              ),
          ],
        ),
      ),
    );
  }
}
