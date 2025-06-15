import 'package:alertaescolar/components/danger_zone_card.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/profile/personal_data_section_title.dart';
import 'package:alertaescolar/components/profile/personal_data_navigation_card.dart';
import 'package:alertaescolar/components/profile/personal_data_info_card.dart';
import 'package:alertaescolar/components/profile/personal_data_navigation_tile.dart';
import 'package:alertaescolar/components/profile/personal_data_info_tile.dart';
import 'package:alertaescolar/components/profile/personal_data_divider.dart';
import 'package:alertaescolar/components/profile/security_section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/school_provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/usuario.dart';

class PersonalDataNavigationView extends StatefulWidget {
  const PersonalDataNavigationView({super.key});

  @override
  State<PersonalDataNavigationView> createState() =>
      _PersonalDataNavigationViewState();
}

class _PersonalDataNavigationViewState
    extends State<PersonalDataNavigationView> {
  String? _schoolName;
  bool _isLoadingSchool = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolInfo();
    });
  }

  Future<void> _loadSchoolInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);

    if (userProvider.currentUser?.escuelaId != null) {
      setState(() {
        _isLoadingSchool = true;
      });

      final school = await schoolProvider.getSchoolById(
          userProvider.currentUser!.escuelaId!, context);

      if (mounted) {
        setState(() {
          _schoolName = school?.nombre;
          _isLoadingSchool = false;
        });
      }
    }
  }

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
                      final user = userProvider.currentUser;
                      return PersonalDataInfoCard(
                        screenSize: screenSize,
                        children: [
                          PersonalDataInfoTile(
                            label: l10n.userType,
                            value: _formatUserRole(user?.tipo, l10n),
                            screenSize: screenSize,
                          ),
                          if (user?.tipo == TipoUsuario.administrador &&
                              user?.tipoAdministrador != null) ...[
                            const PersonalDataDivider(),
                            PersonalDataInfoTile(
                              label: l10n.adminRole,
                              value: _formatAdminType(
                                  user?.tipoAdministrador, l10n),
                              screenSize: screenSize,
                            ),
                          ],
                          const PersonalDataDivider(),
                          PersonalDataInfoTile(
                            label: l10n.registrationDate,
                            value: user?.fechaRegistro != null
                                ? l10n.dateFormat(user!.fechaRegistro)
                                : 'N/A',
                            screenSize: screenSize,
                          ),
                          if (user?.escuelaId != null) ...[
                            const PersonalDataDivider(),
                            PersonalDataInfoTile(
                              label: l10n.school,
                              value: _isLoadingSchool
                                  ? '${l10n.loading}...'
                                  : _schoolName ?? user?.escuelaId ?? 'N/A',
                              screenSize: screenSize,
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Account Deletion Section
                  SecuritySectionTitle(
                    title: l10n.dangerZone,
                    screenSize: screenSize,
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                  DangerZoneCard(l10n: l10n, screenSize: screenSize),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUserRole(TipoUsuario? tipo, AppLocalizations l10n) {
    if (tipo == null) return l10n.user;

    switch (tipo) {
      case TipoUsuario.administrador:
        return l10n.adminRole;
      case TipoUsuario.padre:
        return l10n.fatherRole;
      case TipoUsuario.madre:
        return l10n.motherRole;
      case TipoUsuario.tutor:
        return l10n.tutorRole;
      case TipoUsuario.familiar:
        return l10n.relativeRole;
      // No default needed as we've covered all cases
    }
  }

  String _formatAdminType(TipoAdministrador? tipo, AppLocalizations l10n) {
    if (tipo == null) return l10n.administrativo;

    switch (tipo) {
      case TipoAdministrador.director:
        return l10n.director;
      case TipoAdministrador.subdirector:
        return l10n.subdirector;
      case TipoAdministrador.secretario:
        return l10n.secretary;
      case TipoAdministrador.personalSeguridad:
        return l10n.securityStaff;
      case TipoAdministrador.maestro:
        return l10n.teacher;
      case TipoAdministrador.administrativo:
        return l10n.administrative;
      // No default needed as we've covered all cases
    }
  }
}
