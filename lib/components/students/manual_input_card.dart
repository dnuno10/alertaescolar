import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../textfield/custom_input_field.dart';

class ManualInputCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController keyController;

  /// Habilita/deshabilita el input (útil mientras hay loading arriba)
  final bool enabled;

  /// Se dispara al enviar desde el teclado (Enter/Done)
  final VoidCallback? onSubmitted;

  const ManualInputCard({
    super.key,
    required this.formKey,
    required this.keyController,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.manualEntry,
              style: AppTheme.getSubtitle1(size).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              l10n.enterStudentKeyCode,
              style: AppTheme.getBodyMedium(size).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(size)),
            AbsorbPointer(
              absorbing:
                  !enabled, // bloquea interacciones si está deshabilitado
              child: Opacity(
                opacity: enabled ? 1.0 : 0.6,
                child: CustomInputField(
                  label: l10n.keyCode,
                  controller: keyController,
                  icon: Icons.key_rounded,
                  // Si tu CustomInputField soporta estos extras, los pasamos:
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSubmitted?.call(),
                  readOnly: !enabled,
                  // Útil si tus códigos son alfanuméricos sin espacios
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                    // Evita espacios accidentales
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  // capitalización por si hay letras
                  textCapitalization: TextCapitalization.characters,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return l10n.pleaseEnterKeyCode;
                    //if (v.length < 6) return l10n.keyCodeMinLength;
                    return null;
                  },
                  screenSize: size, // mantiene compatibilidad con tu widget
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
