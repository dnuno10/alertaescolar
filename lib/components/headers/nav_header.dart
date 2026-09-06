import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NavHeader extends StatelessWidget {
  final String title;
  final bool isSliverAppBar;

  const NavHeader({
    super.key,
    required this.title,
    this.isSliverAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final radius = AppTheme.getLargeRadius(screenSize);
    final borderW = screenSize.width * 0.0025;

    if (isSliverAppBar) {
      // 🔹 Versión SliverAppBar idéntica al original
      return SliverAppBar(
        floating: false,
        pinned: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        toolbarHeight: (screenSize.width * 0.2).clamp(56.0, 96.0),
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              boxShadow: const [],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
              ),
              child: SafeArea(
                child: Center(
                  child: _buildRow(context, screenSize),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // 🔹 Versión fija con banner + bordes redondeados
      return SliverToBoxAdapter(
        child: Column(
          children: [
            // Banner de deslizar
            SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize),
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
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
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
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Header fijo con bordes redondeados y margen
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppTheme.getLargePadding(screenSize) * 0.5,
                vertical: AppTheme.getSmallPadding(screenSize) * 0.6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: AppTheme.getDividerColor(context),
                  width: borderW,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize),
                ),
                child: _buildRow(context, screenSize),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRow(BuildContext context, Size screenSize) {
    return Row(
      children: [
        Semantics(
          label: 'Regresar',
          button: true,
          child: Container(
            width: screenSize.width * 0.1,
            height: screenSize.width * 0.1,
            child: IconButton(
              tooltip: 'Regresar',
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.05,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.maybePop(context);
              },
            ),
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.getH2(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
