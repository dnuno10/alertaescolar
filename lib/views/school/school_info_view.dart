import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

class SchoolInfoView extends StatefulWidget {
  const SchoolInfoView({super.key});

  @override
  State<SchoolInfoView> createState() => _SchoolInfoViewState();
}

class _SchoolInfoViewState extends State<SchoolInfoView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
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
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Column(
                      children: [
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        // Modern School Header Card
                        _buildModernSchoolHeaderCard(screenSize, context),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Quick Stats Section
                        _buildQuickStatsSection(screenSize, context),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Basic Information Section
                        _buildModernInfoSection(
                          title: 'Información Básica',
                          icon: Icons.school_rounded,
                          color: AppTheme.accentBlue,
                          screenSize: screenSize,
                          context: context,
                          children: [
                            _buildModernInfoRow('Código de Escuela', 'ESC001',
                                Icons.tag_rounded, screenSize, context),
                            _buildModernInfoRow(
                                'Director/a',
                                'Lic. María Elena González Pérez',
                                Icons.person_rounded,
                                screenSize,
                                context),
                            _buildModernInfoRow(
                                'Año de Fundación',
                                '1985',
                                Icons.calendar_today_rounded,
                                screenSize,
                                context),
                            _buildModernInfoRow('Tipo de Escuela', 'Pública',
                                Icons.business_rounded, screenSize, context),
                            _buildLevelChips(screenSize, context),
                          ],
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Contact Information Section
                        _buildModernInfoSection(
                          title: 'Información de Contacto',
                          icon: Icons.contact_phone_rounded,
                          color: AppTheme.successColor,
                          screenSize: screenSize,
                          context: context,
                          children: [
                            _buildContactCard(
                                'Dirección',
                                'Av. Reforma #123, Col. Centro, Ciudad de México',
                                Icons.location_on_rounded,
                                screenSize,
                                context,
                                isClickable: true),
                            _buildContactCard('Teléfono', '+52 55 1234 5678',
                                Icons.phone_rounded, screenSize, context,
                                isClickable: true),
                            _buildContactCard(
                                'Correo Electrónico',
                                'contacto@escuela-benitojuarez.edu.mx',
                                Icons.email_rounded,
                                screenSize,
                                context,
                                isClickable: true),
                            _buildContactCard(
                                'Sitio Web',
                                'www.escuela-benitojuarez.edu.mx',
                                Icons.language_rounded,
                                screenSize,
                                context,
                                isClickable: true),
                          ],
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Description Section
                        _buildModernDescriptionSection(screenSize, context),

                        SizedBox(
                            height: AppTheme.getLargePadding(screenSize) * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernSchoolHeaderCard(Size screenSize, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, screenSize.height * 0.01),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with modern styling
          Container(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              border: Border.all(
                color: AppTheme.accentPurple.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.school_rounded,
              size: screenSize.height * 0.06,
              color: AppTheme.accentPurple,
            ),
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Title with enhanced typography
          Text(
            'Escuela Primaria Benito Juárez',
            style: AppTheme.getH1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Subtitle with modern badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getMediumPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              border: Border.all(
                color: AppTheme.accentBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              'Institución Educativa de Excelencia',
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(Size screenSize, BuildContext context) {
    final stats = [
      {
        'title': '39 años',
        'subtitle': 'de experiencia',
        'icon': Icons.timeline_rounded,
        'color': AppTheme.accentBlue
      },
      {
        'title': 'Primaria',
        'subtitle': 'nivel educativo',
        'icon': Icons.school_rounded,
        'color': AppTheme.successColor
      },
      {
        'title': 'Pública',
        'subtitle': 'institución',
        'icon': Icons.public_rounded,
        'color': AppTheme.warningColor
      },
    ];

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getSmallPadding(screenSize),
                horizontal: AppTheme.getSmallPadding(screenSize) * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.7),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: screenSize.height * 0.02,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    stat['title'] as String,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    stat['subtitle'] as String,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required Size screenSize,
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
                topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
              border: Border(
                bottom: BorderSide(
                  color: color.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  title,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon,
      Size screenSize, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.getMediumPadding(screenSize)),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.7),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              size: screenSize.height * 0.02,
              color: AppTheme.accentPurple,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.003),
                Text(
                  value,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelChips(Size screenSize, BuildContext context) {
    final levels = ['Primaria'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.7),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: screenSize.height * 0.02,
                  color: AppTheme.accentPurple,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Text(
                'Niveles Educativos',
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Wrap(
            spacing: AppTheme.getSmallPadding(screenSize),
            children: levels.map((level) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(screenSize)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  level,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String label, String value, IconData icon,
      Size screenSize, BuildContext context,
      {bool isClickable = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.getMediumPadding(screenSize)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isClickable ? () => _handleContactTap(label, value) : null,
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.7),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    icon,
                    size: screenSize.height * 0.02,
                    color: AppTheme.successColor,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.003),
                      Text(
                        value,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isClickable)
                  Icon(
                    Icons.open_in_new_rounded,
                    size: screenSize.height * 0.018,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDescriptionSection(Size screenSize, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
                topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: AppTheme.warningColor,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Text(
                  'Acerca de la Escuela',
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Text(
              'Institución educativa comprometida con la excelencia académica y el desarrollo integral de nuestros estudiantes desde hace más de 50 años. Nuestra misión es formar ciudadanos responsables y competentes para enfrentar los desafíos del futuro.',
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  void _handleContactTap(String type, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Abrir $type: $value',
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
  }
}
