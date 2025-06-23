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
        ),
        DialogActionButton(
          label: l10n.signOut,
          onPressed: () => _handleLogout(context, logout),
          backgroundColor: AppTheme.errorColor,
          screenSize: screenSize,
        ),
      ],
      screenSize: screenSize,
    );
  }

  // Separate method to handle logout safely
  void _handleLogout(BuildContext context, Logout logout) {
    // Check if the widget is still mounted before proceeding
    if (!context.mounted) return;

    // Get the navigator before closing the dialog
    final navigator = Navigator.of(context);

    // Close the dialog first
    navigator.pop();

    // Use a post-frame callback to ensure the dialog is fully closed
    // before attempting logout
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Only proceed with signout if the context is still valid
        if (context.mounted) {
          await logout.signOut(context);
        }
      } catch (e) {
        debugPrint('Error during logout: $e');
      }
    });
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
