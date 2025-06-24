import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../components/textfield/custom_input_field.dart';
import '../../../components/textfield/custom_text_area_field.dart';
import '../../../components/admin/school/section_card.dart';
import '../../../components/dropdown/custom_dropdown_field.dart';
import '../../../components/admin/school/education_level_checkboxes.dart';

class InformationTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController codigoController;
  final TextEditingController descripcionController;
  final TextEditingController yearFoundedController;
  final TipoEscuela selectedTipo;
  final ValueChanged<TipoEscuela> onTipoChanged;

  // Education level booleans
  final bool hasPreescolar;
  final bool hasPrimaria;
  final bool hasSecundaria;
  final bool hasBachillerato;
  final ValueChanged<bool> onPreescolarChanged;
  final ValueChanged<bool> onPrimariaChanged;
  final ValueChanged<bool> onSecundariaChanged;
  final ValueChanged<bool> onBachilleratoChanged;

  // Keep original fields for backwards compatibility
  final List<NivelEducativo> selectedNiveles;
  final ValueChanged<List<NivelEducativo>> onNivelesChanged;

  final bool isLoading;
  final VoidCallback onSave;
  final String Function(TipoEscuela) getTipoLabel;
  final String Function(NivelEducativo) getNivelLabel;

  const InformationTab({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.codigoController,
    required this.descripcionController,
    required this.yearFoundedController,
    required this.selectedTipo,
    required this.selectedNiveles,
    required this.onTipoChanged,
    required this.onNivelesChanged,
    required this.isLoading,
    required this.onSave,
    required this.getTipoLabel,
    required this.getNivelLabel,
    this.hasPreescolar = false,
    this.hasPrimaria = true,
    this.hasSecundaria = false,
    this.hasBachillerato = false,
    required this.onPreescolarChanged,
    required this.onPrimariaChanged,
    required this.onSecundariaChanged,
    required this.onBachilleratoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              title: l10n.basicInformation,
              icon: Icons.school_rounded,
              color: AppTheme.accentBlue,
              children: [
                CustomInputField(
                  controller: nombreController,
                  label: l10n.schoolName,
                  screenSize: screenSize,
                  icon: Icons.business_rounded,
                  validator: (value) =>
                      value?.isEmpty == true ? l10n.fieldRequired : null,
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        controller: codigoController,
                        label: l10n.schoolCode,
                        screenSize: screenSize,
                        icon: Icons.tag_rounded,
                        validator: (value) =>
                            value?.isEmpty == true ? l10n.fieldRequired : null,
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      child: CustomInputField(
                        controller: yearFoundedController,
                        label: l10n.foundedYear,
                        screenSize: screenSize,
                        icon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? l10n.fieldRequired : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                CustomTextAreaField(
                  label: l10n.description,
                  controller: descripcionController,
                  icon: Icons.description_rounded,
                  maxLines: 3,
                ),
              ],
            ),
            SizedBox(height: AppTheme.getLargePadding(screenSize)),
            SectionCard(
              title: l10n.institutionalConfiguration,
              icon: Icons.settings_rounded,
              color: AppTheme.successColor,
              children: [
                CustomDropdownField(
                  label: l10n.schoolType,
                  value: selectedTipo,
                  items: TipoEscuela.values,
                  onChanged: (value) =>
                      value != null ? onTipoChanged(value) : null,
                  getLabel: getTipoLabel,
                ),
                SizedBox(height: AppTheme.getLargePadding(screenSize)),
                EducationLevelCheckboxes(
                  label: l10n.educationLevels,
                  hasPreescolar: hasPreescolar,
                  hasPrimaria: hasPrimaria,
                  hasSecundaria: hasSecundaria,
                  hasBachillerato: hasBachillerato,
                  onPreescolarChanged: onPreescolarChanged,
                  onPrimariaChanged: onPrimariaChanged,
                  onSecundariaChanged: onSecundariaChanged,
                  onBachilleratoChanged: onBachilleratoChanged,
                ),
              ],
            ),
            SizedBox(height: AppTheme.getLargePadding(screenSize)),
            // El botón de guardar/actualizar ha sido removido para ser flotante en el view principal
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 6),
          ],
        ),
      ),
    );
  }
}
