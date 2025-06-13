import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/profile/personal_data_section_title.dart';
import 'package:alertaescolar/components/profile/personal_data_navigation_card.dart';
import 'package:alertaescolar/components/profile/personal_data_info_card.dart';
import 'package:alertaescolar/components/profile/personal_data_navigation_tile.dart';
import 'package:alertaescolar/components/profile/personal_data_info_tile.dart';
import 'package:alertaescolar/components/profile/personal_data_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../managers/user_provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class PersonalDataNavigationView extends StatelessWidget {
  const PersonalDataNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          NavHeader(title: l10n.personalData),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Data Section
                  PersonalDataSectionTitle(
                    title: l10n.personalData,
                    screenSize: screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  PersonalDataNavigationCard(
                    screenSize: screenSize,
                    children: [
                      PersonalDataNavigationTile(
                        title: l10n.personalInformation,
                        subtitle: l10n.managePersonalDetails,
                        icon: Icons.person_outline,
                        route: '/profile/personal-information',
                        screenSize: screenSize,
                      ),
                      const PersonalDataDivider(),
                      PersonalDataNavigationTile(
                        title: l10n.contactInformation,
                        subtitle: l10n.viewContactData,
                        icon: Icons.contact_mail_outlined,
                        route: '/profile/contact-information',
                        screenSize: screenSize,
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Account Information Section
                  PersonalDataSectionTitle(
                    title: l10n.accountInformation,
                    screenSize: screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return PersonalDataInfoCard(
                        screenSize: screenSize,
                        children: [
                          PersonalDataInfoTile(
                            label: l10n.userType,
                            value: _formatUserType(
                              userProvider.currentUser?.tipo.name ?? 'unknown',
                              l10n,
                            ),
                            screenSize: screenSize,
                          ),
                          const PersonalDataDivider(),
                          PersonalDataInfoTile(
                            label: l10n.registrationDate,
                            value: _formatDate(
                                userProvider.currentUser?.fechaRegistro),
                            screenSize: screenSize,
                          ),
                          const PersonalDataDivider(),
                          PersonalDataInfoTile(
                            label: l10n.lastLogin,
                            value: _formatDate(
                                userProvider.currentUser?.fechaRegistro),
                            screenSize: screenSize,
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUserType(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'admin':
        return l10n.administrator;
      case 'teacher':
        return l10n.teacher;
      case 'parent':
        return l10n.parent;
      case 'student':
        return l10n.student;
      default:
        return l10n.user;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
