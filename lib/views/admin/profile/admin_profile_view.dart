import 'package:alertaescolar/components/dialogs/logout_dialog.dart';
import 'package:alertaescolar/components/profile/profile_header.dart';
import 'package:alertaescolar/components/profile/settings_section_title.dart';
import 'package:alertaescolar/components/profile/settings_card.dart';
import 'package:alertaescolar/components/profile/settings_tile.dart';
import 'package:alertaescolar/components/profile/theme_settings_tile.dart';
import 'package:alertaescolar/components/profile/language_settings_tile.dart';
import 'package:alertaescolar/components/profile/logout_button.dart';
import 'package:alertaescolar/components/dialogs/theme_dialog_handler.dart';
import 'package:alertaescolar/components/dialogs/language_dialog_handler.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../app/app_routes.dart';

class AdminProfileView extends StatefulWidget {
  const AdminProfileView({super.key});

  @override
  State<AdminProfileView> createState() => _AdminProfileViewState();
}

class _AdminProfileViewState extends State<AdminProfileView> {
  bool _isLogoutDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final up = context.read<UserProvider>();
      if (!up.isLoadingUser && up.currentUser == null) {
        up.loadCurrentUser(context, showDialog: false);
      }
    });
  }

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
              padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          context,
                          AppRoutes.personalDataNavigation,
                        ),
                        screenSize: screenSize,
                        isFirst: true,
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),
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
                        isFirst: true,
                      ),
                      const Divider(height: 1),
                      LanguageSettingsTile(
                        screenSize: screenSize,
                        onTap: () =>
                            LanguageDialogHandler.showLanguageDialog(context),
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),
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
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.helpCenterNavigation,
                        ),
                        screenSize: screenSize,
                        isFirst: true,
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.support_agent_outlined,
                        title: 'Contacto y soporte',
                        subtitle: 'Instagram, WhatsApp, correo',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.contactSupport,
                        ),
                        screenSize: screenSize,
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.info_outline,
                        title: l10n.aboutAlertaEscolar,
                        subtitle: l10n.versionTermsAndPrivacy,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.legalCenter,
                        ),
                        screenSize: screenSize,
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.getLargePadding(screenSize)),
                  LogoutButton(
                    screenSize: screenSize,
                    onTap: () async {
                      if (_isLogoutDialogOpen) return;
                      _isLogoutDialogOpen = true;
                      try {
                        LogoutDialog.show(context);
                      } finally {
                        _isLogoutDialogOpen = false;
                      }
                    },
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
