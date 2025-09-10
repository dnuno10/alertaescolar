import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class QuickActionsSection extends StatelessWidget {
  final Size screenSize;
  final void Function(int) onActionSelected;

  const QuickActionsSection({
    super.key,
    required this.screenSize,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final padX = AppTheme.getLargePadding(screenSize);
    final padY = AppTheme.getMediumPadding(screenSize);
    final gap = AppTheme.getSmallPadding(screenSize);
    final radius = AppTheme.getLargeRadius(screenSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: AppTheme.getH2(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        _QuickActionTile(
          screenSize: screenSize,
          title: l10n.viewHistory,
          leadingIcon: Icons.history_rounded,
          accentColor: AppTheme.accentBlue,
          onTap: () => onActionSelected(2),
          paddingX: padX,
          paddingY: padY,
          gap: gap,
          radius: radius,
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        _QuickActionTile(
          screenSize: screenSize,
          title: l10n.addStudent,
          leadingIcon: Icons.person_add_rounded,
          accentColor: AppTheme.successColor,
          onTap: () => onActionSelected(1),
          paddingX: padX,
          paddingY: padY,
          gap: gap,
          radius: radius,
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        _QuickActionTile(
          screenSize: screenSize,
          title: l10n.myProfile,
          leadingIcon: Icons.account_circle_rounded,
          accentColor: AppTheme.accentPurple,
          onTap: () => onActionSelected(3),
          paddingX: padX,
          paddingY: padY,
          gap: gap,
          radius: radius,
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final Size screenSize;
  final String title;
  final IconData leadingIcon;
  final Color accentColor;
  final VoidCallback onTap;

  final double paddingX;
  final double paddingY;
  final double gap;
  final double radius;

  const _QuickActionTile({
    required this.screenSize,
    required this.title,
    required this.leadingIcon,
    required this.accentColor,
    required this.onTap,
    required this.paddingX,
    required this.paddingY,
    required this.gap,
    required this.radius,
  });

  double _tileHeight(Size s) {
    // Alto uniforme responsivo (tipo celda Apple), con límites sanos
    final h = (s.height * 0.072).clamp(48.0, 72.0);
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final tileHeight = _tileHeight(screenSize);
    final iconSize = tileHeight * 0.46; // icono proporcional
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.getTextPrimaryColor(context),
        );

    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: tileHeight,
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.015),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(screenSize.width * 0.04),
            border: Border.all(
              // ignore: deprecated_member_use
              color: AppTheme.getDividerColor(context).withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon capsule (sin sombras, color sutil)
              Container(
                width: tileHeight * 0.8,
                height: tileHeight * 0.8,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(screenSize.width * 0.04),
                ),
                alignment: Alignment.center,
                child: Icon(
                  leadingIcon,
                  size: iconSize,
                  color: accentColor,
                ),
              ),
              SizedBox(width: gap + paddingY * 0.1),

              // Título (una sola línea)
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),

              // Chevron sutil
              Icon(
                Icons.chevron_right_rounded,
                size: iconSize,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
