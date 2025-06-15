import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final Color? color;

  const LoadingDialog({
    super.key,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.getBackgroundColor(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Center(
              //   child: Image.asset(
              //     "images/alertaescolar_logo.png",
              //     width: MediaQuery.of(context).size.height * 0.045,
              //     height: MediaQuery.of(context).size.height * 0.045,
              //   ),
              // ),
              CircularProgressIndicator(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              if (message.isNotEmpty) ...[
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
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) => LoadingDialog(
        message: message,
        color: color,
      ),
    );
  }

  static void hide(BuildContext context) {
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error hiding loading dialog: $e');
    }
  }
}
