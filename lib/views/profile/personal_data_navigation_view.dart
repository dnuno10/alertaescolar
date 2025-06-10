import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/user_provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_selection_dialog.dart';
import '../../widgets/theme_selection_dialog.dart';

class PersonalDataNavigationView extends StatelessWidget {
  const PersonalDataNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // Modern Sticky Header
          _buildStickyHeader(context, l10n, screenSize),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Data Section
                  _buildSectionTitle(l10n.personalData, context, screenSize),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  _buildNavigationCard([
                    _buildNavigationTile(
                      context,
                      l10n.personalInformation,
                      l10n.managePersonalDetails,
                      Icons.person_outline,
                      '/profile/personal-information',
                      screenSize,
                    ),
                    _buildDivider(context),
                    _buildNavigationTile(
                      context,
                      l10n.contactInformation,
                      l10n.viewContactData,
                      Icons.contact_mail_outlined,
                      '/profile/contact-information',
                      screenSize,
                    ),
                  ], context, screenSize),

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Account Information Section
                  _buildSectionTitle(
                      l10n.accountInformation, context, screenSize),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return _buildInfoCard([
                        _buildInfoTile(
                          label: l10n.userType,
                          value: _formatUserType(
                            userProvider.currentUser?.tipo.name ?? 'unknown',
                            l10n,
                          ),
                          context: context,
                          screenSize: screenSize,
                        ),
                        _buildDivider(context),
                        _buildInfoTile(
                          label: l10n.registrationDate,
                          value: _formatDate(
                              userProvider.currentUser?.fechaRegistro),
                          context: context,
                          screenSize: screenSize,
                        ),
                        _buildDivider(context),
                        _buildInfoTile(
                          label: l10n.lastLogin,
                          value: _formatDate(
                              userProvider.currentUser?.fechaRegistro),
                          context: context,
                          screenSize: screenSize,
                        ),
                      ], context, screenSize);
                    },
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize)),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: screenSize.width * 0.1,
                        height: screenSize.width * 0.1,
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.accentPurple,
                            size: screenSize.width * 0.05,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Expanded(
                        child: Text(
                          l10n.personalData,
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, BuildContext context, Size screenSize) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildNavigationCard(
      List<Widget> children, BuildContext context, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
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

  Widget _buildInfoCard(
      List<Widget> children, BuildContext context, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
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

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    Size screenSize,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Row(
            children: [
              Container(
                width: screenSize.width * 0.1,
                height: screenSize.width * 0.1,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentPurple,
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
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: screenSize.width * 0.04,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required BuildContext context,
    required Size screenSize,
  }) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
              vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(screenSize) * 0.5),
            ),
            child: Text(
              value,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.getBorderColor(context),
      indent: AppTheme.paddingMedium,
      endIndent: AppTheme.paddingMedium,
    );
  }

  String _formatUserType(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'admin':
        return l10n.administrator;
      case 'teacher':
        return l10n.teacher;
      case 'parent':
        return l10n.parent;
      case 'student':
        return l10n.student;
      default:
        return l10n.user;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
