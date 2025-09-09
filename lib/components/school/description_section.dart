// lib/components/school/description_section.dart
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class DescriptionSection extends StatelessWidget {
  final String description;
  final Size screenSize;

  const DescriptionSection({
    super.key,
    required this.description,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rad = AppTheme.getLargeRadius(screenSize);
    final padM = AppTheme.getMediumPadding(screenSize);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header minimal (estilo consistente con InfoSection/QuickStats)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(padM),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(rad),
                topRight: Radius.circular(rad),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.aboutSchool,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getSubtitle1(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cuerpo de texto (limpio, legible)
          Padding(
            padding: EdgeInsets.only(left: padM, right: padM, bottom: padM),
            child: Text(
              (description.trim().isEmpty)
                  ? l10n.schoolDescription
                  : description.trim(),
              textAlign: TextAlign.justify,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
