import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingDialog extends StatelessWidget {
  static const String _routeName = '__loading_dialog__';

  final String message;
  final Color? color;

  const LoadingDialog({
    super.key,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final spinnerColor = color ?? AppTheme.getTextPrimaryColor(context);

    return Material(
      color: AppTheme.getBackgroundColor(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: spinnerColor),
            if (message.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.height * 0.02,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    Color? color,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: _routeName,
      barrierColor: Colors.black45, // mejora UX con overlay semitransparente
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, __, ___) =>
          LoadingDialog(message: message, color: color),
      useRootNavigator: true,
      routeSettings: const RouteSettings(name: _routeName),
    );
  }

  static void hide(BuildContext context) {
    try {
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
    } catch (e) {
      debugPrint('Error hiding loading dialog: $e');
    }
  }
}
