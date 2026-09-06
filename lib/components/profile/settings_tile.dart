import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Size screenSize;
  final Widget? trailing;

  /// Para redondear esquinas solo si es el primero/último dentro de la card
  final bool isFirst;
  final bool isLast;

  /// Estado deshabilitado opcional
  final bool enabled;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.screenSize,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final r = AppTheme.getMediumRadius(screenSize);
    final tileRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? r : 0),
      topRight: Radius.circular(isFirst ? r : 0),
      bottomLeft: Radius.circular(isLast ? r : 0),
      bottomRight: Radius.circular(isLast ? r : 0),
    );

    final textColor = enabled
        ? AppTheme.getTextPrimaryColor(context)
        // ignore: deprecated_member_use
        : AppTheme.getTextSecondaryColor(context).withOpacity(0.6);

    final secondaryColor = enabled
        ? AppTheme.getTextSecondaryColor(context)
        // ignore: deprecated_member_use
        : AppTheme.getTextSecondaryColor(context).withOpacity(0.6);

    return Semantics(
      button: true,
      label: title, // accesibilidad
      child: Ink(
        decoration: BoxDecoration(borderRadius: tileRadius),
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.mediumImpact();
                  onTap();
                }
              : null,
          borderRadius: tileRadius,
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  Container(
                    width: screenSize.width * 0.1,
                    height: screenSize.width * 0.1,
                    child: Icon(
                      icon,
                      color: AppTheme.accentPurple,
                      size: screenSize.width * 0.05,
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: secondaryColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing ??
                      Icon(
                        Icons.arrow_forward_ios,
                        size: screenSize.width * 0.04,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
