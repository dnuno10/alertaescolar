import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/modern_dropdown.dart';

class EducationLevelGroupSelector extends StatelessWidget {
  final String? selectedNivelEducativo;
  final String? selectedGrupo;
  final List<String> nivelesEducativos;
  final List<String> grupos;
  final ValueChanged<String?> onNivelEducativoChanged;
  final ValueChanged<String?> onGrupoChanged;
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

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.getBorderColor(context).withOpacity(0.1),
        ),
      ),
      child: Column(
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
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Text(
                  formattedDate,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Modern Dropdowns Row
          Row(
            children: [
              // Education Level Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.grade_rounded,
                          size: screenSize.height * 0.022,
                          color: AppTheme.accentBlue,
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Text(
                          'Nivel Educativo',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    nivelesEducativos.isEmpty
                        ? _buildNoDataContainer(
                            'No hay niveles disponibles',
                            screenSize,
                            context,
                          )
                        : ModernDropdown<String>(
                            value: selectedNivelEducativo ??
                                nivelesEducativos.first,
                            items: nivelesEducativos,
                            onChanged: (String? value) {
                              HapticFeedback.mediumImpact();
                              onNivelEducativoChanged(value);
                            },
                            getLabel: (String value) => value,
                            screenSize: screenSize,
                            backgroundColor:
                                AppTheme.accentBlue.withOpacity(0.05),
                          ),
                  ],
                ),
              ),

              SizedBox(width: AppTheme.getMediumPadding(screenSize)),

              // Group Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: screenSize.height * 0.022,
                          color: AppTheme.accentPurple,
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Text(
                          l10n.group,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    grupos.isEmpty
                        ? _buildNoDataContainer(
                            selectedNivelEducativo != null
                                ? 'No hay grupos disponibles'
                                : 'Selecciona un nivel primero',
                            screenSize,
                            context,
                          )
                        : ModernDropdown<String>(
                            value: selectedGrupo ??
                                (grupos.isNotEmpty ? grupos.first : ''),
                            items: grupos,
                            onChanged: selectedNivelEducativo != null
                                ? (String? value) {
                                    HapticFeedback.mediumImpact();
                                    onGrupoChanged(value);
                                  }
                                : (String?
                                    value) {}, // Empty function when disabled
                            getLabel: (String value) => value,
                            screenSize: screenSize,
                            backgroundColor:
                                AppTheme.accentPurple.withOpacity(0.05),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataContainer(
      String message, Size screenSize, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize),
      ),
      decoration: BoxDecoration(
        color: AppTheme.getTextSecondaryColor(context).withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getTextSecondaryColor(context).withOpacity(0.1),
        ),
      ),
      child: Text(
        message,
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
