import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';

class NavHeader extends StatelessWidget {
  final String title;
  const NavHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
                          title,
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
    ;
  }
}
