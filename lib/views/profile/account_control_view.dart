import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class AccountControlView extends StatefulWidget {
  const AccountControlView({super.key});

  @override
  State<AccountControlView> createState() => _AccountControlViewState();
}

class _AccountControlViewState extends State<AccountControlView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              // Modern Sticky Header
              _buildStickyHeader(l10n, screenSize),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      _buildHeaderCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Account Management Section
                      _buildSectionTitle(l10n.settings, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildAccountManagementCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Data & Privacy Section
                      _buildSectionTitle(l10n.profile, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildDataPrivacyCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Security Actions Section
                      _buildSectionTitle(l10n.security, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildSecurityActionsCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Danger Zone Section
                      _buildSectionTitle(l10n.dangerZone, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildDangerZoneCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(AppLocalizations l10n, Size screenSize) {
    return SliverAppBar(
      expandedHeight: screenSize.height * 0.15,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentPurple,
              AppTheme.accentBlue,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            l10n.settings,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.onPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          titlePadding: EdgeInsets.only(
            left: screenSize.width * 0.18,
            bottom: AppTheme.getSmallPadding(screenSize),
          ),
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(screenSize.width * 0.02),
        decoration: BoxDecoration(
          color: AppTheme.onPrimaryColor.withOpacity(0.2),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.onPrimaryColor,
            size: screenSize.width * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.accentPurple,
                  AppTheme.accentBlue,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              size: screenSize.height * 0.04,
              color: AppTheme.onPrimaryColor,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.settings,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.about, // Use existing l10n or add proper description
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size screenSize) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
      ),
    );
  }

  Widget _buildAccountManagementCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            l10n.settings,
            l10n.about,
            Icons.pause_circle_outline,
            AppTheme.warningColor,
            () => _showDisableAccountDialog(l10n),
            screenSize,
          ),
          Divider(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
          _buildActionTile(
            l10n.changePassword,
            l10n.changePasswordDesc,
            Icons.lock_outline,
            AppTheme.accentBlue,
            () => _navigateToPasswordChange(),
            screenSize,
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacyCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            l10n.downloadData,
            l10n.downloadDataDesc,
            Icons.download,
            AppTheme.successColor,
            () => _downloadData(l10n),
            screenSize,
          ),
          Divider(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
          _buildActionTile(
            l10n.clearCache,
            l10n.clearCacheDesc,
            Icons.cleaning_services,
            AppTheme.accentPurple,
            () => _clearCache(l10n),
            screenSize,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityActionsCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            l10n.twoFactorAuth,
            l10n.twoFactorAuthDesc,
            Icons.security,
            AppTheme.successColor,
            () => _setupTwoFactor(l10n),
            screenSize,
          ),
          Divider(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
          _buildActionTile(
            l10n.activeSessions,
            l10n.activeSessionsDesc,
            Icons.devices,
            AppTheme.accentBlue,
            () => _viewActiveSessions(l10n),
            screenSize,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border:
            Border.all(color: AppTheme.errorColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenSize.width * 0.02),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(screenSize.width * 0.02),
                  ),
                  child: Icon(
                    Icons.warning,
                    color: AppTheme.errorColor,
                    size: screenSize.width * 0.06,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dangerZone,
                        style: AppTheme.getSubtitle2(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      Text(
                        l10n.dangerZoneDesc,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.getBorderColor(context),
          ),
          _buildActionTile(
            l10n.deleteAccount,
            l10n.deleteAccountDesc,
            Icons.delete_forever,
            AppTheme.errorColor,
            () => _showDeleteAccountDialog(l10n),
            screenSize,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    Size screenSize,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize),
        vertical: screenSize.height * 0.01,
      ),
      leading: Container(
        padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: screenSize.width * 0.06,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.getTextSecondaryColor(context),
        size: screenSize.width * 0.06,
      ),
    );
  }

  void _showDisableAccountDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          l10n.disableAccount,
          style: AppTheme.getSubtitle1(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          l10n.disableAccountWarning,
          style: AppTheme.getBodyMedium(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getTextSecondaryColor(context),
            ),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _disableAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.warningColor),
            child: Text(l10n.disable),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          l10n.deleteAccount,
          style: AppTheme.getSubtitle1(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          l10n.deleteAccountWarning,
          style: AppTheme.getBodyMedium(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getTextSecondaryColor(context),
            ),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(l10n);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _disableAccount() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.accountDisabled,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onErrorColor,
          ),
        ),
        backgroundColor: AppTheme.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  void _deleteAccount(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.accountDeletionStarted,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onErrorColor,
          ),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  void _navigateToPasswordChange() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.navigatingToPasswordChange,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onErrorColor,
          ),
        ),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  void _downloadData(AppLocalizations l10n) async {
    setState(() => _isLoading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.preparingDownload,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onErrorColor,
          ),
        ),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );

    // Simulate download preparation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.downloadReady,
            style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
              color: AppTheme.onErrorColor,
            ),
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
        ),
      );
    }
  }

  void _clearCache(AppLocalizations l10n) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.clearingCache,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onErrorColor,
          ),
        ),
        backgroundColor: AppTheme.accentPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );

    // Simulate cache clearing
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.cacheCleared,
            style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
              color: AppTheme.onErrorColor,
            ),
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
        ),
      );
    }
  }

  void _setupTwoFactor(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.twoFactorSetup,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onErrorColor,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  void _viewActiveSessions(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.viewingSessions,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onErrorColor,
          ),
        ),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }
}
