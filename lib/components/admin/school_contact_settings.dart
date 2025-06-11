import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class SchoolContactSettings extends StatefulWidget {
  final Size screenSize;

  const SchoolContactSettings({
    super.key,
    required this.screenSize,
  });

  @override
  State<SchoolContactSettings> createState() => _SchoolContactSettingsState();
}

class _SchoolContactSettingsState extends State<SchoolContactSettings> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContactData();
  }

  void _loadContactData() {
    // Mock data
    _phoneController.text = '+52 55 1234 5678';
    _emailController.text = 'contacto@escuelabenitojuarez.edu.mx';
    _websiteController.text = 'www.escuelabenitojuarez.edu.mx';
    _emergencyPhoneController.text = '+52 55 9876 5432';
    _facebookController.text = 'EscuelaBenitoJuarezOficial';
    _instagramController.text = '@escuela_benito_juarez';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _emergencyPhoneController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Icon(
                    Icons.contact_phone_rounded,
                    color: AppTheme.successColor,
                    size: widget.screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
                Expanded(
                  child: Text(
                    l10n.contactInfo ?? 'Información de contacto',
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
                    color: AppTheme.successColor,
                    size: widget.screenSize.height * 0.025,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // Contact Information Section
            _buildSectionHeader(
              l10n.primaryContact ?? 'Contacto principal',
              Icons.phone_rounded,
              AppTheme.accentBlue,
            ),

            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),

            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: l10n.schoolPhone,
                    controller: _phoneController,
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.fieldRequired ?? 'Este campo es requerido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: _buildFormField(
                    label: l10n.emergencyPhone ?? 'Teléfono de emergencia',
                    controller: _emergencyPhoneController,
                    icon: Icons.emergency_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            _buildFormField(
              label: l10n.schoolEmail,
              controller: _emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fieldRequired ?? 'Este campo es requerido';
                }
                if (!value.contains('@')) {
                  return l10n.invalidEmail ?? 'Email inválido';
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            _buildFormField(
              label: l10n.website ?? 'Sitio web',
              controller: _websiteController,
              icon: Icons.language_rounded,
              keyboardType: TextInputType.url,
            ),

            SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),

            // Social Media Section
            _buildSectionHeader(
              l10n.socialMedia ?? 'Redes sociales',
              Icons.share_rounded,
              AppTheme.accentPurple,
            ),

            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),

            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: 'Facebook',
                    controller: _facebookController,
                    icon: Icons.facebook_rounded,
                    prefix: 'facebook.com/',
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: _buildFormField(
                    label: 'Instagram',
                    controller: _instagramController,
                    icon: Icons.camera_alt_rounded,
                    prefix: '@',
                  ),
                ),
              ],
            ),

            if (_isEditing) ...[
              SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),
              SolidButton(
                backgroundColor: AppTheme.successColor,
                onPressed: _isLoading ? () {} : _saveContactInfo,
                label: _isLoading ? (l10n.saving ?? 'Guardando...') : l10n.saveChanges,
                icon: _isLoading ? null : Icons.save_rounded,
                screenSize: widget.screenSize,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize) * 0.5),
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.5),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: _isEditing 
                  ? AppTheme.successColor 
                  : AppTheme.getTextSecondaryColor(context),
              size: widget.screenSize.height * 0.022,
            ),
            prefixText: prefix,
            prefixStyle: AppTheme.getCaption(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            filled: true,
            fillColor: _isEditing 
                ? AppTheme.getInputFillColor(context)
                : AppTheme.getBackgroundColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: _isEditing 
                    ? AppTheme.successColor.withOpacity(0.3)
                    : AppTheme.getBorderColor(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.successColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.successColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.getBorderColor(context),
              ),
            ),
            contentPadding: EdgeInsets.all(
                AppTheme.getSmallPadding(widget.screenSize)),
          ),
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  void _saveContactInfo() async {
    if (!_formKey.currentState!.validate()) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: $e',
              style: AppTheme.getCaption(widget.screenSize).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize)),
            ),
          ),
        );
      }
    }
  }
}
