import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class SchoolInfoForm extends StatefulWidget {
  final Size screenSize;

  const SchoolInfoForm({
    super.key,
    required this.screenSize,
  });

  @override
  State<SchoolInfoForm> createState() => _SchoolInfoFormState();
}

class _SchoolInfoFormState extends State<SchoolInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _schoolAddressController = TextEditingController();
  final _principalNameController = TextEditingController();
  final _schoolCodeController = TextEditingController();
  final _foundedYearController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  void _loadSchoolData() {
    // Mock data
    _schoolNameController.text = 'Escuela Primaria Benito Juárez';
    _schoolAddressController.text = 'Av. Reforma #123, Col. Centro, México';
    _principalNameController.text = 'Lic. María Elena González';
    _schoolCodeController.text = 'ESC001';
    _foundedYearController.text = '1985';
    _descriptionController.text = 'Institución educativa comprometida con la excelencia académica y el desarrollo integral de nuestros estudiantes.';
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    _principalNameController.dispose();
    _schoolCodeController.dispose();
    _foundedYearController.dispose();
    _descriptionController.dispose();
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
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: AppTheme.accentBlue,
                    size: widget.screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
                Expanded(
                  child: Text(
                    l10n.schoolInfo,
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
                    color: AppTheme.accentBlue,
                    size: widget.screenSize.height * 0.025,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // School Name
            _buildFormField(
              label: l10n.schoolName,
              controller: _schoolNameController,
              icon: Icons.business_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fieldRequired ?? 'Este campo es requerido';
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // School Address
            _buildFormField(
              label: l10n.schoolAddress,
              controller: _schoolAddressController,
              icon: Icons.location_on_rounded,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fieldRequired ?? 'Este campo es requerido';
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // Principal Name
            _buildFormField(
              label: l10n.principalName,
              controller: _principalNameController,
              icon: Icons.person_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fieldRequired ?? 'Este campo es requerido';
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // School Code and Founded Year
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: l10n.schoolCode ?? 'Código de escuela',
                    controller: _schoolCodeController,
                    icon: Icons.tag_rounded,
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
                    label: l10n.foundedYear ?? 'Año de fundación',
                    controller: _foundedYearController,
                    icon: Icons.calendar_today_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.fieldRequired ?? 'Este campo es requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // Description
            _buildFormField(
              label: l10n.description ?? 'Descripción',
              controller: _descriptionController,
              icon: Icons.description_rounded,
              maxLines: 3,
            ),

            if (_isEditing) ...[
              SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),
              SolidButton(
                backgroundColor: AppTheme.accentBlue,
                onPressed: _isLoading ? () {} : _saveSchoolInfo,
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: _isEditing 
                  ? AppTheme.accentBlue 
                  : AppTheme.getTextSecondaryColor(context),
              size: widget.screenSize.height * 0.025,
            ),
            filled: true,
            fillColor: _isEditing 
                ? AppTheme.getInputFillColor(context)
                : AppTheme.getBackgroundColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: _isEditing 
                    ? AppTheme.accentBlue.withOpacity(0.3)
                    : AppTheme.getBorderColor(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentBlue.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentBlue,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getMediumRadius(widget.screenSize)),
              borderSide: BorderSide(
                color: AppTheme.getBorderColor(context),
              ),
            ),
            contentPadding: EdgeInsets.all(
                AppTheme.getMediumPadding(widget.screenSize)),
          ),
          style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  void _saveSchoolInfo() async {
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
