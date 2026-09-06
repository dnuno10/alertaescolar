// lib/components/students/student_detail_row.dart
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class StudentDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Size screenSize;

  /// Si se proporciona, la fila será tocable (InkWell) con ripple.
  final VoidCallback? onTap;

  /// Si es true, renderiza el valor con SelectableText (útil para copiar matrícula).
  final bool selectableValue;

  /// Descripción personalizada para lectores de pantalla.
  /// Si no se provee, se usa "$label: $value".
  final String? semanticsValue;

  const StudentDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.screenSize,
    this.onTap,
    this.selectableValue = false,
    this.semanticsValue,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.getSmallRadius(screenSize));

    final content = Row(
      children: [
        Container(
          width: screenSize.width * 0.1,
          height: screenSize.width * 0.1,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Icon(
            icon,
            size: screenSize.width * 0.05,
            color: iconColor,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              SizedBox(height: screenSize.height * 0.005),
              selectableValue
                  ? SelectableText(
                      value,
                      style: AppTheme.getSubtitle2(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    )
                  : Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.getSubtitle2(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );

    final base = Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: radius,
      ),
      child: content,
    );

    // Accesibilidad + tap target
    final semantics = Semantics(
      button: onTap != null,
      label: semanticsValue ?? '$label: $value',
      child: base,
    );

    if (onTap == null) return semantics;

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: semantics,
    );
  }
}
