import 'package:alertaescolar/providers/language_provider.dart';
import 'package:alertaescolar/views/profile/notification_settings_view_new.dart';
import 'package:alertaescolar/views/profile/password_security_view_new.dart';
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
              _buildModernHeader(context, l10n, screenSize),

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

  Widget _buildModernHeader(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppTheme.getMediumPadding(screenSize),
          AppTheme.getMediumPadding(screenSize),
          AppTheme.getMediumPadding(screenSize),
          AppTheme.getLargePadding(screenSize),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: AppTheme.accentPurple,
                    size: screenSize.width * 0.08,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.myProfile,
                          style: AppTheme.getH2(screenSize).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextPrimaryColor(context),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        Consumer<UserProvider>(
                          builder: (context, provider, child) {
                            final user = provider.currentUser;
                            return Text(
                              user?.email ?? l10n.manageYourAccount,
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.getTextSecondaryColor(context),
                                height: 1.4,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              // User Info Card
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.currentUser;
                  return Container(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(screenSize)),
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: screenSize.width * 0.15,
                          height: screenSize.width * 0.15,
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple,
                            borderRadius: BorderRadius.circular(
                                AppTheme.getMediumRadius(screenSize)),
                          ),
                          child: Center(
                            child: (user?.nombre != null &&
                                    user!.nombre.isNotEmpty)
                                ? Text(
                                    user.nombre[0].toUpperCase(),
                                    style: AppTheme.getH2(screenSize).copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    size: screenSize.width * 0.075,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.nombre ?? l10n.user,
                                style:
                                    AppTheme.getSubtitle1(screenSize).copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextPrimaryColor(context),
                                  height: 1.4,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppTheme.getSmallPadding(screenSize) *
                                          0.75,
                                  vertical:
                                      AppTheme.getSmallPadding(screenSize) *
                                          0.25,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentPurple
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getSmallRadius(screenSize) *
                                          0.5),
                                ),
                                child: Text(
                                  l10n.parentRole,
                                  style: AppTheme.getCaptionSmall(screenSize)
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentPurple,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
          _buildSectionTitle(l10n.account, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: l10n.personalData,
              subtitle: l10n.editProfileAndContactData,
              onTap: () => Navigator.pushNamed(
                  context, AppRoutes.personalDataNavigation),
              screenSize: screenSize,
              context: context,
            ),
            Divider(height: 1, color: AppTheme.getDividerColor(context)),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: l10n.security,
              subtitle: l10n.changePasswordAndAuthentication,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PasswordSecurityView(),
                ),
              ),
              screenSize: screenSize,
              context: context,
            ),
            Divider(height: 1, color: AppTheme.getDividerColor(context)),
            _buildSettingsTile(
              icon: Icons.family_restroom_outlined,
              title: l10n.familyInformation,
              subtitle: l10n.emergencyDataAndContacts,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.familyInformation),
              screenSize: screenSize,
              context: context,
            ),
          ], screenSize, context),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Preferences Section
          _buildSectionTitle(l10n.preferences, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildSettingsCard([
            _buildSettingsTile(
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
              context: context,
            ),
            Divider(height: 1, color: AppTheme.getDividerColor(context)),
            _buildThemeSettingsTile(context, l10n, screenSize),
            Divider(height: 1, color: AppTheme.getDividerColor(context)),
            _buildLanguageSettingsTile(context, l10n, screenSize),
          ], screenSize, context),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Support Section
          _buildSectionTitle(l10n.support, screenSize, context),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: l10n.helpCenter,
              subtitle: l10n.faqAndGuides,
              onTap: () => _showHelpDialog(context, l10n, screenSize),
              screenSize: screenSize,
              context: context,
            ),
            Divider(height: 1, color: AppTheme.getDividerColor(context)),
            _buildSettingsTile(
              icon: Icons.feedback_outlined,
              title: l10n.sendFeedback,
              subtitle: l10n.shareYourExperienceWithUs,
              onTap: () => _showFeedbackDialog(context, l10n, screenSize),
              screenSize: screenSize,
              context: context,
            ),
            Divider(height: 1, color: AppTheme.getDividerColor(context)),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: l10n.about,
              subtitle: l10n.versionTermsAndPrivacy,
              onTap: () => _showAboutDialog(context, l10n, screenSize),
              screenSize: screenSize,
              context: context,
            ),
          ], screenSize, context),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.errorColor.withOpacity(0.05),
                    AppTheme.errorColor.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showLogoutDialog(context, l10n, screenSize),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  splashColor: AppTheme.errorColor.withOpacity(0.1),
                  highlightColor: AppTheme.errorColor.withOpacity(0.05),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getMediumPadding(screenSize),
                      horizontal: AppTheme.getMediumPadding(screenSize),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              AppTheme.getSmallPadding(screenSize) * 0.5),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(screenSize)),
                          ),
                          child: Icon(
                            Icons.logout_outlined,
                            size: screenSize.width * 0.05,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Text(
                          l10n.signOut,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppTheme.errorColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, Size screenSize, BuildContext context) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildSettingsCard(
      List<Widget> children, Size screenSize, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Size screenSize,
    required BuildContext context,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Row(
            children: [
              Container(
                width: screenSize.width * 0.1,
                height: screenSize.width * 0.1,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentPurple,
                  size: screenSize.width * 0.05,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                        height: 1.4,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: screenSize.width * 0.04,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSettingsTile(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return _buildSettingsTile(
      icon: Icons.palette_outlined,
      title: l10n.theme,
      subtitle: Theme.of(context).brightness == Brightness.dark
          ? l10n.darkMode
          : l10n.lightMode,
      onTap: () => _showThemeDialog(context),
      screenSize: screenSize,
      context: context,
    );
  }

  Widget _buildLanguageSettingsTile(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        // Forzar la reconstrucción obteniendo las localizaciones actuales
        final currentL10n = AppLocalizations.of(context);

        String subtitle;
        if (localeProvider.locale.languageCode == 'es') {
          subtitle = currentL10n.spanish;
        } else {
          subtitle = currentL10n.english;
        }
        print("IDIOM ${localeProvider.locale.languageCode}");

        return _buildSettingsTile(
          icon: Icons.language_outlined,
          title: currentL10n.language,
          subtitle: subtitle,
          onTap: () => _showLanguageDialog(context),
          screenSize: screenSize,
          context: context,
        );
      },
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
