import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../components/textfield/custom_input_field.dart';
import '../../../components/textfield/custom_text_area_field.dart';
import '../../../components/admin/school/section_card.dart';
import '../../../utils/modern_dropdown.dart';

class InformationTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController codigoController; // opcional en DB
  final TextEditingController descripcionController; // opcional en DB
  final TipoEscuela selectedTipo; // mapea a `tipo` (text)
  final ValueChanged<TipoEscuela> onTipoChanged;

  // Focus
  final FocusNode? nombreFocusNode;
  final FocusNode? codigoFocusNode;
  final FocusNode? descripcionFocusNode;

  final bool isLoading;
  final VoidCallback onSave;
  final String Function(TipoEscuela) getTipoLabel;

  const InformationTab({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.codigoController,
    required this.descripcionController,
    required this.selectedTipo,
    required this.onTipoChanged,
    required this.isLoading,
    required this.onSave,
    required this.getTipoLabel,
    this.nombreFocusNode,
    this.codigoFocusNode,
    this.descripcionFocusNode,
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
                // NOMBRE (requerido)
                CustomInputField(
                  controller: nombreController,
                  label: l10n.schoolName,
                  screenSize: screenSize,
                  icon: Icons.business_rounded,
                  focusNode: nombreFocusNode,
                  validator: (v) =>
                      v?.isEmpty == true ? l10n.fieldRequired : null,
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // CÓDIGO (opcional según schema)
                CustomInputField(
                  controller: codigoController,
                  label: l10n.schoolCode,
                  screenSize: screenSize,
                  icon: Icons.tag_rounded,
                  focusNode: codigoFocusNode,
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // TIPO (enum local -> text en DB)
                ModernDropdown<TipoEscuela>(
                  label: l10n.schoolType,
                  value: selectedTipo,
                  items: TipoEscuela.values,
                  onChanged: (value) =>
                      value != null ? onTipoChanged(value) : null,
                  getLabel: getTipoLabel,
                  screenSize: screenSize,
                  backgroundColor: AppTheme.getInputFillColor(context),
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // DESCRIPCIÓN (opcional)
                CustomTextAreaField(
                  textInputAction: TextInputAction.done,
                  label: l10n.description,
                  controller: descripcionController,
                  icon: Icons.description_rounded,
                  maxLines: 3,
                  focusNode: descripcionFocusNode,
                ),
              ],
            ),

            SizedBox(height: AppTheme.getLargePadding(screenSize)),
            // El botón de guardar está flotante en la vista principal
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
          ],
        ),
      ),
    );
  }
}
