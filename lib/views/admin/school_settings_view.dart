import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../components/headers/nav_header.dart';
import '../../components/buttons/solid_button.dart';
import '../../models/models.dart';

class SchoolSettingsView extends StatefulWidget {
  const SchoolSettingsView({super.key});

  @override
  State<SchoolSettingsView> createState() => _SchoolSettingsViewState();
}

class _SchoolSettingsViewState extends State<SchoolSettingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _directorController = TextEditingController();
  final _yearFoundedController = TextEditingController();

  TipoEscuela _selectedTipo = TipoEscuela.publica;
  List<NivelEducativo> _selectedNiveles = [NivelEducativo.primaria];
  bool _isLoading = false;

  // Colors
  Color _primaryColor = AppTheme.accentBlue;
  Color _secondaryColor = AppTheme.accentPurple;
  Color _accentColor = AppTheme.successColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSchoolData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreController.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _sitioWebController.dispose();
    _descripcionController.dispose();
    _directorController.dispose();
    _yearFoundedController.dispose();
    super.dispose();
  }

  void _loadSchoolData() {
    // Mock data
    _nombreController.text = 'Escuela Primaria Benito Juárez';
    _codigoController.text = 'ESC001';
    _direccionController.text =
        'Av. Reforma #123, Col. Centro, Ciudad de México';
    _telefonoController.text = '+52 55 1234 5678';
    _emailController.text = 'contacto@escuela-benitojuarez.edu.mx';
    _sitioWebController.text = 'www.escuela-benitojuarez.edu.mx';
    _descripcionController.text =
        'Institución educativa comprometida con la excelencia académica y el desarrollo integral de nuestros estudiantes desde hace más de 50 años.';
    _directorController.text = 'Lic. María Elena González Pérez';
    _yearFoundedController.text = '1985';
    _selectedTipo = TipoEscuela.publica;
    _selectedNiveles = [NivelEducativo.primaria];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: l10n.schoolSettings),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Tab Bar
                    Container(
                      margin:
                          EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getLargeRadius(screenSize)),
                        border:
                            Border.all(color: AppTheme.getBorderColor(context)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.accentPurple,
                          borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize)),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor:
                            AppTheme.getTextSecondaryColor(context),
                        labelStyle: AppTheme.getCaption(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
                          Tab(
                            icon: Icon(Icons.info_rounded,
                                size: screenSize.height * 0.022),
                            text: 'Información',
                          ),
                          Tab(
                            icon: Icon(Icons.contact_phone_rounded,
                                size: screenSize.height * 0.022),
                            text: 'Contacto',
                          ),
                        ],
                      ),
                    ),

                    // Tab View Content
                    Container(
                      height: screenSize.height * 0.7,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildInformationTab(screenSize, context, l10n),
                          _buildContactTab(screenSize, context, l10n),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInformationTab(
      Size screenSize, BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Información Básica',
              icon: Icons.school_rounded,
              color: AppTheme.accentBlue,
              children: [
                CustomInputField(
                  controller: _nombreController,
                  label: l10n.schoolName,
                  screenSize: screenSize,
                  icon: Icons.business_rounded,
                  validator: (value) =>
                      value?.isEmpty == true ? l10n.fieldRequired : null,
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        controller: _codigoController,
                        label: l10n.schoolCode,
                        screenSize: screenSize,
                        icon: Icons.tag_rounded,
                        validator: (value) =>
                            value?.isEmpty == true ? l10n.fieldRequired : null,
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      child: CustomInputField(
                        controller: _yearFoundedController,
                        label: l10n.foundedYear,
                        screenSize: screenSize,
                        icon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? l10n.fieldRequired : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                CustomInputField(
                  controller: _directorController,
                  label: 'Director/a',
                  screenSize: screenSize,
                  icon: Icons.person_rounded,
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                _buildTextAreaField(
                  label: l10n.description,
                  controller: _descripcionController,
                  icon: Icons.description_rounded,
                  maxLines: 3,
                ),
              ],
            ),
            SizedBox(height: AppTheme.getLargePadding(screenSize)),
            _buildSectionCard(
              title: 'Configuración Institucional',
              icon: Icons.settings_rounded,
              color: AppTheme.successColor,
              children: [
                _buildDropdownField(
                  label: 'Tipo de Escuela',
                  value: _selectedTipo,
                  items: TipoEscuela.values,
                  onChanged: (value) => setState(() => _selectedTipo = value!),
                  getLabel: (tipo) => _getTipoLabel(tipo),
                ),
                SizedBox(height: AppTheme.getLargePadding(screenSize)),
                _buildImprovedMultiSelectField(
                  label: 'Niveles Educativos',
                  selectedItems: _selectedNiveles,
                  allItems: NivelEducativo.values,
                  onChanged: (niveles) =>
                      setState(() => _selectedNiveles = niveles),
                  getLabel: (nivel) => _getNivelLabel(nivel),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getLargePadding(screenSize)),
            _buildSaveButton(screenSize, l10n),
            SizedBox(height: AppTheme.getLargePadding(screenSize) * 6),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTab(
      Size screenSize, BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: l10n.contactInfo,
            icon: Icons.contact_phone_rounded,
            color: AppTheme.successColor,
            children: [
              _buildTextAreaField(
                label: l10n.schoolAddress,
                controller: _direccionController,
                icon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty == true ? l10n.fieldRequired : null,
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _telefonoController,
                      label: l10n.schoolPhone,
                      screenSize: screenSize,
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty == true ? l10n.fieldRequired : null,
                    ),
                  ),
                  SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                  Expanded(
                    child: CustomInputField(
                      controller: _emailController,
                      label: l10n.schoolEmail,
                      screenSize: screenSize,
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty == true) return l10n.fieldRequired;
                        if (value != null && !value.contains('@'))
                          return l10n.invalidEmail;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              CustomInputField(
                controller: _sitioWebController,
                label: l10n.website,
                screenSize: screenSize,
                icon: Icons.language_rounded,
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
          _buildSaveButton(screenSize, l10n),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                title,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            prefixIcon: Icon(
              icon,
              color: AppTheme.accentPurple,
              size: screenSize.width * 0.05,
            ),
            filled: true,
            fillColor: AppTheme.getInputFillColor(context),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: BorderSide(
                color: AppTheme.accentPurple.withOpacity(0.0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: const BorderSide(
                color: AppTheme.accentPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) getLabel,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize) * 0.3,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentPurple.withOpacity(0.0),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.05,
              ),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(getLabel(item)),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovedMultiSelectField<T>({
    required String label,
    required List<T> selectedItems,
    required List<T> allItems,
    required ValueChanged<List<T>> onChanged,
    required String Function(T) getLabel,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona los niveles educativos que ofrece la escuela:',
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              Wrap(
                spacing: AppTheme.getSmallPadding(screenSize),
                runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
                children: allItems.map((item) {
                  final isSelected = selectedItems.contains(item);
                  return InkWell(
                    onTap: () {
                      final newList = List<T>.from(selectedItems);
                      if (isSelected) {
                        if (newList.length > 1) {
                          // Mantener al menos uno seleccionado
                          newList.remove(item);
                        }
                      } else {
                        newList.add(item);
                      }
                      onChanged(newList);
                    },
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentPurple
                            : AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.getBorderColor(context),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: screenSize.width * 0.04,
                            height: screenSize.width * 0.04,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: AppTheme.getBorderColor(context),
                                      width: 1,
                                    ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    color: AppTheme.accentPurple,
                                    size: screenSize.width * 0.03,
                                  )
                                : null,
                          ),
                          SizedBox(
                              width:
                                  AppTheme.getSmallPadding(screenSize) * 0.7),
                          Text(
                            getLabel(item),
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.getTextPrimaryColor(context),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (selectedItems.isEmpty) ...[
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.warningColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: AppTheme.warningColor,
                        size: screenSize.width * 0.04,
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Expanded(
                        child: Text(
                          'Debe seleccionar al menos un nivel educativo',
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Size screenSize, AppLocalizations l10n) {
    return SolidButton(
      onPressed: _isLoading ? () {} : _saveSettings,
      label: _isLoading ? l10n.saving : l10n.updateSettings,
      icon: _isLoading ? null : Icons.save_rounded,
      backgroundColor: AppTheme.accentPurple,
      screenSize: screenSize,
      width: double.infinity,
    );
  }

  String _getTipoLabel(TipoEscuela tipo) {
    switch (tipo) {
      case TipoEscuela.publica:
        return 'Pública';
      case TipoEscuela.privada:
        return 'Privada';
      case TipoEscuela.mixta:
        return 'Mixta';
    }
  }

  String _getNivelLabel(NivelEducativo nivel) {
    switch (nivel) {
      case NivelEducativo.preescolar:
        return 'Preescolar';
      case NivelEducativo.primaria:
        return 'Primaria';
      case NivelEducativo.secundaria:
        return 'Secundaria';
      case NivelEducativo.bachillerato:
        return 'Bachillerato';
      case NivelEducativo.mixto:
        return 'Mixto';
    }
  }

  void _showColorPicker(Color currentColor, ValueChanged<Color> onChanged) {
    final colors = [
      AppTheme.accentBlue,
      AppTheme.accentPurple,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.green,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                AppTheme.getLargeRadius(MediaQuery.of(context).size)),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(
                AppTheme.getMediumPadding(MediaQuery.of(context).size)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar Color',
                  style: AppTheme.getH2(MediaQuery.of(context).size).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                SizedBox(
                    height:
                        AppTheme.getMediumPadding(MediaQuery.of(context).size)),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    return GestureDetector(
                      onTap: () {
                        onChanged(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(
                                  MediaQuery.of(context).size)),
                          border: currentColor == color
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de carga de imagen próximamente'),
        backgroundColor: AppTheme.accentPurple,
      ),
    );
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).settingsUpdated,
              style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(MediaQuery.of(context).size)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
