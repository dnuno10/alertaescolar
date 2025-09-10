import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final IconData icon;
  final Size screenSize;

  const StatusCard({
    super.key,
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final padXS = AppTheme.getSmallPadding(screenSize) * 0.7;
    final padS = AppTheme.getSmallPadding(screenSize);
    final radL = AppTheme.getLargeRadius(screenSize);

    return Semantics(
      label: '$title: $time',
      child: Container(
        width: double.infinity, // <- ocupa todo el ancho disponible
        padding: EdgeInsets.all(padS),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              screenSize.height * 0.02), // “curva” más marcada
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.28), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícono en “pill” sutil (sin sombra)
            Container(
              padding: EdgeInsets.all(padXS),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(radL),
                // ignore: deprecated_member_use
                border: Border.all(color: color.withOpacity(0.25), width: 1),
              ),
              child: Icon(
                icon,
                color: color,
                size: screenSize.height * 0.022,
              ),
            ),
            SizedBox(width: padS),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getSubtitle2(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: padXS * 0.7),
                  // Hora (monoespaciada para alineación limpia)
                  Text(
                    time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
