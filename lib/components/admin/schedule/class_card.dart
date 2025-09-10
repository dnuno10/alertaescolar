import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../models/models.dart';

class ClassCard extends StatelessWidget {
  final ClaseHorario clase;
  final int index;
  final Size screenSize;
  final Materia? subject;
  final bool showDay;

  const ClassCard({
    super.key,
    required this.clase,
    required this.index,
    required this.screenSize,
    this.subject,
    this.showDay = true,
  });

  @override
  Widget build(BuildContext context) {
    final String subjectName = subject?.nombre ?? 'Materia no especificada';
    final String professor = subject?.profesor ?? 'Profesor no asignado';
    final String description = '';
    final Color cardColor = _getSubjectColor(subject?.color ?? '#9B5DE5');

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin:
                  EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: cardColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(screenSize)),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con icono y datos principales
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icono de la materia
                            Container(
                              width: screenSize.width * 0.14,
                              height: screenSize.width * 0.14,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    // ignore: deprecated_member_use
                                    cardColor.withOpacity(0.8),
                                    // ignore: deprecated_member_use
                                    cardColor.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.getMediumRadius(screenSize),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: cardColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getSubjectIcon(subjectName),
                                color: Colors.white,
                                size: screenSize.width * 0.07,
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getMediumPadding(screenSize)),
                            // Detalles de la materia
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subjectName,
                                    style: AppTheme.getSubtitle1(screenSize)
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenSize.height * 0.004),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: screenSize.width * 0.04,
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                      SizedBox(width: screenSize.width * 0.01),
                                      Expanded(
                                        child: Text(
                                          professor,
                                          style:
                                              AppTheme.getBodyMedium(screenSize)
                                                  .copyWith(
                                            color:
                                                AppTheme.getTextSecondaryColor(
                                                    context),
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (description.isNotEmpty) ...[
                                    SizedBox(height: screenSize.height * 0.006),
                                    Text(
                                      description,
                                      style: AppTheme.getCaption(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                        // Horario y Aula
                        Container(
                          padding: EdgeInsets.all(
                              AppTheme.getSmallPadding(screenSize)),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: cardColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize),
                            ),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: cardColor.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Horario
                              Expanded(
                                flex: clase.aula.isNotEmpty ? 3 : 2,
                                child: _buildInfoChip(
                                  icon: Icons.schedule_rounded,
                                  label: 'Horario',
                                  text: clase.horarioLimpio,
                                  color: cardColor,
                                  screenSize: screenSize,
                                ),
                              ),
                              if (clase.aula.isNotEmpty) ...[
                                SizedBox(
                                    width:
                                        AppTheme.getSmallPadding(screenSize)),
                                // Aula
                                Expanded(
                                  flex: 2,
                                  child: _buildInfoChip(
                                    icon: Icons.room_rounded,
                                    label: 'Aula',
                                    text: clase.aula,
                                    color: AppTheme.accentBlue,
                                    screenSize: screenSize,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Días activos (si se solicita)
                        if (showDay) ...[
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.getSmallPadding(screenSize),
                              vertical:
                                  AppTheme.getSmallPadding(screenSize) * 0.5,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: AppTheme.accentPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(screenSize),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: screenSize.width * 0.035,
                                  color: AppTheme.accentPurple,
                                ),
                                SizedBox(width: screenSize.width * 0.01),
                                Text(
                                  _getActiveDaysLabel(clase),
                                  style: AppTheme.getCaptionSmall(screenSize)
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    required String label,
    required String text,
    required Color color,
    required Size screenSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: screenSize.width * 0.035, color: color),
            SizedBox(width: screenSize.width * 0.01),
            Text(
              label,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.002),
        Text(
          text,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Construye etiqueta de días activos a partir de flags bool del modelo.
  String _getActiveDaysLabel(ClaseHorario c) {
    final days = <String>[
      if (c.lunes) 'Lunes',
      if (c.martes) 'Martes',
      if (c.miercoles) 'Miércoles',
      if (c.jueves) 'Jueves',
      if (c.viernes) 'Viernes',
      if (c.sabado) 'Sábado',
      if (c.domingo) 'Domingo',
    ];
    return days.isNotEmpty ? days.join(', ') : 'Sin día asignado';
  }

  Color _getSubjectColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.accentPurple;
    }
  }

  IconData _getSubjectIcon(String subjectName) {
    final subject = subjectName.toLowerCase();

    if (subject.contains('matemáticas') ||
        subject.contains('matematicas') ||
        subject.contains('math')) {
      return Icons.calculate_rounded;
    } else if (subject.contains('español') ||
        subject.contains('lengua') ||
        subject.contains('idioma')) {
      return Icons.menu_book_rounded;
    } else if (subject.contains('ciencias') ||
        subject.contains('biología') ||
        subject.contains('biologia') ||
        subject.contains('química') ||
        subject.contains('quimica')) {
      return Icons.science_rounded;
    } else if (subject.contains('historia') || subject.contains('sociales')) {
      return Icons.history_edu_rounded;
    } else if (subject.contains('educación física') ||
        subject.contains('educacion fisica') ||
        subject.contains('deporte')) {
      return Icons.sports_soccer_rounded;
    } else if (subject.contains('arte') ||
        subject.contains('dibujo') ||
        subject.contains('música') ||
        subject.contains('musica')) {
      return Icons.palette_rounded;
    } else if (subject.contains('inglés') ||
        subject.contains('ingles') ||
        subject.contains('english')) {
      return Icons.language_rounded;
    } else if (subject.contains('informática') ||
        subject.contains('informatica') ||
        subject.contains('computación') ||
        subject.contains('computacion')) {
      return Icons.computer_rounded;
    } else if (subject.contains('geografía') || subject.contains('geografia')) {
      return Icons.public_rounded;
    } else if (subject.contains('física') || subject.contains('fisica')) {
      return Icons.science_rounded;
    } else {
      return Icons.school_rounded;
    }
  }
}
