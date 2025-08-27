import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ToleranceSliderControl extends StatelessWidget {
  final int tolerance;
  final Function(int) onToleranceChanged;
  final Size screenSize;

  const ToleranceSliderControl({
    super.key,
    required this.tolerance,
    required this.onToleranceChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adjustTolerance,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Time markers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeMarker('0', 0 == tolerance, screenSize, context),
              _buildTimeMarker('15', 15 == tolerance, screenSize, context),
              _buildTimeMarker('30', 30 == tolerance, screenSize, context),
              _buildTimeMarker('45', 45 == tolerance, screenSize, context),
              _buildTimeMarker('60', 60 == tolerance, screenSize, context),
            ],
          ),

          // Enhanced Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.warningColor,
              inactiveTrackColor: AppTheme.warningColor.withOpacity(0.2),
              thumbColor: AppTheme.warningColor,
              overlayColor: AppTheme.warningColor.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              trackHeight: 8,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: AppTheme.warningColor,
              valueIndicatorTextStyle:
                  AppTheme.getCaptionSmall(screenSize).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              //showValueIndicator: ShowValueIndicator.onDrag,
            ),
            child: Slider(
              value: tolerance.toDouble(),
              min: 0,
              max: 60,
              divisions: 12,
              label: '$tolerance ${l10n.min}',
              onChanged: (value) {
                HapticFeedback.mediumImpact();
                onToleranceChanged(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMarker(
      String value, bool isActive, Size screenSize, BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.warningColor
                : AppTheme.warningColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
        Text(
          '$value ${AppLocalizations.of(context).min}',
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: isActive
                ? AppTheme.warningColor
                : AppTheme.getTextSecondaryColor(context),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: screenSize.height * 0.012,
          ),
        ),
      ],
    );
  }
}
