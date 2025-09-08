import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/user_provider.dart';

class HomeHeader extends StatelessWidget {
  final Size screenSize;

  const HomeHeader({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final outerPad = AppTheme.getLargePadding(screenSize);
    final innerPad = AppTheme.getMediumPadding(screenSize);
    final avatarSide = screenSize.height * 0.065;
    final borderW = screenSize.width * 0.0025;

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppTheme.getLargeRadius(screenSize)),
          ),
          border: Border.all(
            color: AppTheme.getDividerColor(context),
            width: borderW,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(outerPad, innerPad, outerPad, innerPad),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                final firstName = (user?.nombre ?? l10n.user).split(' ').first;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Saludo (estética plana como la referencia)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeBack,
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                              height:
                                  AppTheme.getSmallPadding(screenSize) * 0.4),
                          Text(
                            firstName,
                            style: AppTheme.getH1(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar inicial sin sombra, con aro/borde
                    Container(
                      width: avatarSide,
                      height: avatarSide,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple,
                        borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(screenSize),
                        ),
                        border: Border.all(
                          color: AppTheme.getDividerColor(context),
                          width: screenSize.width * 0.003,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : 'A',
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
