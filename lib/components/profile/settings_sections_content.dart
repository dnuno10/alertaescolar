import 'package:alertaescolar/widgets/language_selection_dialog.dart';
import 'package:alertaescolar/widgets/theme_selection_dialog.dart';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_routes.dart';
import '../profile/settings_section_title.dart';
import '../profile/settings_card.dart';
import '../profile/settings_tile.dart';
import '../profile/theme_settings_tile.dart';
import '../profile/language_settings_tile.dart';
import '../profile/logout_button.dart';
import '../dialogs/help_dialog.dart';
import '../dialogs/feedback_dialog.dart';
import '../dialogs/about_app_dialog.dart';
import '../dialogs/logout_dialog.dart';

class SettingsSectionsContent extends StatelessWidget {
  final Size screenSize;

  const SettingsSectionsContent({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Section
          SettingsSectionTitle(title: l10n.account, screenSize: screenSize),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SettingsCard(
            screenSize: screenSize,
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: l10n.personalData,
                subtitle: l10n.editProfileAndContactData,
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.personalDataNavigation),
                screenSize: screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              SettingsTile(
                icon: Icons.family_restroom_outlined,
                title: l10n.familyInformation,
                subtitle: l10n.emergencyDataAndContacts,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.familyInformation),
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Preferences Section
          SettingsSectionTitle(title: l10n.preferences, screenSize: screenSize),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SettingsCard(
            screenSize: screenSize,
            children: [
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.configureAlertsAndReminders,
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.notificationSettings),
                screenSize: screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              ThemeSettingsTile(
                onTap: () => _showThemeDialog(context),
                screenSize: screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              LanguageSettingsTile(
                onTap: () => _showLanguageDialog(context),
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Support Section
          SettingsSectionTitle(title: l10n.support, screenSize: screenSize),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SettingsCard(
            screenSize: screenSize,
            children: [
              SettingsTile(
                icon: Icons.help_outline,
                title: l10n.helpCenter,
                subtitle: l10n.faqAndGuides,
                onTap: () => HelpDialog.show(context),
                screenSize: screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              SettingsTile(
                icon: Icons.feedback_outlined,
                title: l10n.sendFeedback,
                subtitle: l10n.shareYourExperienceWithUs,
                onTap: () => FeedbackDialog.show(context),
                screenSize: screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.versionTermsAndPrivacy,
                onTap: () => AboutAppDialog.show(context),
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Logout Button
          LogoutButton(
            onTap: () => LogoutDialog.show(context),
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectionDialog(),
    );
  }
}
