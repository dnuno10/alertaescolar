import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart'; // ← lee el ThemeMode actual
import 'settings_tile.dart';

class ThemeSettingsTile extends StatelessWidget {
  final VoidCallback onTap;
  final Size screenSize;

  /// Opcionales para redondeo de esquinas y estado
  final bool isFirst;
  final bool isLast;
  final bool enabled;

  const ThemeSettingsTile({
    super.key,
    required this.onTap,
    required this.screenSize,
    this.isFirst = false,
    this.isLast = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mode = context.watch<ThemeProvider>().themeMode;

    String subtitleByMode() {
      switch (mode) {
        case ThemeMode.light:
          return l10n.lightMode;
        case ThemeMode.dark:
          return l10n.darkMode;
        case ThemeMode.system:
          return l10n.systemTheme;
      }
    }

    return SettingsTile(
      icon: Icons.palette_outlined,
      title: l10n.theme,
      subtitle: subtitleByMode(),
      onTap: onTap,
      screenSize: screenSize,
      isFirst: isFirst,
      isLast: isLast,
      enabled: enabled,
    );
  }
}
