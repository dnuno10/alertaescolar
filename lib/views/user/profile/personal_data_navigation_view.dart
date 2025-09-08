import 'package:alertaescolar/app/app_routes.dart';
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
    // Resolver (solo para admins) tras el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolInfo();
    });
  }

  Future<void> _loadSchoolInfo({bool forceRefresh = false}) async {
    final userProvider = context.read<UserProvider>();

    // Asegurar usuario cargado si hiciera falta
    if (userProvider.currentUser == null && mounted) {
      await userProvider.loadCurrentUser(context, showDialog: false);
    }

    // ⚠️ Solo ADMIN puede estar asociado a escuela. Si no es admin, no consultamos nada.
    if (!userProvider.isAdmin()) {
      if (!mounted) return;
      setState(() {
        _schoolName = null;
        _isLoadingSchool = false;
      });
      return;
    }

    // A partir de aquí, es admin
    final schoolProvider = context.read<SchoolProvider>();

    setState(() {
      _isLoadingSchool = true;
    });

    try {
      // Intentar obtener/asegurar escuelaId
      String? escuelaId = userProvider.currentUser?.escuelaId;
      escuelaId ??= await userProvider.ensureEscuelaIdLoaded();

      if (!mounted) return;

      // Si no hay escuela definida, limpiar y salir
      if (escuelaId == null || escuelaId.isEmpty) {
        setState(() {
          _schoolName = null;
          _isLoadingSchool = false;
        });
        return;
      }

      // 1) Resolver solo el nombre (consulta ligera, con caché)
      final name = await schoolProvider.getSchoolNameById(
        escuelaId,
        forceRefresh: forceRefresh,
      );

      // 2) Fallback (opcional): si no vino nombre, intentar cargar la escuela completa
      String? finalName = name;
      if (finalName == null) {
        final escuela = await schoolProvider.getSchoolById(
          escuelaId,
          useCache: !forceRefresh,
        );
        finalName = escuela?.nombre;
      }

      if (!mounted) return;
      setState(() {
        _schoolName = finalName;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _schoolName = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingSchool = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    // Recarga silenciosa de usuario…
    await context.read<UserProvider>().reloadSilently(context);

    // …y SOLO si es admin re-intenta cargar la escuela
    if (!mounted) return;
    if (context.read<UserProvider>().isAdmin()) {
      await _loadSchoolInfo(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
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
                          route: AppRoutes.personalInformation,
                          screenSize: screenSize,
                        ),
                        const PersonalDataDivider(),
                        PersonalDataNavigationTile(
                          title: l10n.contactInformation,
                          subtitle: l10n.viewContactData,
                          icon: Icons.contact_mail_outlined,
                          route: AppRoutes.contactInformation,
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
                            // Tipo de usuario
                            PersonalDataInfoTile(
                              label: l10n.userType,
                              value: _formatUserRole(user?.tipo, l10n),
                              screenSize: screenSize,
                            ),

                            // Subtipo de admin (si aplica)
                            if (user?.tipo == TipoUsuario.administrador &&
                                user?.tipoAdministrador != null) ...[
                              const PersonalDataDivider(),
                              PersonalDataInfoTile(
                                label: l10n.adminRole,
                                value: _formatAdminType(
                                  user?.tipoAdministrador,
                                  l10n,
                                ),
                                screenSize: screenSize,
                              ),
                            ],

                            const PersonalDataDivider(),

                            // Fecha de registro
                            PersonalDataInfoTile(
                              label: l10n.registrationDate,
                              value: user?.fechaRegistro != null
                                  ? l10n.dateFormat(user!.fechaRegistro)
                                  : 'N/A',
                              screenSize: screenSize,
                            ),

                            // Escuela (SOLO admins)
                            if (userProvider.isAdmin() &&
                                (user?.escuelaId != null ||
                                    _schoolName != null ||
                                    _isLoadingSchool)) ...[
                              const PersonalDataDivider(),
                              PersonalDataInfoTile(
                                label: l10n.school,
                                value: _isLoadingSchool
                                    ? '${l10n.loading}...'
                                    : (_schoolName ?? user?.escuelaId ?? 'N/A'),
                                screenSize: screenSize,
                              ),
                            ],
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
    }
  }
}
