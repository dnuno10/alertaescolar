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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppTheme.getMediumPadding(screenSize),
            AppTheme.getMediumPadding(screenSize),
            AppTheme.getMediumPadding(screenSize),
            AppTheme.getLargePadding(screenSize),
          ),
          child: Consumer<UserProvider>(
            builder: (context, provider, child) {
              final user = provider.currentUser;
              final subtitle = user?.email ?? l10n.manageYourAccount;
              final isLoading = provider.isLoadingUser && user == null;
              final hasError = !provider.isLoadingUser &&
                  provider.error != null &&
                  user == null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppTheme.accentPurple,
                        size: screenSize.width * 0.08,
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Expanded(
                        child: Text(
                          l10n.myProfile,
                          style: AppTheme.getH2(screenSize).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextPrimaryColor(context),
                            letterSpacing: 0,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (user != null)
                        Flexible(
                          child: Text(
                            _getRoleText(user.tipo, l10n),
                            textAlign: TextAlign.right,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentPurple,
                              height: 1.2,
                            ),
                          ),
                        ),
                      if (isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasError ? l10n.errorLoadingData : subtitle,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            fontWeight: FontWeight.w500,
                            color: hasError
                                ? AppTheme.errorColor
                                : AppTheme.getTextSecondaryColor(context),
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (hasError)
                        TextButton(
                          onPressed: () => provider.reloadSilently(context),
                          child: Text(l10n.retry),
                        ),
                    ],
                  ),
                ],
              );
            },
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
