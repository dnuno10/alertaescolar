import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ColorPickerBottomSheet extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerBottomSheet({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    final colors = [
      AppTheme.accentBlue,
      AppTheme.accentPurple,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.green,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectColor,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];
                  return GestureDetector(
                    onTap: () {
                      onColorSelected(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                        border: currentColor == color
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, Color currentColor,
      ValueChanged<Color> onColorSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ColorPickerBottomSheet(
        currentColor: currentColor,
        onColorSelected: onColorSelected,
      ),
    );
  }
}
