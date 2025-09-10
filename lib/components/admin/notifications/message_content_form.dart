import 'dart:ui' show ImageFilter; // <- para el blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class MessageContentForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController messageController;
  final String selectedType; // 'comunicado' | 'permiso'
  final Size screenSize;

  final bool enabled;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onMessageChanged;
  final String? errorTitleText;
  final String? errorMessageText;

  const MessageContentForm({
    super.key,
    required this.titleController,
    required this.messageController,
    required this.selectedType,
    required this.screenSize,
    this.enabled = true,
    this.onTitleChanged,
    this.onMessageChanged,
    this.errorTitleText,
    this.errorMessageText,
  });

  // ancho “reservado” para que el texto no se meta debajo del pill
  double get _titleCounterReserve => screenSize.width * 0.22; // ~22% (80/80)
  double get _messageCounterReserve =>
      screenSize.width * 0.26; // ~26% (500/500)

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // ---------- TÍTULO ----------
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          child: Stack(
            children: [
              TextField(
                enabled: enabled,
                controller: titleController,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                maxLength: 80,
                maxLengthEnforcement:
                    MaxLengthEnforcement.truncateAfterCompositionEnds,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                onChanged: onTitleChanged,
                decoration: InputDecoration(
                  fillColor: AppTheme.getBackgroundColor(context),
                  labelText: l10n.messageTitle,
                  labelStyle: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  hintText: selectedType == 'comunicado'
                      ? l10n.exampleCommunicationTitle
                      : l10n.examplePermissionTitle,
                  hintStyle: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context)
                        // ignore: deprecated_member_use
                        .withOpacity(0.7),
                  ),
                  errorText: errorTitleText,
                  prefixIcon: Container(
                    margin: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.8),
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.6),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(Icons.title_rounded,
                        color: AppTheme.accentBlue,
                        size: screenSize.height * 0.022),
                  ),
                  border: InputBorder.none,

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    borderSide:
                        BorderSide(color: AppTheme.accentBlue, width: 2),
                  ),
                  // padding normal + reserva del contador + un pequeño gap
                  contentPadding: EdgeInsets.fromLTRB(
                    AppTheme.getMediumPadding(screenSize),
                    AppTheme.getMediumPadding(screenSize),
                    AppTheme.getSmallPadding(screenSize) + _titleCounterReserve,
                    AppTheme.getMediumPadding(screenSize),
                  ),
                  // ocultamos el contador nativo
                  counterText: '',
                ),
              ),
              // contador interno con blur
              Positioned(
                right: AppTheme.getMediumPadding(screenSize),
                bottom: AppTheme.getSmallPadding(screenSize) * 0.6,
                child: _CounterPill(
                  text: '${titleController.text.characters.length}/80',
                  screenSize: screenSize,
                  context: context,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // ---------- MENSAJE ----------
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          child: Stack(
            children: [
              TextField(
                enabled: enabled,
                controller: messageController,
                maxLines: 6,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 500,
                maxLengthEnforcement:
                    MaxLengthEnforcement.truncateAfterCompositionEnds,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  height: 1.5,
                ),
                onChanged: onMessageChanged,
                decoration: InputDecoration(
                  labelText: l10n.message,
                  fillColor: AppTheme.getBackgroundColor(context),
                  labelStyle: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  hintText: selectedType == 'comunicado'
                      ? l10n.communicationContentHint
                      : l10n.messageContentHint,
                  hintStyle: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context)
                        // ignore: deprecated_member_use
                        .withOpacity(0.7),
                    height: 1.4,
                  ),
                  errorText: errorMessageText,
                  alignLabelWithHint: true,
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    borderSide:
                        BorderSide(color: AppTheme.accentBlue, width: 2),
                  ),
                  // padding normal + reserva del contador + gap
                  contentPadding: EdgeInsets.fromLTRB(
                    AppTheme.getMediumPadding(screenSize),
                    AppTheme.getMediumPadding(screenSize),
                    AppTheme.getSmallPadding(screenSize) +
                        _messageCounterReserve,
                    AppTheme.getMediumPadding(screenSize),
                  ),
                  counterText: '',
                ),
              ),
              Positioned(
                right: AppTheme.getMediumPadding(screenSize),
                bottom: AppTheme.getSmallPadding(screenSize) * 0.6,
                child: _CounterPill(
                  text: '${messageController.text.characters.length}/500',
                  screenSize: screenSize,
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterPill extends StatelessWidget {
  final String text;
  final Size screenSize;
  final BuildContext context;
  const _CounterPill({
    required this.text,
    required this.screenSize,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final radius = AppTheme.getSmallRadius(screenSize);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // <- blur sutil
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize) * 0.45,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context)
                // ignore: deprecated_member_use
                .withOpacity(0.65), // <- translúcido
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
