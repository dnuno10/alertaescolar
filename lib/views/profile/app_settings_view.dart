import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});

  @override
  State<AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  bool _autoSync = true;
  bool _offlineMode = false;
  bool _analyticsEnabled = true;
  bool _crashReporting = true;
  String _cacheSize = 'Medium';
  String _downloadQuality = 'High';
  bool _autoUpdate = true;
  bool _betaFeatures = false;

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

                      // Sync & Data Section
                      _buildSectionTitle(l10n.syncData, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          l10n.autoSync,
                          l10n.autoSyncDescription,
                          _autoSync,
                          (value) => setState(() => _autoSync = value),
                          Icons.sync,
                          screenSize,
                        ),
                        _buildDivider(screenSize),
                        _buildSwitchTile(
                          l10n.offlineMode,
                          l10n.offlineModeDescription,
                          _offlineMode,
                          (value) => setState(() => _offlineMode = value),
                          Icons.cloud_off,
                          screenSize,
                        ),
                      ], screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Privacy & Analytics Section
                      _buildSectionTitle(l10n.privacyAnalytics, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          l10n.analyticsEnabled,
                          l10n.analyticsDescription,
                          _analyticsEnabled,
                          (value) => setState(() => _analyticsEnabled = value),
                          Icons.analytics,
                          screenSize,
                        ),
                        _buildDivider(screenSize),
                        _buildSwitchTile(
                          l10n.crashReporting,
                          l10n.crashReportingDescription,
                          _crashReporting,
                          (value) => setState(() => _crashReporting = value),
                          Icons.bug_report,
                          screenSize,
                        ),
                      ], screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Storage & Cache Section
                      _buildSectionTitle(l10n.storageCache, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildSettingsCard([
                        _buildSelectTile(
                          l10n.cacheSize,
                          _cacheSize,
                          ['Low', 'Medium', 'High'],
                          (value) => setState(() => _cacheSize = value!),
                          Icons.storage,
                          l10n,
                          screenSize,
                        ),
                        _buildDivider(screenSize),
                        _buildActionTile(
                          l10n.clearCache,
                          l10n.clearCacheDescription,
                          Icons.delete_sweep,
                          () => _clearCache(l10n),
                          screenSize,
                        ),
                        _buildDivider(screenSize),
                        _buildSelectTile(
                          l10n.downloadQuality,
                          _downloadQuality,
                          ['Low', 'Medium', 'High'],
                          (value) => setState(() => _downloadQuality = value!),
                          Icons.download,
                          l10n,
                          screenSize,
                        ),
                      ], screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // App Updates Section
                      _buildSectionTitle(l10n.appUpdates, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          l10n.autoUpdate,
                          l10n.autoUpdateDescription,
                          _autoUpdate,
                          (value) => setState(() => _autoUpdate = value),
                          Icons.system_update,
                          screenSize,
                        ),
                        _buildDivider(screenSize),
                        _buildSwitchTile(
                          l10n.betaFeatures,
                          l10n.betaFeaturesDescription,
                          _betaFeatures,
                          (value) => setState(() => _betaFeatures = value),
                          Icons.science,
                          screenSize,
                        ),
                      ], screenSize),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
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
              AppTheme.iconContainerPurple,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            l10n.appSettings,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.onPrimaryColor,
            ),
          ),
          centerTitle: true,
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
            Icons.arrow_back_ios,
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
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.settings,
              size: screenSize.height * 0.06,
              color: AppTheme.accentPurple,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.appSettings,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            l10n.appConfiguration,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.5,
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
        fontWeight: FontWeight.w700,
        color: AppTheme.getTextPrimaryColor(context),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
    Size screenSize,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(screenSize),
        vertical: screenSize.height * 0.01,
      ),
      leading: Container(
        padding: EdgeInsets.all(screenSize.width * 0.02),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        ),
        child: Icon(
          icon,
          color: AppTheme.accentPurple,
          size: screenSize.width * 0.05,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accentPurple,
        inactiveThumbColor: AppTheme.getTextSecondaryColor(context),
        inactiveTrackColor: AppTheme.getBorderColor(context),
      ),
    );
  }

  Widget _buildSelectTile(
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String?> onChanged,
    IconData icon,
    AppLocalizations l10n,
    Size screenSize,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(screenSize),
        vertical: screenSize.height * 0.01,
      ),
      leading: Container(
        padding: EdgeInsets.all(screenSize.width * 0.02),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        ),
        child: Icon(
          icon,
          color: AppTheme.accentPurple,
          size: screenSize.width * 0.05,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize),
          vertical: screenSize.height * 0.008,
        ),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.02),
          border: Border.all(
            color: AppTheme.accentPurple.withOpacity(0.3),
          ),
        ),
        child: DropdownButton<String>(
          value: currentValue,
          underline: const SizedBox(),
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.accentPurple,
          ),
          dropdownColor: AppTheme.getSurfaceColor(context),
          items: options.map((option) {
            String translatedOption = option;
            if (option == 'Low') translatedOption = l10n.low;
            if (option == 'Medium') translatedOption = l10n.medium;
            if (option == 'High') translatedOption = l10n.high;

            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                translatedOption,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Size screenSize,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(screenSize),
        vertical: screenSize.height * 0.01,
      ),
      leading: Container(
        padding: EdgeInsets.all(screenSize.width * 0.02),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        ),
        child: Icon(
          icon,
          color: AppTheme.accentPurple,
          size: screenSize.width * 0.05,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          fontWeight: FontWeight.w600,
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
      onTap: onTap,
    );
  }

  Widget _buildDivider(Size screenSize) {
    return Divider(
      height: 1,
      color: AppTheme.getBorderColor(context),
      indent: AppTheme.getMediumPadding(screenSize),
      endIndent: AppTheme.getMediumPadding(screenSize),
    );
  }

  Future<void> _clearCache(AppLocalizations l10n) async {
    try {
      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showMessage(l10n.cacheCleared);
      }
    } catch (e) {
      if (mounted) {
        _showMessage(l10n.cacheClearError);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.getTextPrimaryColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
        margin: EdgeInsets.all(
            AppTheme.getSmallPadding(MediaQuery.of(context).size)),
      ),
    );
  }
}
