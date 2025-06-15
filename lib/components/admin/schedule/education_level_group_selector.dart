import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class EducationLevelGroupSelector extends StatelessWidget {
  final String? selectedNivelEducativo;
  final String? selectedGrupo;
  final List<String> nivelesEducativos;
  final List<String> grupos;
  final Function(String?) onNivelEducativoChanged;
  final Function(String?) onGrupoChanged;
  final Size screenSize;

  const EducationLevelGroupSelector({
    super.key,
    required this.selectedNivelEducativo,
    required this.selectedGrupo,
    required this.nivelesEducativos,
    required this.grupos,
    required this.onNivelEducativoChanged,
    required this.onGrupoChanged,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.schedulesByGroup,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              formattedDate,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Education Level Selector
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border:
                Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.grade_rounded,
                size: screenSize.height * 0.02,
                color: AppTheme.accentBlue,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                'Nivel Educativo',
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: nivelesEducativos.isEmpty
                    ? _buildNoDataContainer(
                        'No existen niveles educativos',
                        screenSize,
                        context,
                        false, // No mostrar flecha
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedNivelEducativo,
                          hint: Text(
                            'Seleccionar nivel',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                          dropdownColor: AppTheme.getCardColor(context),
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                          isExpanded: true,
                          items: nivelesEducativos.map((String nivel) {
                            return DropdownMenuItem<String>(
                              value: nivel,
                              child: Text(nivel),
                            );
                          }).toList(),
                          onChanged: onNivelEducativoChanged,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.accentBlue,
                            size: screenSize.height * 0.018,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

        // Group Selector
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border:
                Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.school_rounded,
                size: screenSize.height * 0.02,
                color: AppTheme.accentPurple,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                l10n.group,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: grupos.isEmpty
                    ? _buildNoDataContainer(
                        selectedNivelEducativo != null
                            ? 'No existen grupos'
                            : 'Primero selecciona un nivel',
                        screenSize,
                        context,
                        false, // No mostrar flecha
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedGrupo,
                          hint: Text(
                            selectedNivelEducativo != null
                                ? 'Seleccionar grupo'
                                : 'Primero selecciona un nivel',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                          dropdownColor: AppTheme.getCardColor(context),
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                          isExpanded: true,
                          items: grupos.map((String grupo) {
                            return DropdownMenuItem<String>(
                              value: grupo,
                              child: Text(grupo),
                            );
                          }).toList(),
                          onChanged: selectedNivelEducativo != null
                              ? onGrupoChanged
                              : null,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.accentPurple,
                            size: screenSize.height * 0.018,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a container to show when there's no data available
  Widget _buildNoDataContainer(
    String message,
    Size screenSize,
    BuildContext context,
    bool showArrow,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showArrow) ...[
            SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.018,
            ),
          ],
        ],
      ),
    );
  }
}
