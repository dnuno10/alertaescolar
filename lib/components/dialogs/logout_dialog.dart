import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/auth/Logout.dart';
import 'custom_alert_dialog.dart';
import '../buttons/dialog_action_button.dart';

class LogoutDialog extends StatelessWidget {
  final Size screenSize;

  const LogoutDialog({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(20);
    final logout = Logout();

    return CustomAlertDialog(
      title: l10n.signOut,
      // titleIcon: Icon(
      //   Icons.logout_rounded,
      //   color: AppTheme.errorColor,
      //   size: 28,
      // ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add illustration for visual impact
          Container(
            height: screenSize.height * 0.12,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black12 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.warning_amber_rounded,
                size: screenSize.height * 0.06,
                color: AppTheme.errorColor.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            l10n.confirmSignOut,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        DialogActionButton(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
          textColor: AppTheme.getTextSecondaryColor(context),
          screenSize: screenSize,
          // borderRadius: borderRadius,
          // // Add hover/press effect
          // hoverColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          // // Add leading icon for better visual hierarchy
          // icon: Icons.close_rounded,
        ),
        DialogActionButton(
          label: l10n.signOut,
          onPressed: () {
            Navigator.of(context).pop();
            // Implement logout logic by calling the Logout manager
            logout.signOut(context);
          },
          backgroundColor: AppTheme.errorColor,
          screenSize: screenSize,
          // borderRadius: borderRadius,
          // // Add hover/press effect for better feedback
          // splashColor: Colors.red.shade700,
          // // Add leading icon for visual consistency
          // icon: Icons.logout_rounded,
          // // Add slight elevation for button
          // elevation: 2,
          // // Add subtle shadow for depth
          // boxShadow: [
          //   BoxShadow(
          //     color: AppTheme.errorColor.withOpacity(0.4),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
      ],
      screenSize: screenSize,
      // Add rounded corners to the dialog
      // borderRadius: BorderRadius.circular(24),
      // // Add subtle animation when appearing
      // animationDuration: const Duration(milliseconds: 250),
      // // Add slight elevation for depth
      // elevation: 5,
      // // Add background blur effect for modern look
      // barrierColor: Colors.black54,
    );
  }

  static void show(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Add entrance animation to the dialog
    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => LogoutDialog(screenSize: screenSize),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
  }
}
