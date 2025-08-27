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

    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.getCardColor(context),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                final firstName = user?.nombre.split(' ').first ?? l10n.user;

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeBack,
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                          SizedBox(
                            height: AppTheme.getSmallPadding(screenSize) * 0.5,
                          ),
                          Text(
                            firstName,
                            style: AppTheme.getH1(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenSize.height * 0.06,
                      height: screenSize.height * 0.06,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple,
                        borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(screenSize),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentPurple.withOpacity(0.2),
                            blurRadius: screenSize.height * 0.01,
                            offset: Offset(0, screenSize.height * 0.005),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          firstName[0].toUpperCase(),
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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
