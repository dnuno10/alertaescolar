import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class SchoolBrandingSettings extends StatefulWidget {
  final Size screenSize;

  const SchoolBrandingSettings({
    super.key,
    required this.screenSize,
  });

  @override
  State<SchoolBrandingSettings> createState() => _SchoolBrandingSettingsState();
}

class _SchoolBrandingSettingsState extends State<SchoolBrandingSettings> {
  bool _isEditing = false;
  bool _isLoading = false;

  Color _primaryColor = AppTheme.accentBlue;
  Color _secondaryColor = AppTheme.accentPurple;
  Color _accentColor = AppTheme.successColor;
  String? _logoPath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: widget.screenSize.height * 0.015,
            offset: Offset(0, widget.screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                    AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: AppTheme.accentPurple,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Expanded(
                child: Text(
                  l10n.schoolBranding ?? 'Imagen corporativa',
                  style: AppTheme.getH2(widget.screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                  color: AppTheme.accentPurple,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Logo Section
          _buildSectionHeader(
            l10n.schoolLogo,
            Icons.image_rounded,
            AppTheme.warningColor,
          ),

          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),

          _LogoUploadSection(
            logoPath: _logoPath,
            onLogoChanged: (path) {
              setState(() {
                _logoPath = path;
              });
            },
            isEditing: _isEditing,
            screenSize: widget.screenSize,
            l10n: l10n,
          ),

          SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),

          // Colors Section
          _buildSectionHeader(
            l10n.schoolColors,
            Icons.color_lens_rounded,
            AppTheme.accentPurple,
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          _ColorPicker(
            label: l10n.primaryColor,
            color: _primaryColor,
            onColorChanged: (color) {
              setState(() {
                _primaryColor = color;
              });
            },
            isEditing: _isEditing,
            screenSize: widget.screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          _ColorPicker(
            label: l10n.secondaryColor,
            color: _secondaryColor,
            onColorChanged: (color) {
              setState(() {
                _secondaryColor = color;
              });
            },
            isEditing: _isEditing,
            screenSize: widget.screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          _ColorPicker(
            label: l10n.accentColor,
            color: _accentColor,
            onColorChanged: (color) {
              setState(() {
                _accentColor = color;
              });
            },
            isEditing: _isEditing,
            screenSize: widget.screenSize,
          ),

          SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),

          // Preview Section
          _PreviewCard(
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
            accentColor: _accentColor,
            screenSize: widget.screenSize,
            l10n: l10n,
          ),

          if (_isEditing) ...[
            SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),
            Row(
              children: [
                Expanded(
                  child: SolidButton(
                    backgroundColor: AppTheme.errorColor,
                    onPressed: _resetBranding,
                    label: l10n.reset ?? 'Restablecer',
                    icon: Icons.refresh_rounded,
                    screenSize: widget.screenSize,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: SolidButton(
                    backgroundColor: AppTheme.accentPurple,
                    onPressed: _isLoading ? () {} : _saveBranding,
                    label: _isLoading
                        ? (l10n.saving ?? 'Guardando...')
                        : l10n.saveChanges,
                    icon: _isLoading ? null : Icons.save_rounded,
                    screenSize: widget.screenSize,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding:
              EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize) * 0.5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize) * 0.5),
          ),
          child: Icon(
            icon,
            color: color,
            size: widget.screenSize.height * 0.02,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
        Text(
          title,
          style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _resetBranding() {
    setState(() {
      _primaryColor = AppTheme.accentBlue;
      _secondaryColor = AppTheme.accentPurple;
      _accentColor = AppTheme.successColor;
      _logoPath = null;
    });
  }

  void _saveBranding() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).settingsUpdated,
              style: AppTheme.getCaption(widget.screenSize).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _LogoUploadSection extends StatelessWidget {
  final String? logoPath;
  final ValueChanged<String?> onLogoChanged;
  final bool isEditing;
  final Size screenSize;
  final AppLocalizations l10n;

  const _LogoUploadSection({
    required this.logoPath,
    required this.onLogoChanged,
    required this.isEditing,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: isEditing
              ? AppTheme.warningColor.withOpacity(0.3)
              : AppTheme.getBorderColor(context),
          style: isEditing ? BorderStyle.none : BorderStyle.solid,
          width: isEditing ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (logoPath != null)
            Container(
              width: screenSize.height * 0.12,
              height: screenSize.height * 0.12,
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                ),
              ),
              child: Icon(
                Icons.school_rounded,
                size: screenSize.height * 0.06,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            )
          else
            Container(
              width: screenSize.height * 0.12,
              height: screenSize.height * 0.12,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.add_photo_alternate_rounded,
                size: screenSize.height * 0.04,
                color: AppTheme.warningColor,
              ),
            ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          if (isEditing)
            SolidButton(
              backgroundColor: AppTheme.warningColor,
              onPressed: () => _selectLogo(context),
              label: logoPath != null
                  ? (l10n.changeLogo ?? 'Cambiar logo')
                  : (l10n.uploadLogo ?? 'Subir logo'),
              icon: Icons.upload_rounded,
              screenSize: screenSize,
            )
          else
            Text(
              logoPath != null
                  ? (l10n.logoUploaded ?? 'Logo cargado')
                  : (l10n.noLogoUploaded ?? 'Sin logo'),
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
        ],
      ),
    );
  }

  void _selectLogo(BuildContext context) {
    // Simulate file selection
    onLogoChanged('mock_logo_path.png');
  }
}

class _ColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool isEditing;
  final Size screenSize;

  const _ColorPicker({
    required this.label,
    required this.color,
    required this.onColorChanged,
    required this.isEditing,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final predefinedColors = [
      AppTheme.accentBlue,
      AppTheme.accentPurple,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF607D8B),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              width: screenSize.height * 0.04,
              height: screenSize.height * 0.04,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(screenSize.height * 0.02),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
        if (isEditing) ...[
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Wrap(
            spacing: AppTheme.getSmallPadding(screenSize) * 0.5,
            runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
            children: predefinedColors
                .map((presetColor) => GestureDetector(
                      onTap: () => onColorChanged(presetColor),
                      child: Container(
                        width: screenSize.height * 0.035,
                        height: screenSize.height * 0.035,
                        decoration: BoxDecoration(
                          color: presetColor,
                          borderRadius:
                              BorderRadius.circular(screenSize.height * 0.0175),
                          border: Border.all(
                            color: color == presetColor
                                ? AppTheme.getTextPrimaryColor(context)
                                : AppTheme.getBorderColor(context),
                            width: color == presetColor ? 3 : 1,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Size screenSize;
  final AppLocalizations l10n;

  const _PreviewCard({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.preview ?? 'Vista previa',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize) * 0.5),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    l10n.schoolName,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                    vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize) * 0.5),
                  ),
                  child: Text(
                    l10n.notifications,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
