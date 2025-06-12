import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';

class StudentFamilyInfoCard extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const StudentFamilyInfoCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Mock family data for the student
    final familyMembers = _generateMockFamilyData();

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.family_restroom_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.familyContacts,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.5),
                ),
                child: Text(
                  '${familyMembers.length} ${l10n.contacts ?? 'contactos'}',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Family Members List
          ...familyMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            return _FamilyMemberItem(
              member: member,
              screenSize: screenSize,
              isLast: index == familyMembers.length - 1,
              l10n: l10n,
            );
          }),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        ],
      ),
    );
  }

  List<Map<String, String>> _generateMockFamilyData() {
    return [
      {
        'name': 'María Elena García',
        'relationship': 'Madre',
        'phone': '+52 55 1234 5678',
        'email': 'maria.garcia@email.com',
        'occupation': 'Doctora',
        'isPrimary': 'true',
      },
      {
        'name': 'Carlos Martínez López',
        'relationship': 'Padre',
        'phone': '+52 55 9876 5432',
        'email': 'carlos.martinez@email.com',
        'occupation': 'Ingeniero',
        'isPrimary': 'false',
      },
      {
        'name': 'Ana García Ruiz',
        'relationship': 'Abuela',
        'phone': '+52 55 5555 1234',
        'email': 'ana.garcia@email.com',
        'occupation': 'Jubilada',
        'isPrimary': 'false',
      },
    ];
  }
}

class _FamilyMemberItem extends StatelessWidget {
  final Map<String, String> member;
  final Size screenSize;
  final bool isLast;
  final AppLocalizations l10n;

  const _FamilyMemberItem({
    required this.member,
    required this.screenSize,
    required this.isLast,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = member['isPrimary'] == 'true';

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: isPrimary
            ? Border.all(
                color: AppTheme.accentPurple.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and relationship
          Row(
            children: [
              Expanded(
                child: Text(
                  member['name']!,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isPrimary)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize) * 0.5),
                  ),
                  child: Text(
                    l10n.primaryContact ?? 'Principal',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          // Relationship
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
              vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(screenSize) * 0.5),
            ),
            child: Text(
              member['relationship']!,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Contact Information
          _ContactRow(
            icon: Icons.phone_rounded,
            label: l10n.phone ?? 'Teléfono',
            value: member['phone']!,
            screenSize: screenSize,
            color: AppTheme.successColor,
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          _ContactRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: member['email']!,
            screenSize: screenSize,
            color: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Size screenSize;
  final Color color;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.screenSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: screenSize.height * 0.018,
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
        Text(
          '$label: ',
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
