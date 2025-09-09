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
    final pad = AppTheme.getSmallPadding(screenSize);
    final rad = AppTheme.getMediumRadius(screenSize);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isClickable ? (onTap ?? () => _handleContactTap(context)) : null,
        borderRadius: BorderRadius.circular(rad),
        child: Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(rad),
            border:
                Border.all(color: AppTheme.getBorderColor(context), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.7),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: Icon(icon,
                    size: screenSize.height * 0.020,
                    color: AppTheme.successColor),
              ),
              SizedBox(width: pad),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontSize: screenSize.height * 0.018,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isClickable)
                Icon(Icons.open_in_new_rounded,
                    size: screenSize.height * 0.018,
                    color: AppTheme.getTextSecondaryColor(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContactTap(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.openContactInfo('$label: $value'),
          style: AppTheme.getCaption(size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(size)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
