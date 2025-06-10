import 'package:alertaescolar/components/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= screenSize.width * 2.25;
          final maxWidth = isWide ? screenSize.width : double.infinity;

          return Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: screenSize.width * 0.06,
                  offset: Offset(0, screenSize.height * 0.01),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with background contrast
                Container(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: screenSize.width * 0.12,
                            height: screenSize.width * 0.12,
                            decoration: BoxDecoration(
                              color: AppTheme.getTextPrimaryColor(context)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getSmallRadius(screenSize)),
                            ),
                            child: Icon(
                              Icons.palette_outlined,
                              color: AppTheme.getTextPrimaryColor(context),
                              size: screenSize.width * 0.06,
                            ),
                          ),
                          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.themeSelection,
                                  style: AppTheme.getH2(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextPrimaryColor(context),
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.005),
                                Text(
                                  l10n.chooseYourPreferredTheme,
                                  style:
                                      AppTheme.getCaption(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      // Light theme option
                      _buildThemeOption(
                        context: context,
                        l10n: l10n,
                        screenSize: screenSize,
                        themeMode: 'light',
                        title: l10n.lightMode,
                        subtitle: l10n.lightModeDescription,
                        icon: Icons.light_mode_outlined,
                        isSelected: _isLightTheme(context),
                        accentColor: AppTheme.accentBlue,
                      ),

                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      // Dark theme option
                      _buildThemeOption(
                        context: context,
                        l10n: l10n,
                        screenSize: screenSize,
                        themeMode: 'dark',
                        title: l10n.darkMode,
                        subtitle: l10n.darkModeDescription,
                        icon: Icons.dark_mode_outlined,
                        isSelected: _isDarkTheme(context),
                        accentColor: AppTheme.accentPurple,
                      ),

                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      // System theme option
                      _buildThemeOption(
                        context: context,
                        l10n: l10n,
                        screenSize: screenSize,
                        themeMode: 'system',
                        title: l10n.systemTheme,
                        subtitle: l10n.systemThemeDescription,
                        icon: Icons.settings_system_daydream_outlined,
                        isSelected: _isSystemTheme(context),
                        accentColor: AppTheme.accentYellow,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      SizedBox(
                        width: double.infinity,
                        child: CustomOutlineButton(
                            onPressed: () => Navigator.of(context).pop(),
                            label: l10n.close,
                            color: AppTheme.getTextPrimaryColor(context),
                            screenSize: screenSize),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required AppLocalizations l10n,
    required Size screenSize,
    required String themeMode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
  }) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // TODO: Implement theme change logic
            await _changeTheme(context, themeMode);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.1)
                  : AppTheme.getContainerBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color:
                    isSelected ? accentColor : AppTheme.getBorderColor(context),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: screenSize.width * 0.12,
                  height: screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.getOnPrimaryColor(context)
                        : accentColor,
                    size: screenSize.width * 0.06,
                  ),
                ),

                SizedBox(width: AppTheme.getSmallPadding(screenSize)),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        subtitle,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: screenSize.width * 0.06,
                  height: screenSize.width * 0.06,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : AppTheme.getTextSecondaryColor(context),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: AppTheme.getOnPrimaryColor(context),
                          size: screenSize.width * 0.04,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ));
  }
}

bool _isLightTheme(BuildContext context) {
  try {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.themeMode == ThemeMode.light;
  } catch (e) {
    // Fallback to system theme detection if provider is not available
    return Theme.of(context).brightness == Brightness.light;
  }
}

bool _isDarkTheme(BuildContext context) {
  try {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.themeMode == ThemeMode.dark;
  } catch (e) {
    // Fallback to system theme detection if provider is not available
    return Theme.of(context).brightness == Brightness.dark;
  }
}

bool _isSystemTheme(BuildContext context) {
  try {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.themeMode == ThemeMode.system;
  } catch (e) {
    // If provider is not available, assume system theme
    return true;
  }
}

Future<void> _changeTheme(BuildContext context, String themeMode) async {
  try {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    switch (themeMode) {
      case 'light':
        await themeProvider.setThemeMode(ThemeMode.light);
        break;
      case 'dark':
        await themeProvider.setThemeMode(ThemeMode.dark);
        break;
      case 'system':
        await themeProvider.setThemeMode(ThemeMode.system);
        break;
    }
  } catch (e) {
    // Handle case where provider is not available
    debugPrint('ThemeProvider not available: $e');
    // You could show a snackbar or handle this gracefully
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme change not available'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
