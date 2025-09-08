import 'package:alertaescolar/components/dialogs/language_dialog_handler.dart';
import 'package:alertaescolar/components/dialogs/theme_dialog_handler.dart';
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
import '../dialogs/logout_dialog.dart';

class SettingsSectionsContent extends StatefulWidget {
  final Size screenSize;

  const SettingsSectionsContent({
    super.key,
    required this.screenSize,
  });

  @override
  State<SettingsSectionsContent> createState() =>
      _SettingsSectionsContentState();
}

class _SettingsSectionsContentState extends State<SettingsSectionsContent> {
  bool _isLogoutDialogOpen = false;

  Future<void> _handleLogoutTap() async {
    if (_isLogoutDialogOpen) return;
    setState(() => _isLogoutDialogOpen = true);
    try {
      // Aguardar a que cierre para evitar diálogos múltiples por taps rápidos
      LogoutDialog.show(context);
    } finally {
      if (mounted) {
        setState(() => _isLogoutDialogOpen = false);
      } else {
        _isLogoutDialogOpen = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(widget.screenSize),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Section
          SettingsSectionTitle(
            title: l10n.account,
            screenSize: widget.screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          SettingsCard(
            screenSize: widget.screenSize,
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: l10n.personalData,
                subtitle: l10n.editProfileAndContactData,
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.personalDataNavigation),
                screenSize: widget.screenSize,
                isFirst: true,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              SettingsTile(
                icon: Icons.family_restroom_outlined,
                title: l10n.familyInformation,
                subtitle: l10n.emergencyDataAndContacts,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.familyInformation),
                screenSize: widget.screenSize,
                isLast: true,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Preferences Section
          SettingsSectionTitle(
            title: l10n.preferences,
            screenSize: widget.screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          SettingsCard(
            screenSize: widget.screenSize,
            children: [
              ThemeSettingsTile(
                screenSize: widget.screenSize,
                onTap: () => ThemeDialogHandler.showThemeDialog(context),
                isFirst: true,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),
              LanguageSettingsTile(
                screenSize: widget.screenSize,
                onTap: () => LanguageDialogHandler.showLanguageDialog(context),
                isLast: true,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Support Section
          SettingsSectionTitle(
            title: l10n.support,
            screenSize: widget.screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          SettingsCard(
            screenSize: widget.screenSize,
            children: [
              SettingsTile(
                icon: Icons.help_outline,
                title: l10n.helpCenter,
                subtitle: l10n.faqAndGuides,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.helpCenterNavigation,
                ),
                screenSize: widget.screenSize,
                isFirst: true,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),

              // Contacto y Soporte (si ya tienes l10n, cámbialo por claves)
              SettingsTile(
                icon: Icons.support_agent_outlined,
                title: 'Contacto y soporte',
                subtitle: 'Instagram, WhatsApp, correo',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.contactSupport,
                ),
                screenSize: widget.screenSize,
              ),
              Divider(height: 1, color: AppTheme.getDividerColor(context)),

              // About / Legal
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.aboutAlertaEscolar,
                subtitle: l10n.versionTermsAndPrivacy,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.legalCenter,
                ),
                screenSize: widget.screenSize,
                isLast: true,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),

          // Logout Button (con guard de doble tap)
          LogoutButton(
            screenSize: widget.screenSize,
            onTap: _handleLogoutTap,
          ),
          SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),
        ],
      ),
    );
  }
}
