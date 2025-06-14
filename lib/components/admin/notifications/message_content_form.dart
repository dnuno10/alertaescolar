import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_snack_bar.dart';

class MessageContentForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController messageController;
  final String selectedType;
  final Size screenSize;

  const MessageContentForm({
    super.key,
    required this.titleController,
    required this.messageController,
    required this.selectedType,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Title field
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: titleController,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            decoration: InputDecoration(
              labelText: l10n.messageTitle,
              labelStyle: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              hintText: selectedType == 'comunicado'
                  ? l10n.exampleCommunicationTitle
                  : l10n.examplePermissionTitle,
              hintStyle: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context)
                    .withValues(alpha: 0.7),
              ),
              prefixIcon: Container(
                margin:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.6),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.title_rounded,
                  color: AppTheme.accentOrange,
                  size: screenSize.height * 0.022,
                ),
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                borderSide: BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getMediumPadding(screenSize),
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Message field
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: messageController,
            maxLines: 6,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              height: 1.5,
            ),
            decoration: InputDecoration(
              labelText: l10n.message,
              labelStyle: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              hintText: selectedType == 'comunicado'
                  ? l10n.communicationContentHint
                  : l10n.messageContentHint,
              hintStyle: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context)
                    .withValues(alpha: 0.7),
                height: 1.4,
              ),
              alignLabelWithHint: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                borderSide: BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            ),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

        // Tips
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: AppTheme.accentOrange.withValues(alpha: 0.7),
              size: screenSize.height * 0.018,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
            Expanded(
              child: Text(
                selectedType == 'comunicado'
                    ? l10n.communicationTip
                    : l10n.messageTip,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
