import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/components/school/school_header_card.dart';
import 'package:alertaescolar/components/school/quick_stats_section.dart';
import 'package:alertaescolar/components/school/info_section.dart';
import 'package:alertaescolar/components/school/info_row.dart';
import 'package:alertaescolar/components/school/education_level_chips.dart';
import 'package:alertaescolar/components/school/contact_card.dart';
import 'package:alertaescolar/components/school/description_section.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../app/app_theme.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/school_provider.dart';

class SchoolInfoView extends StatefulWidget {
  final Escuela? school;

  const SchoolInfoView({super.key, this.school});

  @override
  State<SchoolInfoView> createState() => _SchoolInfoViewState();
}

class _SchoolInfoViewState extends State<SchoolInfoView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Escuela? _school;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolData();
    });
  }

  Future<void> _loadSchoolData() async {
    // Si ya viene la escuela vía props, úsala tal cual
    if (widget.school != null) {
      setState(() {
        _school = widget.school;
        _isLoading = false;
      });
      _animationController.forward();
      return;
    }

    // Cargar desde el id_escuela del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LoadingDialog.show(context,
            message: 'Cargando información de la escuela...');
      }
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final schoolProvider =
          Provider.of<SchoolProvider>(context, listen: false);

      final escuelaId = userProvider.currentUser?.escuelaId;
      if (escuelaId != null && escuelaId.isNotEmpty) {
        final school =
            await schoolProvider.loadSchool(escuelaId, context: context);
        if (mounted) {
          setState(() => _school = school);
        }
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.errorLoadingSchoolInfo}: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } finally {
      if (mounted) {
        LoadingDialog.hide(context);
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: l10n.schoolInfo),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _isLoading
                      ? _buildLoadingState(screenSize)
                      : _buildContent(context, l10n, screenSize),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
          const CircularProgressIndicator(),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Cargando información de la escuela...',
            style: AppTheme.getBodyLarge(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    if (_school == null) {
      return _buildErrorState(l10n, screenSize);
    }

    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Header
          SchoolHeaderCard(
            schoolName: _school!.nombre,
            subtitle: l10n.educationalExcellenceInstitution,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Quick stats
          QuickStatsSection(screenSize: screenSize, stats: [
            {
              'title': _getEducationalLevel(_school!.nivelesEducativos, l10n),
              'subtitle': l10n.educationalLevel,
              'icon': Icons.school_rounded,
              'color': AppTheme.successColor,
            },
            {
              'title': _getSchoolType(_school!.tipo, l10n),
              'subtitle': l10n.institution,
              'icon': Icons.public_rounded,
              'color': AppTheme.warningColor,
            },
          ]),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Basic info
          InfoSection(
            title: l10n.basicInformation,
            icon: Icons.school_rounded,
            color: AppTheme.accentBlue,
            screenSize: screenSize,
            children: [
              InfoRow(
                label: l10n.schoolCode,
                value: (_school!.codigo ?? '').isNotEmpty
                    ? (_school!.codigo ?? '')
                    : l10n.notAvailable,
                icon: Icons.tag_rounded,
                screenSize: screenSize,
              ),
              InfoRow(
                label: l10n.schoolType,
                value: _getSchoolType(_school!.tipo, l10n),
                icon: Icons.business_rounded,
                screenSize: screenSize,
              ),
              EducationLevelChips(
                levels: _getEducationalLevels(_school!.nivelesEducativos, l10n),
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Contact info
          InfoSection(
            title: l10n.contactInfo,
            icon: Icons.contact_phone_rounded,
            color: AppTheme.successColor,
            screenSize: screenSize,
            children: [
              ContactCard(
                label: l10n.address,
                value: _school!.direccion.isNotEmpty
                    ? _school!.direccion
                    : l10n.notAvailable,
                icon: Icons.location_on_rounded,
                screenSize: screenSize,
                isClickable: _school!.direccion.isNotEmpty,
              ),
              ContactCard(
                label: l10n.phone,
                value: _school!.telefono.isNotEmpty
                    ? _school!.telefono
                    : l10n.notAvailable,
                icon: Icons.phone_rounded,
                screenSize: screenSize,
                isClickable: _school!.telefono.isNotEmpty,
              ),
              ContactCard(
                label: l10n.email,
                value: _school!.email.isNotEmpty
                    ? _school!.email
                    : l10n.notAvailable,
                icon: Icons.email_rounded,
                screenSize: screenSize,
                isClickable: _school!.email.isNotEmpty,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Description
          DescriptionSection(
            description: (_school!.descripcion ?? '').isNotEmpty
                ? _school!.descripcion!
                : l10n.schoolDescription,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        children: [
          SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Error al cargar la información de la escuela',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Por favor, intenta de nuevo más tarde.',
            style: AppTheme.getBodyLarge(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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

  String _getEducationalLevel(
      List<NivelEducativo>? niveles, AppLocalizations l10n) {
    if (niveles == null || niveles.isEmpty) return l10n.primary;
    switch (niveles.first) {
      case NivelEducativo.preescolar:
        return l10n.preschool;
      case NivelEducativo.primaria:
        return l10n.primary;
      case NivelEducativo.secundaria:
        return l10n.secondary;
      case NivelEducativo.bachillerato:
        return l10n.highSchool;
    }
  }

  List<String> _getEducationalLevels(
      List<NivelEducativo>? niveles, AppLocalizations l10n) {
    if (niveles == null || niveles.isEmpty) return [l10n.primary];
    return niveles.map((n) {
      switch (n) {
        case NivelEducativo.preescolar:
          return l10n.preschool;
        case NivelEducativo.primaria:
          return l10n.primary;
        case NivelEducativo.secundaria:
          return l10n.secondary;
        case NivelEducativo.bachillerato:
          return l10n.highSchool;
      }
    }).toList();
  }
}
