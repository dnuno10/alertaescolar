import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'contact_button.dart';

class ContactInfoCard extends StatelessWidget {
  final Size screenSize;

  const ContactInfoCard({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.needScheduleChanges,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            l10n.scheduleChangesDescription,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: ContactButton(
                  icon: Icons.email_rounded,
                  label: l10n.email,
                  subtitle: 'soporte@alertaescolar.com',
                  color: AppTheme.accentBlue,
                  screenSize: screenSize,
                  onTap: () => _showContactInfo(
                      context, l10n.email, 'soporte@alertaescolar.com'),
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: ContactButton(
                  icon: Icons.phone_rounded,
                  label: l10n.phone,
                  subtitle: '+52 55 1234 5678',
                  color: AppTheme.successColor,
                  screenSize: screenSize,
                  onTap: () =>
                      _showContactInfo(context, l10n.phone, '+52 55 1234 5678'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContactInfo(BuildContext context, String method, String contact) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
        title: Text(
          l10n.contactVia(method),
          style: AppTheme.getSubtitle1(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          contact,
          style: AppTheme.getBodyMedium(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
