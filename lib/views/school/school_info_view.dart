import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

class SchoolInfoView extends StatelessWidget {
  const SchoolInfoView({super.key});

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
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // School Header Card
                      _buildSchoolHeaderCard(screenSize, context),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Basic Information
                      _buildInfoSection(
                        title: 'Información Básica',
                        icon: Icons.school_rounded,
                        color: AppTheme.accentBlue,
                        screenSize: screenSize,
                        context: context,
                        children: [
                          _buildInfoRow('Código de Escuela', 'ESC001',
                              Icons.tag_rounded, screenSize, context),
                          _buildInfoRow(
                              'Director/a',
                              'Lic. María Elena González Pérez',
                              Icons.person_rounded,
                              screenSize,
                              context),
                          _buildInfoRow(
                              'Año de Fundación',
                              '1985',
                              Icons.calendar_today_rounded,
                              screenSize,
                              context),
                          _buildInfoRow('Tipo de Escuela', 'Pública',
                              Icons.business_rounded, screenSize, context),
                          _buildInfoRow('Niveles Educativos', 'Primaria',
                              Icons.school_rounded, screenSize, context),
                        ],
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Contact Information
                      _buildInfoSection(
                        title: 'Información de Contacto',
                        icon: Icons.contact_phone_rounded,
                        color: AppTheme.successColor,
                        screenSize: screenSize,
                        context: context,
                        children: [
                          _buildInfoRow(
                              'Dirección',
                              'Av. Reforma #123, Col. Centro, Ciudad de México',
                              Icons.location_on_rounded,
                              screenSize,
                              context),
                          _buildInfoRow('Teléfono', '+52 55 1234 5678',
                              Icons.phone_rounded, screenSize, context),
                          _buildInfoRow(
                              'Correo Electrónico',
                              'contacto@escuela-benitojuarez.edu.mx',
                              Icons.email_rounded,
                              screenSize,
                              context),
                          _buildInfoRow(
                              'Sitio Web',
                              'www.escuela-benitojuarez.edu.mx',
                              Icons.language_rounded,
                              screenSize,
                              context),
                        ],
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Description Section
                      _buildDescriptionSection(screenSize, context),

                      SizedBox(
                          height: AppTheme.getLargePadding(screenSize) * 2),
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

  Widget _buildSchoolHeaderCard(Size screenSize, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentPurple, AppTheme.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withOpacity(0.3),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, screenSize.height * 0.01),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            ),
            child: Icon(
              Icons.school_rounded,
              size: screenSize.height * 0.06,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Escuela Primaria Benito Juárez',
            style: AppTheme.getH1(screenSize).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Institución Educativa de Excelencia',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required Size screenSize,
    required BuildContext context,
    required List<Widget> children,
  }) {
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
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      Size screenSize, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: screenSize.height * 0.02,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Size screenSize, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
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
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: AppTheme.warningColor,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Acerca de la Escuela',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Institución educativa comprometida con la excelencia académica y el desarrollo integral de nuestros estudiantes desde hace más de 50 años.',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
