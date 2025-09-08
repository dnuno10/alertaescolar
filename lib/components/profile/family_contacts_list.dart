import 'package:flutter/material.dart';
import 'family_empty_state.dart';
import 'family_contact_tile.dart';
import '../../models/contacto_familiar.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class FamilyContactsList extends StatelessWidget {
  final List<ContactoFamiliar> familyContacts;

  // 🔧 Firma simplificada: sólo el contacto
  final void Function(ContactoFamiliar) onEditContact;

  // Mantiene l10n/size en delete porque muestras textos contextuales
  final void Function(ContactoFamiliar, AppLocalizations, Size) onDeleteContact;

  final Size screenSize;

  const FamilyContactsList({
    super.key,
    required this.familyContacts,
    required this.onEditContact,
    required this.onDeleteContact,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: familyContacts.isEmpty
          ? FamilyEmptyState(screenSize: screenSize)
          : Column(
              children: familyContacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;
                return FamilyContactTile(
                  contact: contact,
                  isLast: index == familyContacts.length - 1,
                  // 🔧 Ahora sólo pasamos el contacto
                  onEdit: () => onEditContact(contact),
                  onDelete: () => onDeleteContact(contact, l10n, screenSize),
                  screenSize: screenSize,
                );
              }).toList(),
            ),
    );
  }
}
