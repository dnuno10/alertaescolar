// lib/views/school/school_info_view.dart
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/school/school_header_card.dart';
import 'package:alertaescolar/components/school/quick_stats_section.dart';
import 'package:alertaescolar/components/school/info_section.dart';
import 'package:alertaescolar/components/school/info_row.dart';
// import 'package:alertaescolar/components/school/education_level_chips.dart'; // ← ya no se usa
import 'package:alertaescolar/components/school/contact_card.dart';
import 'package:alertaescolar/components/school/description_section.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../app/app_theme.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/school_provider.dart';

class SchoolInfoView extends StatefulWidget {
  /// Si viene por props, se usará su id para la carga inicial.
  final Escuela? school;

  const SchoolInfoView({super.key, this.school});

  @override
  State<SchoolInfoView> createState() => _SchoolInfoViewState();
}

class _SchoolInfoViewState extends State<SchoolInfoView>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  /// Error local para excepciones fuera del provider (p.ej. falta de id_escuela).
  String? _localError;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolData(forceRefresh: false);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSchoolData({bool forceRefresh = false}) async {
    setState(() => _localError = null);

    try {
      final userProvider = context.read<UserProvider>();
      final schoolProvider = context.read<SchoolProvider>();

      // Asegura que exista usuario si lo necesitas como fallback
      if (userProvider.currentUser == null) {
        await userProvider.loadCurrentUser(context, showDialog: false);
      }

      // Orden de precedencia: prop -> usuario -> cache del provider
      final escuelaId = widget.school?.id ??
          userProvider.currentUser?.escuelaId ??
          schoolProvider.currentSchool?.id;

      if (escuelaId == null || escuelaId.isEmpty) {
        throw Exception('No hay un id_escuela disponible');
      }

      await schoolProvider.loadSchool(escuelaId, forceRefresh: forceRefresh);

      if (!mounted) return;
      if (_fadeCtrl.status != AnimationStatus.forward) {
        _fadeCtrl.forward(from: 0);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _localError = e.toString());
    }
  }

  Future<void> _onRefresh() async {
    await _loadSchoolData(forceRefresh: true);
  }

  // ---------- Launchers: Maps (Google), Phone, Email ----------
  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    // Prefer Google Maps app (iOS/Android) if installed
    final gmapsApp = Uri.parse('comgooglemaps://?q=$query');
    if (await canLaunchUrl(gmapsApp)) {
      await launchUrl(gmapsApp, mode: LaunchMode.externalApplication);
      return;
    }
    // Web fallback that also works on Android/iOS
    final gmaps =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(gmaps)) {
      await launchUrl(gmaps, mode: LaunchMode.externalApplication);
      return;
    }
    // Fallback to geo: (Android) or universal maps URL
    final geo = Uri.parse('geo:0,0?q=$query');
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo, mode: LaunchMode.externalApplication);
      return;
    }
    // Last resort try universal map URL in browser
    await launchUrl(gmaps, mode: LaunchMode.platformDefault);
  }

  Future<void> _callPhone(String phoneRaw) async {
    final digits = phoneRaw.replaceAll(RegExp(r'[^0-9+]+'), '');
    final tel = Uri.parse('tel:$digits');
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final mailto = Uri(
      scheme: 'mailto',
      path: email,
      // You can add subject/body defaults if desired via queryParameters
    );
    if (await canLaunchUrl(mailto)) {
      await launchUrl(mailto, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    // Leemos el estado directamente del provider (única fuente de verdad).
    final sp = context.watch<SchoolProvider>();
    final isLoading = sp.isLoading;
    final providerError = sp.error;
    final school = sp.currentSchool;

    return Consumer<ThemeProvider>(
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: RefreshIndicator.adaptive(
            onRefresh: _onRefresh,
            displacement: 88,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                NavHeader(title: l10n.schoolInfo),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
                    child: _buildBody(
                      l10n: l10n,
                      size: size,
                      isLoading: isLoading,
                      errorText: _localError ?? providerError,
                      school: school,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required AppLocalizations l10n,
    required Size size,
    required bool isLoading,
    required String? errorText,
    required Escuela? school,
  }) {
    if (isLoading) return _buildSkeleton(size);
    if (errorText != null) return _buildError(l10n, size, errorText);
    if (school == null) return _buildEmpty(l10n, size);
    return FadeTransition(
        opacity: _fade, child: _buildContent(l10n, size, school));
  }

  // ---------- Skeleton / Loading ----------
  Widget _buildSkeleton(Size size) {
    final base = AppTheme.getCardColor(context);
    Widget shimmer({required double h, double? w, double r = 12}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(r),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
        );

    return Column(
      children: [
        SizedBox(height: AppTheme.getSmallPadding(size)),
        shimmer(h: size.height * 0.18, r: AppTheme.getLargeRadius(size)),
        SizedBox(height: AppTheme.getLargePadding(size)),
        shimmer(h: 100, r: AppTheme.getLargeRadius(size)),
        SizedBox(height: AppTheme.getLargePadding(size)),
        shimmer(h: 180, r: AppTheme.getLargeRadius(size)),
        SizedBox(height: AppTheme.getLargePadding(size)),
        shimmer(h: 160, r: AppTheme.getLargeRadius(size)),
        SizedBox(height: AppTheme.getLargePadding(size)),
        shimmer(h: 180, r: AppTheme.getLargeRadius(size)),
        SizedBox(height: AppTheme.getLargePadding(size) * 2),
      ],
    );
  }

  // ---------- Error / Empty ----------
  Widget _buildError(AppLocalizations l10n, Size size, String message) {
    return _StatusBox(
      icon: Icons.error_outline,
      title: l10n.errorLoadingSchoolInfo,
      subtitle: message,
      size: size,
      primary: AppTheme.errorColor,
      actionLabel: l10n.retry,
      onAction: () => _loadSchoolData(forceRefresh: true),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, Size size) {
    return _StatusBox(
      icon: Icons.school_outlined,
      title: l10n.schoolInfo,
      subtitle: l10n.notAvailable,
      size: size,
      primary: AppTheme.accentBlue,
      actionLabel: l10n.refresh,
      onAction: () => _loadSchoolData(forceRefresh: true),
    );
  }

  // ---------- Content ----------
  Widget _buildContent(AppLocalizations l10n, Size size, Escuela s) {
    final tipoStr = _getSchoolType(s.tipo, l10n);

    // Quick stats: solo datos existentes en la tabla `escuelas`
    final stats = [
      {
        'title': tipoStr,
        'subtitle': l10n.institution, // tipo de institución
        'icon': Icons.apartment_rounded,
        'color': AppTheme.warningColor,
      },
      {
        'title':
            (s.codigo ?? '').isNotEmpty ? (s.codigo ?? '') : l10n.notAvailable,
        'subtitle': l10n.schoolCode,
        'icon': Icons.tag_rounded,
        'color': AppTheme.accentBlue,
      },
    ];

    return Column(
      children: [
        SizedBox(height: AppTheme.getSmallPadding(size)),

        // Header + acciones
        SchoolHeaderCard(
          schoolName: s.nombre,
          subtitle: l10n.educationalExcellenceInstitution,
          screenSize: size,
        ),
        SizedBox(height: AppTheme.getSmallPadding(size)),
        _QuickActionsBar(
          size: size,
          addressEnabled: s.direccion.isNotEmpty,
          phoneEnabled: s.telefono.isNotEmpty,
          emailEnabled: s.email.isNotEmpty,
          onOpenMap:
              s.direccion.isNotEmpty ? () => _openMap(s.direccion) : null,
          onCall: s.telefono.isNotEmpty ? () => _callPhone(s.telefono) : null,
          onEmail: s.email.isNotEmpty ? () => _sendEmail(s.email) : null,
        ),

        SizedBox(height: AppTheme.getLargePadding(size)),

        // Quick stats
        QuickStatsSection(screenSize: size, stats: stats),

        SizedBox(height: AppTheme.getLargePadding(size)),

        // Basic info
        InfoSection(
          title: l10n.basicInformation,
          icon: Icons.info_outline_rounded,
          color: AppTheme.accentBlue,
          screenSize: size,
          children: [
            InfoRow(
              label: l10n.schoolCode,
              value: (s.codigo ?? '').isNotEmpty
                  ? (s.codigo ?? '')
                  : l10n.notAvailable,
              icon: Icons.tag_rounded,
              screenSize: size,
            ),
            InfoRow(
              label: l10n.schoolType,
              value: tipoStr,
              icon: Icons.business_rounded,
              screenSize: size,
            ),
          ],
        ),

        SizedBox(height: AppTheme.getLargePadding(size)),

        // Contact info
        InfoSection(
          title: l10n.contactInfo,
          icon: Icons.contact_phone_rounded,
          color: AppTheme.successColor,
          screenSize: size,
          children: [
            ContactCard(
              label: l10n.address,
              value: s.direccion.isNotEmpty ? s.direccion : l10n.notAvailable,
              icon: Icons.location_on_rounded,
              screenSize: size,
              isClickable: s.direccion.isNotEmpty,
              onTap:
                  s.direccion.isNotEmpty ? () => _openMap(s.direccion) : null,
            ),
            ContactCard(
              label: l10n.phone,
              value: s.telefono.isNotEmpty ? s.telefono : l10n.notAvailable,
              icon: Icons.phone_rounded,
              screenSize: size,
              isClickable: s.telefono.isNotEmpty,
              onTap:
                  s.telefono.isNotEmpty ? () => _callPhone(s.telefono) : null,
            ),
            ContactCard(
              label: l10n.email,
              value: s.email.isNotEmpty ? s.email : l10n.notAvailable,
              icon: Icons.email_rounded,
              screenSize: size,
              isClickable: s.email.isNotEmpty,
              onTap: s.email.isNotEmpty ? () => _sendEmail(s.email) : null,
            ),
            if ((s.sitioWeb ?? '').isNotEmpty)
              ContactCard(
                label: l10n.website,
                value: s.sitioWeb!,
                icon: Icons.language_rounded,
                screenSize: size,
                isClickable: true,
                onTap: () async {
                  final url = Uri.parse(s.sitioWeb!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
          ],
        ),

        SizedBox(height: AppTheme.getLargePadding(size)),

        // Description
        DescriptionSection(
          description: (s.descripcion ?? '').isNotEmpty
              ? s.descripcion!
              : l10n.schoolDescription,
          screenSize: size,
        ),

        SizedBox(height: AppTheme.getLargePadding(size) * 2),
      ],
    );
  }

  // ---------- Helpers de mapeo ----------
  String _getSchoolType(TipoEscuela? tipo, AppLocalizations l10n) {
    if (tipo == null) return l10n.public;
    switch (tipo) {
      case TipoEscuela.publica:
        return l10n.public;
      case TipoEscuela.privada:
        return l10n.private;
      case TipoEscuela.mixta:
        return l10n.mixed;
    }
  }
}

// ---------- Widgets auxiliares ----------

class _StatusBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Size size;
  final Color primary;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.primary,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      child: Column(
        children: [
          SizedBox(height: AppTheme.getLargePadding(size) * 1.5),
          Icon(icon, size: 64, color: primary),
          SizedBox(height: AppTheme.getMediumPadding(size)),
          Text(
            title,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: primary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(size)),
          Text(
            subtitle,
            style: AppTheme.getBodyLarge(size).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: AppTheme.getMediumPadding(size)),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          SizedBox(height: AppTheme.getLargePadding(size) * 2),
        ],
      ),
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  final Size size;
  final bool addressEnabled;
  final bool phoneEnabled;
  final bool emailEnabled;
  final VoidCallback? onOpenMap;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;

  const _QuickActionsBar({
    required this.size,
    required this.addressEnabled,
    required this.phoneEnabled,
    required this.emailEnabled,
    this.onOpenMap,
    this.onCall,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn({
      required IconData icon,
      required String label,
      required bool enabled,
      required VoidCallback? onTap,
    }) {
      return Expanded(
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getSmallPadding(size) * 0.9,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(size)),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: size.height * 0.022,
                      color: AppTheme.getTextPrimaryColor(context)),
                  SizedBox(width: AppTheme.getSmallPadding(size)),
                  Text(
                    label,
                    style: AppTheme.getCaption(size).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn(
          icon: Icons.map_rounded,
          label: 'Mapa',
          enabled: addressEnabled,
          onTap: onOpenMap,
        ),
        SizedBox(width: AppTheme.getSmallPadding(size)),
        btn(
          icon: Icons.call_rounded,
          label: 'Llamar',
          enabled: phoneEnabled,
          onTap: onCall,
        ),
        SizedBox(width: AppTheme.getSmallPadding(size)),
        btn(
          icon: Icons.email_rounded,
          label: 'Email',
          enabled: emailEnabled,
          onTap: onEmail,
        ),
      ],
    );
  }
}
