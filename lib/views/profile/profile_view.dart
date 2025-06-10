import 'package:alertaescolar/providers/language_provider.dart';
import 'package:alertaescolar/views/profile/notification_settings_view_new.dart';
import 'package:alertaescolar/views/profile/password_security_view_new.dart';
import 'package:alertaescolar/components/profile/profile_header.dart';
import 'package:alertaescolar/components/profile/settings_section_title.dart';
import 'package:alertaescolar/components/profile/settings_card.dart';
import 'package:alertaescolar/components/profile/settings_tile.dart';
import 'package:alertaescolar/components/profile/theme_settings_tile.dart';
import 'package:alertaescolar/components/profile/language_settings_tile.dart';
import 'package:alertaescolar/components/profile/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/user_provider.dart';
import '../../app/app_theme.dart';
import '../../app/app_routes.dart';
import '../../widgets/language_selection_dialog.dart';
import '../../widgets/theme_selection_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final l10n = AppLocalizations.of(context);
        final screenSize = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              ProfileHeader(screenSize: screenSize),

              // Settings Sections
              SliverToBoxAdapter(
                child: _buildSettingsSections(context, l10n, screenSize),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSections(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
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
                icon: Icons.security_outlined,
                title: l10n.security,
                subtitle: l10n.changePasswordAndAuthentication,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PasswordSecurityView(),
                  ),
                ),
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsView(),
                    ),
                  );
                },
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
                onTap: () => _showHelpDialog(context, l10n, screenSize),
                screenSize: screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              SettingsTile(
                icon: Icons.feedback_outlined,
                title: l10n.sendFeedback,
                subtitle: l10n.shareYourExperienceWithUs,
                onTap: () => _showFeedbackDialog(context, l10n, screenSize),
                screenSize: screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.versionTermsAndPrivacy,
                onTap: () => _showAboutDialog(context, l10n, screenSize),
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Logout Button
          LogoutButton(
            onTap: () => _showLogoutDialog(context, l10n, screenSize),
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
        ],
      ),
    );
  }

  // Dialog Methods with modern styling
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

  void _showHelpDialog(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          l10n.helpCenter,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          l10n.helpCenterAndDocumentationComingSoon,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.understood,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          l10n.sendFeedback,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          l10n.feedbackSystemComingSoon,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.understood,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          l10n.aboutAlertaEscolar,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.version,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              l10n.aboutDescription,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.understood,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          l10n.signOut,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          l10n.confirmSignOut,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement logout logic
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
            ),
            child: Text(
              l10n.signOut,
              style: AppTheme.getCaption(screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
