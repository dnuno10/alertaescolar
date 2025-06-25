import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';

class AdminNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;
  final Size screenSize;

  const AdminNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;

    return Flexible(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.02,
              vertical: screenSize.height * 0.01),
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
              Container(
                padding: EdgeInsets.all(screenSize.height * 0.006),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.accentPurple : Colors.transparent,
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
