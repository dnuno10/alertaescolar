import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'settings_tile.dart';

class ThemeSettingsTile extends StatelessWidget {
  final VoidCallback onTap;
  final Size screenSize;

  const ThemeSettingsTile({
    super.key,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsTile(
      icon: Icons.palette_outlined,
      title: l10n.theme,
      subtitle: Theme.of(context).brightness == Brightness.dark
          ? l10n.darkMode
          : l10n.lightMode,
      onTap: onTap,
      screenSize: screenSize,
    );
  }
}
