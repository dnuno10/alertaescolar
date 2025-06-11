import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../components/headers/nav_header.dart';
import '../../components/admin/school_info_form.dart';
import '../../components/admin/school_branding_settings.dart';
import '../../components/admin/school_contact_settings.dart';

class SchoolSettingsView extends StatelessWidget {
  const SchoolSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.schoolSettings),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // School Information
                      SchoolInfoForm(screenSize: screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Contact Settings
                      SchoolContactSettings(screenSize: screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Branding Settings
                      SchoolBrandingSettings(screenSize: screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
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
}
