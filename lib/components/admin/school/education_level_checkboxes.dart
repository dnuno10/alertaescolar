import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class EducationLevelCheckboxes extends StatelessWidget {
  final String label;
  final bool hasPreescolar;
  final bool hasPrimaria;
  final bool hasSecundaria;
  final bool hasBachillerato;
  final ValueChanged<bool> onPreescolarChanged;
  final ValueChanged<bool> onPrimariaChanged;
  final ValueChanged<bool> onSecundariaChanged;
  final ValueChanged<bool> onBachilleratoChanged;

  const EducationLevelCheckboxes({
    super.key,
    required this.label,
    required this.hasPreescolar,
    required this.hasPrimaria,
    required this.hasSecundaria,
    required this.hasBachillerato,
    required this.onPreescolarChanged,
    required this.onPrimariaChanged,
    required this.onSecundariaChanged,
    required this.onBachilleratoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.getBorderColor(context)),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Column(
            children: [
              _buildCheckboxTile(
                context,
                l10n.preschool,
                hasPreescolar,
                onPreescolarChanged,
                screenSize,
              ),
              Divider(color: AppTheme.getBorderColor(context)),
              _buildCheckboxTile(
                context,
                l10n.primary,
                hasPrimaria,
                onPrimariaChanged,
                screenSize,
              ),
              Divider(color: AppTheme.getBorderColor(context)),
              _buildCheckboxTile(
                context,
                l10n.secondary,
                hasSecundaria,
                onSecundariaChanged,
                screenSize,
              ),
              Divider(color: AppTheme.getBorderColor(context)),
              _buildCheckboxTile(
                context,
                l10n.highSchool,
                hasBachillerato,
                onBachilleratoChanged,
                screenSize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    Size screenSize,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
        ),
        Checkbox(
          value: value,
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          activeColor: AppTheme.accentPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
