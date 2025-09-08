import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import 'settings_tile.dart';

class LanguageSettingsTile extends StatelessWidget {
  final VoidCallback onTap;
  final Size screenSize;

  /// Opcionales para radio del primer/último tile y estado
  final bool isFirst;
  final bool isLast;
  final bool enabled;

  const LanguageSettingsTile({
    super.key,
    required this.onTap,
    required this.screenSize,
    this.isFirst = false,
    this.isLast = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final l10n = AppLocalizations.of(context);
        final code = localeProvider.locale.languageCode.toLowerCase();

        final subtitle = (code == 'es') ? l10n.spanish : l10n.english;

        return SettingsTile(
          icon: Icons.language_outlined,
          title: l10n.language,
          subtitle: subtitle,
          onTap: onTap,
          screenSize: screenSize,
          isFirst: isFirst,
          isLast: isLast,
          enabled: enabled,
        );
      },
    );
  }
}
