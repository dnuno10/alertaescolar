import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Icono para arrastrar/actualizar
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
    final smallPad = AppTheme.getSmallPadding(screenSize);
    final avatarSide = screenSize.height * 0.065;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Banner estático para "deslizar para refrescar"
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: smallPad,
                horizontal: AppTheme.getMediumPadding(screenSize),
              ),
              color: AppTheme.getBackgroundColor(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.arrowDownCircle,
                    size: screenSize.height * 0.022,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  SizedBox(width: smallPad),
                  Text(
                    "Desliza hacia abajo para actualizar",
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: smallPad), // Espacio entre banner y header

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: outerPad * 0.5, // margen lateral
              vertical: smallPad * 0.6, // margen superior/inferior
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                innerPad * 0.5,
                innerPad,
                innerPad * 0.5,
                innerPad,
              ),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.currentUser;
                  final firstName =
                      (user?.nombre ?? l10n.user).split(' ').first;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Saludo plano
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
                            SizedBox(height: smallPad * 0.4),
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

                      // Avatar inicial sin sombra, con borde
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
                      SizedBox(width: smallPad),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
