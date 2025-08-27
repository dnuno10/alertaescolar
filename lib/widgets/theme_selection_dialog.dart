import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= screenSize.width * 0.75;
          final maxWidth = isWide ? screenSize.width * 0.9 : double.infinity;

          return Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: screenSize.height * 0.02,
                  offset: Offset(0, screenSize.height * 0.008),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          AppTheme.getSmallPadding(screenSize) * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize),
                          ),
                        ),
                        child: Icon(
                          Icons.palette_rounded,
                          color: AppTheme.accentPurple,
                          size: screenSize.height * 0.025,
                        ),
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        child: Text(
                          l10n.selectTheme,
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Theme Options
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Column(
                        children: [
                          _ThemeOption(
                            title: l10n.lightTheme,
                            subtitle: l10n.lightThemeDescription,
                            icon: Icons.light_mode_rounded,
                            isSelected:
                                themeProvider.themeMode == ThemeMode.light,
                            onTap: () {
                              themeProvider.setThemeMode(ThemeMode.light);
                              Navigator.of(context).pop();
                            },
                            screenSize: screenSize,
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          _ThemeOption(
                            title: l10n.darkTheme,
                            subtitle: l10n.darkThemeDescription,
                            icon: Icons.dark_mode_rounded,
                            isSelected:
                                themeProvider.themeMode == ThemeMode.dark,
                            onTap: () {
                              themeProvider.setThemeMode(ThemeMode.dark);
                              Navigator.of(context).pop();
                            },
                            screenSize: screenSize,
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          _ThemeOption(
                            title: l10n.systemTheme,
                            subtitle: l10n.systemThemeDescription,
                            icon: Icons.settings_rounded,
                            isSelected:
                                themeProvider.themeMode == ThemeMode.system,
                            onTap: () {
                              themeProvider.setThemeMode(ThemeMode.system);
                              Navigator.of(context).pop();
                            },
                            screenSize: screenSize,
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: SolidButton(
                        onPressed: () => Navigator.of(context).pop(),
                        label: l10n.cancel,
                        backgroundColor: AppTheme.accentPurple,
                        screenSize: screenSize),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppTheme.getMediumRadius(screenSize),
        ),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentPurple.withOpacity(0.1)
                : AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(screenSize),
            ),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentPurple
                  : AppTheme.getBorderColor(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  AppTheme.getSmallPadding(screenSize) * 0.7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentPurple.withOpacity(0.15)
                      : AppTheme.getTextSecondaryColor(context)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(screenSize),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.accentPurple
                      : AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
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
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.3),
                    Text(
                      subtitle,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.025,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
