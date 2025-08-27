import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import 'settings_tile.dart';

class LanguageSettingsTile extends StatelessWidget {
  final VoidCallback onTap;
  final Size screenSize;

  const LanguageSettingsTile({
    super.key,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
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

        return SettingsTile(
          icon: Icons.language_outlined,
          title: currentL10n.language,
          subtitle: subtitle,
          onTap: onTap,
          screenSize: screenSize,
        );
      },
    );
  }
}
