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
    Materia? materia,
  });

  @override
  Widget build(BuildContext context) {
    final String subjectName = _getSubjectNameFromId(clase.materiaId);
    final Color cardColor = _getSubjectColor(clase.materiaId);
    final bool isReceso = subjectName.toLowerCase().contains('recreo');

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
                        // Header con icono y nombre
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
                                    : _getSubjectIcon(subjectName),
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
                                    subjectName,
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
                                  SizedBox(height: screenSize.height * 0.003),
                                  Text(
                                    _getProfessorFromId(clase.materiaId),
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
                              flex: clase.aula.isNotEmpty ? 1 : 2,
                              child: _buildInfoChip(
                                icon: Icons.access_time_rounded,
                                text: clase.horarioTexto,
                                color: cardColor,
                                screenSize: screenSize,
                              ),
                            ),
                            if (clase.aula.isNotEmpty) ...[
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize) *
                                      0.5),
                              Expanded(
                                flex: 1,
                                child: _buildInfoChip(
                                  icon: Icons.location_on_outlined,
                                  text: clase.aula,
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

  String _getSubjectNameFromId(String materiaId) {
    final Map<String, String> subjects = {
      'mat_001': 'Matemáticas',
      'mat_002': 'Español',
      'mat_003': 'Ciencias Naturales',
      'mat_004': 'Historia',
      'mat_005': 'Educación Física',
      'mat_006': 'Inglés',
      'mat_007': 'Arte',
      'mat_008': 'Recreo',
    };
    return subjects[materiaId] ?? 'Materia';
  }

  String _getProfessorFromId(String materiaId) {
    final Map<String, String> professors = {
      'mat_001': 'Prof. María González',
      'mat_002': 'Prof. Luis Rodríguez',
      'mat_003': 'Prof. Ana Martínez',
      'mat_004': 'Prof. Carlos López',
      'mat_005': 'Prof. Roberto Silva',
      'mat_006': 'Prof. Sandra Torres',
      'mat_007': 'Prof. Elena Vega',
      'mat_008': '',
    };
    return professors[materiaId] ?? 'Profesor';
  }

  Color _getSubjectColor(String materiaId) {
    final Map<String, String> colors = {
      'mat_001': '#3A86FF',
      'mat_002': '#00C896',
      'mat_003': '#9B5DE5',
      'mat_004': '#FF6B35',
      'mat_005': '#FDCB5A',
      'mat_006': '#F72585',
      'mat_007': '#4CC9F0',
      'mat_008': '#90E0EF',
    };
    return _getColorFromHex(colors[materiaId] ?? '#9B5DE5');
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
