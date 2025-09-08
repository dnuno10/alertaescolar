// action_button.dart
import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Size screenSize;

  const ActionButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.screenSize,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);
    final padM = AppTheme.getMediumPadding(screenSize);
    final radiusM = AppTheme.getMediumRadius(screenSize);

    // Botón cápsula sin sombras, con borde y relleno muy sutil
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(radiusM),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // ❌ Sin splash agresivo; mantén el estilo sobrio
          onTap: onTap,
          borderRadius: BorderRadius.circular(radiusM),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padM,
              vertical: padS * 0.9,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: screenSize.shortestSide * 0.055,
                ),
                if (label != null && label!.trim().isNotEmpty) ...[
                  SizedBox(width: padS),
                  Flexible(
                    child: Text(
                      label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: color,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
