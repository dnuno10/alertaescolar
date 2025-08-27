import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ContactCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Size screenSize;
  final bool isClickable;
  final VoidCallback? onTap;

  const ContactCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.screenSize,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.getMediumPadding(screenSize)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isClickable
              ? (onTap ?? () => _handleContactTap(context, label, value))
              : null,
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.7),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    icon,
                    size: screenSize.height * 0.02,
                    color: AppTheme.successColor,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.003),
                      Text(
                        value,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isClickable)
                  Icon(
                    Icons.open_in_new_rounded,
                    size: screenSize.height * 0.018,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContactTap(BuildContext context, String type, String value) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.openContactInfo('$type: $value'),
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
  }
}
