import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class RecipientOption extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String description;
  final Size screenSize;
  final String selectedRecipient;
  final Function(String) onSelect;

  /// NUEVO: si está en false, se ve atenuado y no es clickable
  final bool enabled;

  const RecipientOption({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.description,
    required this.screenSize,
    required this.selectedRecipient,
    required this.onSelect,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedRecipient == value;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.accentOrange.withOpacity(0.1)
            : AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: isSelected
              ? AppTheme.accentOrange
              : AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentOrange.withOpacity(0.2)
                  : AppTheme.getBorderColor(context).withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? AppTheme.accentOrange
                  : AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.022,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),

          // textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: isSelected
                        ? AppTheme.accentOrange
                        : AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  enabled ? description : 'No disponible',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: enabled
                        ? AppTheme.getTextSecondaryColor(context)
                        : AppTheme.getTextSecondaryColor(context)
                            .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          if (isSelected)
            Padding(
              padding:
                  EdgeInsets.only(left: AppTheme.getSmallPadding(screenSize)),
              child: Icon(Icons.check_circle_rounded,
                  color: AppTheme.accentOrange,
                  size: screenSize.height * 0.025),
            ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      selected: isSelected,
      label: title,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: IgnorePointer(
          ignoring: !enabled,
          child: GestureDetector(
            onTap: () => onSelect(value),
            child: card,
          ),
        ),
      ),
    );
  }
}
