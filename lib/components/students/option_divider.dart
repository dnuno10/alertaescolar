import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

/// Separador con línea – texto – línea.
/// - Usa MediaQuery para tamaños (no requiere screenSize).
/// - Respeta DividerTheme y colores del tema.
/// - Expone `label` para personalizar el texto (por defecto l10n.or).
class OptionDivider extends StatelessWidget {
  final String? label;

  const OptionDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    final text = label ?? l10n.or;
    final dividerColor = AppTheme.getBorderColor(context);
    final verticalPadding = AppTheme.getSmallPadding(size);
    final horizontalGap = AppTheme.getSmallPadding(size);

    // Accesibilidad: anunciar como separador
    return Semantics(
      container: true,
      label: text,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: DividerTheme.of(context).thickness ?? 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: dividerColor),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalGap),
              child: Text(
                text,
                style: AppTheme.getBodyMedium(size).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: DividerTheme.of(context).thickness ?? 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: dividerColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
