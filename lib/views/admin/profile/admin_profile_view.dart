import 'package:alertaescolar/views/profile/password_security_view_new.dart';
import 'package:alertaescolar/components/profile/profile_header.dart';
import 'package:alertaescolar/components/profile/settings_section_title.dart';
import 'package:alertaescolar/components/profile/settings_card.dart';
import 'package:alertaescolar/components/profile/settings_tile.dart';
import 'package:alertaescolar/components/profile/theme_settings_tile.dart';
import 'package:alertaescolar/components/profile/language_settings_tile.dart';
import 'package:alertaescolar/components/profile/logout_button.dart';
import 'package:alertaescolar/components/dialogs/theme_dialog_handler.dart';
import 'package:alertaescolar/components/dialogs/language_dialog_handler.dart';
import 'package:alertaescolar/components/dialogs/coming_soon_dialog.dart';
import 'package:alertaescolar/components/dialogs/about_app_dialog.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../app/app_routes.dart';

class AdminProfileView extends StatefulWidget {
  const AdminProfileView({super.key});

  @override
  State<AdminProfileView> createState() => _AdminProfileViewState();
}

class _AdminProfileViewState extends State<AdminProfileView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          ProfileHeader(screenSize: screenSize),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  SettingsSectionTitle(
                    title: l10n.account,
                    screenSize: screenSize,
                  ),
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
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.lock_outline,
                        title: l10n.security,
                        subtitle: l10n.changePasswordAndAuthentication,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordSecurityView(),
                          ),
                        ),
                        screenSize: screenSize,
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Preferences Section
                  SettingsSectionTitle(
                    title: l10n.preferences,
                    screenSize: screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  SettingsCard(
                    screenSize: screenSize,
                    children: [
                      ThemeSettingsTile(
                        screenSize: screenSize,
                        onTap: () =>
                            ThemeDialogHandler.showThemeDialog(context),
                      ),
                      const Divider(height: 1),
                      LanguageSettingsTile(
                        screenSize: screenSize,
                        onTap: () =>
                            LanguageDialogHandler.showLanguageDialog(context),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Help Section
                  SettingsSectionTitle(
                    title: l10n.helpCenter,
                    screenSize: screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  SettingsCard(
                    screenSize: screenSize,
                    children: [
                      SettingsTile(
                        icon: Icons.help_outline,
                        title: l10n.helpCenter,
                        subtitle: l10n.faqAndGuides,
                        onTap: () => ComingSoonDialog.show(
                            context, l10n.helpCenterAndDocumentationComingSoon),
                        screenSize: screenSize,
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.feedback_outlined,
                        title: l10n.sendFeedback,
                        subtitle: l10n.shareYourExperienceWithUs,
                        onTap: () => ComingSoonDialog.show(
                            context, l10n.feedbackSystemComingSoon),
                        screenSize: screenSize,
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.info_outline,
                        title: l10n.aboutAlertaEscolar,
                        subtitle: l10n.versionTermsAndPrivacy,
                        onTap: () => AboutAppDialog.show(context),
                        screenSize: screenSize,
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Logout Button
                  LogoutButton(
                    screenSize: screenSize,
                    onTap: () {},
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
