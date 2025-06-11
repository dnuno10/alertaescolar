import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/user_provider.dart';

class AdminHeader extends StatelessWidget {
  final Size screenSize;

  const AdminHeader({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SliverAppBar(
      expandedHeight: screenSize.height * 0.25,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.getBackgroundColor(context),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentPurple,
                AppTheme.accentPurple.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.currentUser;
                  final timeOfDay = DateTime.now().hour;
                  String greeting;

                  if (timeOfDay < 12) {
                    greeting = l10n.goodMorning;
                  } else if (timeOfDay < 18) {
                    greeting = l10n.goodAfternoon;
                  } else {
                    greeting = l10n.goodEvening;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        greeting,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        user?.nombreCompleto ?? l10n.administrator,
                        style: AppTheme.getH1(screenSize).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getSmallPadding(screenSize),
                          vertical: screenSize.height * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Text(
                          l10n.adminDashboard,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
