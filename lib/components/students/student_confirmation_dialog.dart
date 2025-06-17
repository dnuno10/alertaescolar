import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class StudentConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const StudentConfirmationDialog({
    super.key,
    required this.studentData,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: AppTheme.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: AppTheme.successColor,
                    size: screenSize.height * 0.03,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Text(
                    l10n.confirmStudentRegistration,
                    style: AppTheme.getH2(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize)),

            // Student info
            Text(
              l10n.studentToRegister,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            Container(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.person_rounded,
                    l10n.studentName,
                    studentData['nombre'] ?? l10n.unknown,
                    screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  _buildInfoRow(
                    context,
                    Icons.badge_rounded,
                    l10n.studentId,
                    studentData['matricula'] ?? l10n.noId,
                    screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  _buildInfoRow(
                    context,
                    Icons.class_rounded,
                    l10n.gradeGroup,
                    '${studentData['nivelEducativo']} - ${studentData['grupo']}',
                    screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  _buildInfoRow(
                    context,
                    Icons.schedule_rounded,
                    l10n.shift,
                    studentData['turno'] ?? l10n.unknown,
                    screenSize,
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize)),

            // Confirmation message
            Container(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.height * 0.025,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      l10n.confirmRegistrationMessage,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.accentBlue,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize)),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SolidButton(
                    onPressed: isLoading ? () {} : onCancel,
                    label: l10n.cancel,
                    backgroundColor: AppTheme.getTextSecondaryColor(context),
                    screenSize: screenSize,
                    width: double.infinity,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: SolidButton(
                    onPressed: isLoading ? () {} : onConfirm,
                    label:
                        isLoading ? l10n.registering : l10n.confirmRegistration,
                    icon: isLoading ? null : Icons.check_rounded,
                    backgroundColor: AppTheme.successColor,
                    screenSize: screenSize,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Size screenSize,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.accentBlue,
          size: screenSize.height * 0.02,
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Text(
          '$label:',
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
        Expanded(
          child: Text(
            value,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
