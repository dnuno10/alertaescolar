import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_theme.dart';
import '../l10n/app_localizations.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.maybeOf(context);
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
                // Header
                Container(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Row(
                    children: [
                      Container(
                        width: screenSize.width * 0.12,
                        height: screenSize.width * 0.12,
                        decoration: BoxDecoration(
                          color: AppTheme.getTextPrimaryColor(context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize),
                          ),
                        ),
                        child: Icon(
                          Icons.language,
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
                              (l10n?.selectLanguage) ?? 'Select language',
                              style: AppTheme.getH2(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.005),
                            Text(
                              (l10n?.choosePreferredLanguage) ??
                                  'Choose your preferred language.',
                              style: AppTheme.getCaption(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Consumer<LocaleProvider>(
                    builder: (context, localeProvider, _) {
                      final isEs = localeProvider.locale.languageCode == 'es';
                      final isEn = localeProvider.locale.languageCode == 'en';

                      return Column(
                        children: [
                          _LanguageOption(
                            screenSize: screenSize,
                            title: (l10n?.spanish) ?? 'Spanish',
                            subtitle: 'Español',
                            flagEmoji: '🇪🇸',
                            isSelected: isEs,
                            accentColor: AppTheme.accentPurple,
                            onTap: () async {
                              await localeProvider
                                  .setLocale(const Locale('es', 'ES'));
                              if (context.mounted) Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          _LanguageOption(
                            screenSize: screenSize,
                            title: (l10n?.english) ?? 'English',
                            subtitle: 'English',
                            flagEmoji: '🇺🇸',
                            isSelected: isEn,
                            accentColor: AppTheme.accentBlue,
                            onTap: () async {
                              await localeProvider
                                  .setLocale(const Locale('en', 'US'));
                              if (context.mounted) Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),
                          SizedBox(
                            width: double.infinity,
                            child: SolidButton(
                              onPressed: () => Navigator.of(context).pop(),
                              label: (l10n?.cancel) ?? 'Cancel',
                              backgroundColor: AppTheme.accentPurple,
                              screenSize: screenSize,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final Size screenSize;
  final String title;
  final String subtitle;
  final String flagEmoji;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.screenSize,
    required this.title,
    required this.subtitle,
    required this.flagEmoji,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withOpacity(0.1)
                : AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(screenSize),
            ),
            border: Border.all(
              color:
                  isSelected ? accentColor : AppTheme.getBorderColor(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Flag
              SizedBox(
                width: screenSize.width * 0.12,
                height: screenSize.width * 0.12,
                child: Center(
                  child: Text(
                    flagEmoji,
                    style: TextStyle(fontSize: screenSize.width * 0.06),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              // Texts
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
              // Check
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
      ),
    );
  }
}
