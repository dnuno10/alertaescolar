import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/app_theme.dart';

class DirectoryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSliverAppBar;

  const DirectoryHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSliverAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final radius = AppTheme.getLargeRadius(screenSize);
    final borderW = screenSize.width * 0.0025;
    final smallPad = AppTheme.getSmallPadding(screenSize);
    final outerPad = AppTheme.getLargePadding(screenSize);

    if (isSliverAppBar) {
      // 🔹 Versión SliverAppBar (igual que HomeHeader)
      return SliverToBoxAdapter(
        child: Column(
          children: [
            // Banner deslizar
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
            SizedBox(height: smallPad),

            // Header principal con bordes redondeados
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: outerPad * 0.5,
                vertical: smallPad * 0.6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: AppTheme.getDividerColor(context),
                  width: borderW,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  outerPad,
                  AppTheme.getMediumPadding(screenSize),
                  outerPad,
                  AppTheme.getLargePadding(screenSize),
                ),
                child: _buildContent(context, screenSize),
              ),
            ),
          ],
        ),
      );
    } else {
      // 🔹 Versión fija (igual visualmente, solo que no se comporta como AppBar)
      return SliverToBoxAdapter(
        child: Column(
          children: [
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
            SizedBox(height: smallPad),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: outerPad * 0.5,
                vertical: smallPad * 0.6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: AppTheme.getDividerColor(context),
                  width: borderW,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  outerPad,
                  AppTheme.getMediumPadding(screenSize),
                  outerPad,
                  AppTheme.getLargePadding(screenSize),
                ),
                child: _buildContent(context, screenSize),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.getH1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        Text(
          subtitle,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
