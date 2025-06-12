import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'admin_navigation_item.dart';

class AdminBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Size screenSize;

  const AdminBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
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
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.06),
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
              AdminNavigationItem(
                icon: Icons.dashboard_rounded,
                label: l10n.adminDashboard,
                index: 0,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
                screenSize: screenSize,
              ),
              AdminNavigationItem(
                icon: Icons.qr_code_scanner_rounded,
                label: l10n.attendanceControl,
                index: 1,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
                screenSize: screenSize,
              ),
              AdminNavigationItem(
                icon: Icons.group_rounded,
                label: l10n.studentsDirectory,
                index: 2,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
                screenSize: screenSize,
              ),
              AdminNavigationItem(
                icon: Icons.school_rounded,
                label: l10n.schoolSettings,
                index: 3,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
                screenSize: screenSize,
              ),
              AdminNavigationItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                index: 4,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
                screenSize: screenSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
