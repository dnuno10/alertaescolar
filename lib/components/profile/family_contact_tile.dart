import 'package:flutter/material.dart';
import '../../models/contacto_familiar.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class FamilyContactTile extends StatelessWidget {
  final ContactoFamiliar contact;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Size screenSize;

  const FamilyContactTile({
    super.key,
    required this.contact,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Added non-null assertion

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              _getRelationIcon(contact.parentesco),
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.06,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.nombre,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.02,
                        vertical: screenSize.height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.02),
                      ),
                      child: Text(
                        _getRelationshipName(contact.parentesco, l10n),
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.005),
                if (contact.telefono.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: screenSize.width * 0.01),
                      Text(
                        contact.telefono,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                if (contact.email?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: screenSize.width * 0.01),
                      Expanded(
                        child: Text(
                          contact.email!,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            color: AppTheme.getSurfaceColor(context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: screenSize.width * 0.045,
                      color: AppTheme.getIconColor(context),
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    Text(
                      l10n.edit,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: screenSize.width * 0.045,
                      color: AppTheme.errorColor,
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    Text(
                      l10n.delete,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.width * 0.05,
            ),
          ),
        ],
      ),
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
