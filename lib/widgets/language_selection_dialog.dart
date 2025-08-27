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
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getSmallRadius(screenSize)),
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
                                  l10n.selectLanguage,
                                  style: AppTheme.getH2(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextPrimaryColor(context),
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.005),
                                Text(
                                  l10n.choosePreferredLanguage,
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
                      // Spanish language option
                      _buildLanguageOption(
                        context: context,
                        l10n: l10n,
                        screenSize: screenSize,
                        locale: const Locale('es', 'ES'),
                        title: l10n.spanish,
                        subtitle: 'Español',
                        flagEmoji: '🇪🇸',
                        isSelected: _isSpanish(context),
                        accentColor: AppTheme.accentPurple,
                      ),

                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      // English language option
                      _buildLanguageOption(
                        context: context,
                        l10n: l10n,
                        screenSize: screenSize,
                        locale: const Locale('en', 'US'),
                        title: l10n.english,
                        subtitle: 'English',
                        flagEmoji: '🇺🇸',
                        isSelected: _isEnglish(context),
                        accentColor: AppTheme.accentBlue,
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required AppLocalizations l10n,
    required Size screenSize,
    required Locale locale,
    required String title,
    required String subtitle,
    required String flagEmoji,
    required bool isSelected,
    required Color accentColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _changeLanguage(context, locale);
          if (context.mounted) {
            final localeProvider =
                Provider.of<LocaleProvider>(context, listen: false);
            localeProvider.setLocale(Locale(locale.languageCode));
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
                ? accentColor.withOpacity(0.1)
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
              // Flag container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: screenSize.width * 0.12,
                height: screenSize.width * 0.12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Center(
                  child: Text(
                    flagEmoji,
                    style: TextStyle(
                      fontSize: screenSize.width * 0.06,
                    ),
                  ),
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
      ),
    );
  }

  bool _isSpanish(BuildContext context) {
    try {
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      return localeProvider.locale.languageCode == 'es';
    } catch (e) {
      // Fallback to system locale detection if provider is not available
      return Localizations.localeOf(context).languageCode == 'es';
    }
  }

  bool _isEnglish(BuildContext context) {
    try {
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      return localeProvider.locale.languageCode == 'en';
    } catch (e) {
      // Fallback to system locale detection if provider is not available
      return Localizations.localeOf(context).languageCode == 'en';
    }
  }

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    try {
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      await localeProvider.setLocale(locale);
    } catch (e) {
      // Handle case where provider is not available
      debugPrint('LocaleProvider not available: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language change not available: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}
