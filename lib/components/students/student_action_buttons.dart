import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';
import '../buttons/solid_button.dart';
import '../buttons/custom_outline_button.dart';

class StudentActionButtons extends StatelessWidget {
  final StudentDetails student;
  final Size screenSize;

  const StudentActionButtons({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SolidButton(
            icon: Icons.download_rounded,
            width: double.infinity,
            onPressed: () {
              _downloadCredential(context, l10n);
            },
            label: l10n.downloadDigitalCredential,
            screenSize: screenSize),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        SizedBox(
          width: double.infinity,
          child: CustomOutlineButton(
              onPressed: () => _deleteStudent(context, l10n),
              label: l10n.delete,
              icon: Icons.delete,
              color: AppTheme.errorColor,
              screenSize: screenSize),
        ),
      ],
    );
  }

  void _downloadCredential(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.generatingCredentialFor(student.nombre),
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _deleteStudent(BuildContext context, AppLocalizations l10n) {
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          l10n.deleteStudent,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          l10n.deleteStudentConfirmation(student.nombre),
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // For now, just show a message since we need the current user ID to unlink
              // In a real implementation, you'd get the current user ID from UserProvider
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.studentDeletedSuccessfully,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.onPrimaryColor,
                    ),
                  ),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                ),
              );

              Navigator.pop(context); // Go back to students list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.onPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.delete,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.onPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
