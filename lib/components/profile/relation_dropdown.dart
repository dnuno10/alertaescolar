import 'package:flutter/material.dart';
import '../../models/contacto_familiar.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class RelationDropdown extends StatelessWidget {
  final TipoParentesco selectedRelation;
  final ValueChanged<TipoParentesco?> onRelationChanged;
  final Size screenSize;

  const RelationDropdown({
    super.key,
    required this.selectedRelation,
    required this.onRelationChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.relationship,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TipoParentesco>(
              value: selectedRelation,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              dropdownColor: AppTheme.getSurfaceColor(context),
              items: TipoParentesco.values.map((TipoParentesco relation) {
                return DropdownMenuItem<TipoParentesco>(
                  value: relation,
                  child: Row(
                    children: [
                      Icon(
                        _getRelationIcon(relation),
                        size: screenSize.width * 0.04,
                        color: AppTheme.accentPurple,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        _getRelationshipName(relation, l10n),
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onRelationChanged,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getRelationIcon(TipoParentesco relation) {
    switch (relation) {
      case TipoParentesco.padre:
      case TipoParentesco.madre:
        return Icons.person_outline;
      case TipoParentesco.abuelo:
      case TipoParentesco.abuela:
        return Icons.elderly_outlined;
      case TipoParentesco.tutor:
      case TipoParentesco.tutora:
        return Icons.school_outlined;
      case TipoParentesco.tio:
      case TipoParentesco.tia:
        return Icons.family_restroom_outlined;
      case TipoParentesco.hermano:
      case TipoParentesco.hermana:
        return Icons.people_outline;
      default:
        return Icons.contact_phone_outlined;
    }
  }

  String _getRelationshipName(TipoParentesco relation, AppLocalizations l10n) {
    switch (relation) {
      case TipoParentesco.padre:
        return l10n.father;
      case TipoParentesco.madre:
        return l10n.mother;
      case TipoParentesco.abuelo:
        return l10n.grandfather;
      case TipoParentesco.abuela:
        return l10n.grandmother;
      case TipoParentesco.tutor:
        return l10n.guardian;
      case TipoParentesco.tutora:
        return l10n.guardianFemale;
      case TipoParentesco.tio:
        return l10n.uncle;
      case TipoParentesco.tia:
        return l10n.aunt;
      case TipoParentesco.hermano:
        return l10n.brother;
      case TipoParentesco.hermana:
        return l10n.sister;
      case TipoParentesco.otroFamiliar:
        return l10n.otherFamily;
    }
  }
}
