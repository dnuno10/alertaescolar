import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/tips_cards/info_notice_card_action.dart';
import 'package:alertaescolar/components/profile/contact_section_title.dart';
import 'package:alertaescolar/components/profile/contact_info_card.dart';
import 'package:alertaescolar/components/profile/security_info_card.dart';
import 'package:alertaescolar/components/profile/contact_tile.dart';
import 'package:alertaescolar/components/profile/security_tile.dart';
import 'package:alertaescolar/components/profile/contact_divider.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../managers/user_provider.dart';
import '../../../../managers/school_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/app_theme.dart';
import '../../../../models/usuario.dart';

class ContactInformationView extends StatefulWidget {
  const ContactInformationView({super.key});

  @override
  State<ContactInformationView> createState() => _ContactInformationViewState();
}

class _ContactInformationViewState extends State<ContactInformationView> {
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

      final school = await schoolProvider
          .getSchoolById(userProvider.currentUser!.escuelaId!);

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

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.viewContactData),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Details Section
                      ContactSectionTitle(
                        title: l10n.contactData,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final user = userProvider.currentUser;
                          return ContactInfoCard(
                            screenSize: screenSize,
                            children: [
                              ContactTile(
                                icon: Icons.email_outlined,
                                title: l10n.email,
                                subtitle: l10n.primaryEmailAddress,
                                value: user?.email ?? l10n.notRegistered,
                                isVerified: true,
                                screenSize: screenSize,
                              ),
                              if (user?.telefono != null &&
                                  user!.telefono!.isNotEmpty) ...[
                                ContactDivider(screenSize: screenSize),
                                ContactTile(
                                  icon: Icons.phone_outlined,
                                  title: l10n.phoneNumber,
                                  subtitle: l10n.primaryContact,
                                  value: user.telefono!,
                                  isVerified: false,
                                  screenSize: screenSize,
                                ),
                              ],
                              // Mostrar campo específico según el tipo de usuario
                              if (user?.tipo == TipoUsuario.administrador &&
                                  user?.escuelaId != null) ...[
                                ContactDivider(screenSize: screenSize),
                                ContactTile(
                                  icon: Icons.school_outlined,
                                  title: l10n.school,
                                  subtitle: l10n.associatedSchool,
                                  value: _isLoadingSchool
                                      ? '${l10n.loading}...'
                                      : _schoolName ??
                                          user?.escuelaId ??
                                          l10n.notRegistered,
                                  isVerified: true,
                                  screenSize: screenSize,
                                ),
                              ],
                              // Para padres/tutores, podríamos mostrar los estudiantes asociados
                              if (user?.tipo != TipoUsuario.administrador) ...[
                                ContactDivider(screenSize: screenSize),
                                ContactTile(
                                  icon: Icons.person_outline,
                                  title: l10n.userType,
                                  subtitle: l10n.accountType,
                                  value: _getUserRoleText(user?.tipo, l10n),
                                  isVerified: false,
                                  screenSize: screenSize,
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Security Info Section
                      ContactSectionTitle(
                        title: l10n.securityInformation,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final user = userProvider.currentUser;
                          return SecurityInfoCard(
                            screenSize: screenSize,
                            children: [
                              SecurityTile(
                                icon: Icons.verified_user_outlined,
                                title: l10n.accountStatus,
                                value: l10n.verified,
                                color: AppTheme.successColor,
                                screenSize: screenSize,
                              ),
                              ContactDivider(screenSize: screenSize),
                              if (userProvider.isAdmin()) ...[
                                ContactDivider(screenSize: screenSize),
                                SecurityTile(
                                  icon: Icons.admin_panel_settings_outlined,
                                  title: l10n.administrativeRole,
                                  value: _getAdminRoleText(
                                      user?.tipoAdministrador, l10n),
                                  color: AppTheme.accentPurple,
                                  screenSize: screenSize,
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Info Notice
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          if (userProvider.isAdmin()) {
                            return AdminInfoNoticeCard(
                              l10n: l10n,
                              screenSize: screenSize,
                            );
                          } else {
                            return InfoNoticeCardAction(
                              l10n: l10n,
                              screenSize: screenSize,
                            );
                          }
                        },
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUserRoleText(TipoUsuario? tipo, AppLocalizations l10n) {
    if (tipo == null) return l10n.parentRole;

    switch (tipo) {
      case TipoUsuario.padre:
        return l10n.fatherRole;
      case TipoUsuario.madre:
        return l10n.motherRole;
      case TipoUsuario.tutor:
        return l10n.tutorRole;
      case TipoUsuario.familiar:
        return l10n.relativeRole;
      case TipoUsuario.administrador:
        return l10n.adminRole;
    }
  }

  String _getAdminRoleText(TipoAdministrador? tipo, AppLocalizations l10n) {
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
    }
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Today
      return '${AppLocalizations.of(context).todayAt} ${DateFormat.Hm().format(dateTime)}';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      // Yesterday
      return '${AppLocalizations.of(context).yesterdayAt} ${DateFormat.Hm().format(dateTime)}';
    } else {
      // Other days
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
}

// Añade esta clase para admins
class AdminInfoNoticeCard extends StatelessWidget {
  final AppLocalizations l10n;
  final Size screenSize;

  const AdminInfoNoticeCard({
    super.key,
    required this.l10n,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border:
            Border.all(color: AppTheme.accentPurple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined,
                  color: AppTheme.accentPurple, size: screenSize.width * 0.06),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.administratorAccount,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.adminAccountInformation,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
