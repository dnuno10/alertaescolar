import 'package:alertaescolar/components/nav_header.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

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
                      _buildSectionTitle(context, l10n.contactData, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final user = userProvider.currentUser;
                          return _buildContactCard(
                              context,
                              [
                                _buildContactTile(
                                  context: context,
                                  icon: Icons.email_outlined,
                                  title: l10n.email,
                                  subtitle: l10n.primaryEmailAddress,
                                  value: user?.email ?? l10n.notRegistered,
                                  isVerified: true,
                                  l10n: l10n,
                                  screenSize: screenSize,
                                ),
                              ],
                              screenSize);
                        },
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Security Info Section
                      _buildSectionTitle(
                          context, l10n.securityInformation, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildSecurityCard(
                          context,
                          [
                            _buildSecurityTile(
                              context: context,
                              icon: Icons.verified_user_outlined,
                              title: l10n.accountStatus,
                              value: l10n.verified,
                              color: AppTheme.successColor,
                              screenSize: screenSize,
                            ),
                            _buildDivider(context, screenSize),
                            _buildSecurityTile(
                              context: context,
                              icon: Icons.schedule_outlined,
                              title: l10n.lastAccess,
                              value: l10n.todayAtTime,
                              color: AppTheme.getTextSecondaryColor(context),
                              screenSize: screenSize,
                            ),
                            _buildDivider(context, screenSize),
                            _buildSecurityTile(
                              context: context,
                              icon: Icons.security_outlined,
                              title: l10n.authentication,
                              value: l10n.enabled,
                              color: AppTheme.infoColor,
                              screenSize: screenSize,
                            ),
                          ],
                          screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Info Notice
                      _buildInfoNotice(context, l10n, screenSize),
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

  Widget _buildSectionTitle(
      BuildContext context, String title, Size screenSize) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context, List<Widget> children, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSecurityCard(
      BuildContext context, List<Widget> children, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildContactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required bool isVerified,
    required AppLocalizations l10n,
    required Size screenSize,
  }) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.06,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    if (isVerified) ...[
                      SizedBox(width: screenSize.width * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.02,
                          vertical: screenSize.height * 0.002,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: screenSize.width * 0.03,
                              color: AppTheme.successColor,
                            ),
                            SizedBox(width: screenSize.width * 0.01),
                            Text(
                              l10n.verified,
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  value,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Size screenSize,
  }) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.1,
            height: screenSize.width * 0.1,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: color,
              size: screenSize.width * 0.05,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNotice(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  l10n.importantInformation,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            l10n.contactAdminModifyInfo,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (context) => ElevatedButton.icon(
                onPressed: () {
                  // Handle contact admin action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.functionInDevelopment,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.onPrimaryColor,
                        ),
                      ),
                      backgroundColor: AppTheme.accentPurple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.contact_support_outlined,
                  size: screenSize.width * 0.045,
                  color: AppTheme.onPrimaryColor,
                ),
                label: Text(
                  l10n.contactAdmin,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onPrimaryColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: AppTheme.onPrimaryColor,
                  padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(screenSize)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, Size screenSize) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize)),
      color: AppTheme.getDividerColor(context),
    );
  }
}
