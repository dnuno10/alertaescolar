import 'package:alertaescolar/components/headers/nav_header.dart';
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
                        SchoolHeaderCard(
                          schoolName: l10n.schoolName,
                          subtitle: l10n.educationalExcellenceInstitution,
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Quick Stats Section
                        QuickStatsSection(screenSize: screenSize, stats: [
                          {
                            'title': l10n.yearsExperience(39),
                            'subtitle': l10n.experienceLabel,
                            'icon': Icons.timeline_rounded,
                            'color': AppTheme.accentBlue
                          },
                          {
                            'title': l10n.primary,
                            'subtitle': l10n.educationalLevel,
                            'icon': Icons.school_rounded,
                            'color': AppTheme.successColor
                          },
                          {
                            'title': l10n.public,
                            'subtitle': l10n.institution,
                            'icon': Icons.public_rounded,
                            'color': AppTheme.warningColor
                          },
                        ]),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Basic Information Section
                        InfoSection(
                          title: l10n.basicInformation,
                          icon: Icons.school_rounded,
                          color: AppTheme.accentBlue,
                          screenSize: screenSize,
                          children: [
                            InfoRow(
                              label: l10n.schoolCode,
                              value: 'ESC001',
                              icon: Icons.tag_rounded,
                              screenSize: screenSize,
                            ),
                            InfoRow(
                              label: l10n.principal,
                              value: 'Lic. María Elena González Pérez',
                              icon: Icons.person_rounded,
                              screenSize: screenSize,
                            ),
                            InfoRow(
                              label: l10n.foundedYear,
                              value: '1985',
                              icon: Icons.calendar_today_rounded,
                              screenSize: screenSize,
                            ),
                            InfoRow(
                              label: l10n.schoolType,
                              value: l10n.public,
                              icon: Icons.business_rounded,
                              screenSize: screenSize,
                            ),
                            EducationLevelChips(
                              levels: [l10n.primary],
                              screenSize: screenSize,
                            ),
                          ],
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Contact Information Section
                        InfoSection(
                          title: l10n.contactInfo,
                          icon: Icons.contact_phone_rounded,
                          color: AppTheme.successColor,
                          screenSize: screenSize,
                          children: [
                            ContactCard(
                              label: l10n.address,
                              value:
                                  'Av. Reforma #123, Col. Centro, Ciudad de México',
                              icon: Icons.location_on_rounded,
                              screenSize: screenSize,
                              isClickable: true,
                            ),
                            ContactCard(
                              label: l10n.phone,
                              value: '+52 55 1234 5678',
                              icon: Icons.phone_rounded,
                              screenSize: screenSize,
                              isClickable: true,
                            ),
                            ContactCard(
                              label: l10n.email,
                              value: 'contacto@escuela-benitojuarez.edu.mx',
                              icon: Icons.email_rounded,
                              screenSize: screenSize,
                              isClickable: true,
                            ),
                            ContactCard(
                              label: l10n.website,
                              value: 'www.escuela-benitojuarez.edu.mx',
                              icon: Icons.language_rounded,
                              screenSize: screenSize,
                              isClickable: true,
                            ),
                          ],
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Description Section
                        DescriptionSection(
                          description: l10n.schoolDescription,
                          screenSize: screenSize,
                        ),

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
}
