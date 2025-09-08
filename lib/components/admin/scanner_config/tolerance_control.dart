import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Control unificado: encabezado (display) + barra segmentada + slider + marcadores.
class ToleranceControl extends StatelessWidget {
  final int tolerance; // 0..60 (pasos de 5 por divisions=12)
  final ValueChanged<int> onChanged;
  final Size screenSize;

  /// Opcional: título encima del control (por si lo usas suelto).
  final String? title;

  const ToleranceControl({
    super.key,
    required this.tolerance,
    required this.onChanged,
    required this.screenSize,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final pad = AppTheme.getMediumPadding(screenSize);
    final radius = AppTheme.getLargeRadius(screenSize);

    // Tamaños responsivos (clamped para evitar overflow)
    final numberSize = (screenSize.shortestSide * 0.18).clamp(28.0, 56.0);
    final captionSize = (screenSize.shortestSide * 0.035).clamp(11.0, 16.0);
    final helperSize = (screenSize.shortestSide * 0.030).clamp(10.0, 14.0);

    // Segmentos (12 = 12*5min)
    final totalSegments = 12;
    final filled = ((tolerance / 5).round()).clamp(0, totalSegments);

    return Semantics(
      label: l10n.adjustTolerance,
      value: '$tolerance',
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            ],

            // “Display” integrado (número grande + textos) sobre una banda suave
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getLargePadding(screenSize),
                vertical: AppTheme.getMediumPadding(screenSize) * 0.9,
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.30),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$tolerance',
                        textAlign: TextAlign.center,
                        style: AppTheme.getH1(screenSize).copyWith(
                          fontSize: numberSize,
                          height: 1.0,
                          letterSpacing: 1.0,
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.minutes,
                            style: AppTheme.getCaption(screenSize).copyWith(
                              fontSize: captionSize,
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(
                              height:
                                  AppTheme.getSmallPadding(screenSize) * 0.25),
                          Text(
                            l10n.ofTolerance,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              fontSize: helperSize,
                              color: AppTheme.getTextSecondaryColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.getLargePadding(screenSize) * 0.8),
                  _SegmentBar(
                    total: totalSegments,
                    filled: filled,
                    screenSize: screenSize,
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.getMediumPadding(screenSize)),

            // Marcadores táctiles 0/15/30/45/60
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [0, 15, 30, 45, 60]
                  .map((v) => _Tick(value: v))
                  .toList(),
            ),

            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Slider sin sombras
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: (screenSize.shortestSide * 0.018).clamp(6.0, 10.0),
                activeTrackColor: AppTheme.warningColor,
                inactiveTrackColor: AppTheme.warningColor.withOpacity(0.18),
                thumbColor: AppTheme.warningColor,
                overlayColor: AppTheme.warningColor.withOpacity(0.10),
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius:
                      (screenSize.shortestSide * 0.040).clamp(12.0, 16.0),
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius:
                      (screenSize.shortestSide * 0.040 * 1.6).clamp(18.0, 26.0),
                ),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: AppTheme.warningColor,
                valueIndicatorTextStyle:
                    AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: Color.fromARGB(255, 1, 7, 23),
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Slider(
                value: tolerance.toDouble(),
                min: 0,
                max: 60,
                divisions: 12, // pasos de 5 minutos
                label: '$tolerance ${l10n.min}',
                onChanged: (value) {
                  HapticFeedback.mediumImpact();
                  onChanged(value.round());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final int total;
  final int filled;
  final Size screenSize;

  const _SegmentBar({
    required this.total,
    required this.filled,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final gap = AppTheme.getSmallPadding(screenSize) * 0.6;
    final height = (screenSize.shortestSide * 0.012).clamp(4.0, 8.0).toDouble();
    final radius = height / 2;

    return Row(
      children: List.generate(total, (i) {
        final active = i < filled;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.symmetric(horizontal: gap / 2),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.warningColor
                  : AppTheme.warningColor.withOpacity(0.12),
              border: Border.all(
                color: active
                    ? AppTheme.warningColor.withOpacity(0.90)
                    : AppTheme.warningColor.withOpacity(0.25),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      }),
    );
  }
}

class _Tick extends StatelessWidget {
  final int value;
  const _Tick({required this.value});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final parent = context.findAncestorWidgetOfExactType<ToleranceControl>();
    final isActive = (parent?.tolerance ?? 0) == value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (parent != null) {
          HapticFeedback.selectionClick();
          parent.onChanged(value);
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: (size.shortestSide * 0.015).clamp(6.0, 8.0),
            height: (size.shortestSide * 0.015).clamp(6.0, 8.0),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.warningColor
                  : AppTheme.warningColor.withOpacity(0.30),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(size) * 0.25),
          Text(
            '$value ${l10n.min}',
            style: AppTheme.getCaptionSmall(size).copyWith(
              color: isActive
                  ? AppTheme.warningColor
                  : AppTheme.getTextSecondaryColor(context),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: (size.height * 0.012).clamp(10.0, 13.0),
            ),
          ),
        ],
      ),
    );
  }
}
