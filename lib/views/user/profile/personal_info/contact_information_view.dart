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
import 'package:provider/provider.dart';
import '../../../../managers/user_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/app_theme.dart';

class ContactInformationView extends StatelessWidget {
  const ContactInformationView({super.key});

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

                      SecurityInfoCard(
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
                          SecurityTile(
                            icon: Icons.schedule_outlined,
                            title: l10n.lastAccess,
                            value: l10n.todayAtTime,
                            color: AppTheme.getTextSecondaryColor(context),
                            screenSize: screenSize,
                          ),
                          ContactDivider(screenSize: screenSize),
                          SecurityTile(
                            icon: Icons.security_outlined,
                            title: l10n.authentication,
                            value: l10n.enabled,
                            color: AppTheme.infoColor,
                            screenSize: screenSize,
                          ),
                        ],
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Info Notice
                      InfoNoticeCardAction(
                        l10n: l10n,
                        screenSize: screenSize,
                      ),
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
