import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';

class ClassCard extends StatelessWidget {
  final ClaseHorario clase;
  final int index;
  final Size screenSize;

  const ClassCard({
    super.key,
    required this.clase,
    required this.index,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final materia = clase.materia;
    if (materia == null) return const SizedBox.shrink();

    final Color cardColor = _getColorFromHex(materia.color);
    final bool isReceso = materia.nombre.toLowerCase().contains('recreo');

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Column(
                      children: [
                        // Header con icono, nombre y profesor
                        Row(
                          children: [
                            Container(
                              width: screenSize.width * 0.12,
                              height: screenSize.width * 0.12,
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(screenSize)),
                              ),
                              child: Icon(
                                isReceso
                                    ? Icons.free_breakfast_outlined
                                    : _getSubjectIcon(materia.nombre),
                                color: cardColor,
                                size: screenSize.width * 0.06,
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getSmallPadding(screenSize)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    materia.nombre,
                                    style: AppTheme.getSubtitle1(screenSize)
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (materia.profesor.isNotEmpty) ...[
                                    SizedBox(height: screenSize.height * 0.003),
                                    Text(
                                      materia.profesor,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Separador
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        // Información de tiempo y lugar
                        Row(
                          children: [
                            Expanded(
                              flex: materia.aula.isNotEmpty ? 1 : 2,
                              child: _buildInfoChip(
                                icon: Icons.access_time_rounded,
                                text: clase.horarioTexto,
                                color: cardColor,
                                screenSize: screenSize,
                              ),
                            ),
                            if (materia.aula.isNotEmpty) ...[
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize) *
                                      0.5),
                              Expanded(
                                flex: 1,
                                child: _buildInfoChip(
                                  icon: Icons.location_on_outlined,
                                  text: materia.aula,
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                  screenSize: screenSize,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required Size screenSize,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: screenSize.width * 0.035,
            color: color,
          ),
          SizedBox(width: screenSize.width * 0.01),
          Text(
            text,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.accentPurple;
    }
  }

  IconData _getSubjectIcon(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('matemá')) return Icons.calculate_outlined;
    if (subjectLower.contains('español') || subjectLower.contains('lengua'))
      return Icons.menu_book_outlined;
    if (subjectLower.contains('ciencia')) return Icons.science_outlined;
    if (subjectLower.contains('historia')) return Icons.history_edu_outlined;
    if (subjectLower.contains('física') || subjectLower.contains('deporte'))
      return Icons.sports_soccer_outlined;
    if (subjectLower.contains('inglés') || subjectLower.contains('idioma'))
      return Icons.language_outlined;
    if (subjectLower.contains('arte') || subjectLower.contains('dibujo'))
      return Icons.palette_outlined;
    if (subjectLower.contains('música')) return Icons.music_note_outlined;
    if (subjectLower.contains('geografía')) return Icons.public_outlined;
    if (subjectLower.contains('química')) return Icons.biotech_outlined;
    if (subjectLower.contains('biología')) return Icons.eco_outlined;
    if (subjectLower.contains('tecnología') ||
        subjectLower.contains('informática')) return Icons.computer_outlined;
    return Icons.school_outlined;
  }
}
