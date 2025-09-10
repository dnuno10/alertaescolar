import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/user_provider.dart';
import '../../app/app_theme.dart';
import '../../models/usuario.dart';

class ProfileHeader extends StatelessWidget {
  final Size screenSize;

  const ProfileHeader({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppTheme.getMediumPadding(screenSize),
          AppTheme.getMediumPadding(screenSize),
          AppTheme.getMediumPadding(screenSize),
          AppTheme.getLargePadding(screenSize),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: AppTheme.accentPurple,
                    size: screenSize.width * 0.08,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.myProfile,
                          style: AppTheme.getH2(screenSize).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextPrimaryColor(context),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        Consumer<UserProvider>(
                          builder: (context, provider, child) {
                            final user = provider.currentUser;
                            final subtitle =
                                user?.email ?? l10n.manageYourAccount;
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subtitle,
                                    style: AppTheme.getBodyMedium(screenSize)
                                        .copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                if (provider.isLoadingUser && user == null)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                if (!provider.isLoadingUser &&
                                    provider.error != null &&
                                    user == null)
                                  TextButton(
                                    onPressed: () =>
                                        provider.reloadSilently(context),
                                    child: Text(l10n.retry),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              // User Info Card
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.currentUser;
                  final initials = userProvider.initials;
                  final displayName = userProvider.displayName;
                  final isLoading = userProvider.isLoadingUser;
                  final hasError = userProvider.error != null && user == null;

                  return Container(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize),
                      ),
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Profile Avatar
                        Container(
                          width: screenSize.width * 0.15,
                          height: screenSize.width * 0.15,
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple,
                            borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize),
                            ),
                          ),
                          child: Center(
                            child: (initials.isNotEmpty)
                                ? Text(
                                    initials,
                                    style: AppTheme.getH2(screenSize).copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    size: screenSize.width * 0.075,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre mostrado
                              Text(
                                displayName.isNotEmpty
                                    ? displayName
                                    : l10n.user,
                                style:
                                    AppTheme.getSubtitle1(screenSize).copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextPrimaryColor(context),
                                  height: 1.4,
                                ),
                              ),

                              // Estado/rol
                              if (isLoading && user == null) ...[
                                SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize) *
                                      0.5,
                                ),
                                Text(
                                  l10n.loadingUserData,
                                  style: AppTheme.getCaptionSmall(screenSize)
                                      .copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
                              ] else if (hasError) ...[
                                SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize) *
                                      0.5,
                                ),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Text(
                                      l10n.errorLoadingData,
                                      style:
                                          AppTheme.getCaptionSmall(screenSize)
                                              .copyWith(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          userProvider.reloadSilently(context),
                                      child: Text(l10n.retry),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize) *
                                      0.5,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        AppTheme.getSmallPadding(screenSize) *
                                            0.75,
                                    vertical:
                                        AppTheme.getSmallPadding(screenSize) *
                                            0.25,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        // ignore: deprecated_member_use
                                        AppTheme.accentPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.getSmallRadius(screenSize) * 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    _getRoleText(user?.tipo, l10n),
                                    style: AppTheme.getCaptionSmall(screenSize)
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.accentPurple,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleText(TipoUsuario? tipo, AppLocalizations l10n) {
    if (tipo == null) return l10n.parentRole;
    switch (tipo) {
      case TipoUsuario.padre:
        return l10n.fatherRole;
      case TipoUsuario.madre:
        return l10n.motherRole;
      case TipoUsuario.tutor:
        return l10n.tutorRole;
      case TipoUsuario.familiar:
        return l10n.relativeRole;
      case TipoUsuario.administrador:
        return l10n.adminRole;
    }
  }
}
