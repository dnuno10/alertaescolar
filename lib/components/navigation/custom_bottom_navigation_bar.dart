import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'nav_item.dart';
import 'nav_item_with_badge.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Size screenSize;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.getLargeRadius(screenSize))),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withOpacity(0.06),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, -screenSize.height * 0.008),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: screenSize.width * 0.03,
            right: screenSize.width * 0.03,
            top: screenSize.height * 0.008,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.dashboard_rounded,
                label: l10n.homeTitle,
                index: 0,
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
                screenSize: screenSize,
              ),
              NavItem(
                icon: Icons.people_rounded,
                label: l10n.students,
                index: 1,
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
                screenSize: screenSize,
              ),
              NavItemWithBadge(
                icon: Icons.notifications_rounded,
                label: l10n.notifications,
                index: 2,
                isSelected: selectedIndex == 2,
                onTap: () => onItemSelected(2),
                screenSize: screenSize,
              ),
              NavItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                index: 3,
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected(3),
                screenSize: screenSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
