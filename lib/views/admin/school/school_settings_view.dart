import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../models/models.dart';
import '../../../components/admin/school/information_tab.dart';
import '../../../components/admin/school/contact_tab.dart';
import '../../../components/admin/school/color_picker_bottom_sheet.dart';

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
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        AppTheme.getSmallPadding(screenSize),
                    left: AppTheme.getMediumPadding(screenSize),
                    right: AppTheme.getMediumPadding(screenSize),
                    bottom: AppTheme.getLargePadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                  ),
                  child: Column(
                    children: [
                      // Title and Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.schoolSettings,
                                  style: AppTheme.getH1(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextPrimaryColor(context),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        AppTheme.getSmallPadding(screenSize) *
                                            0.5),
                                Text(
                                  l10n.manageAndSearchStudents,
                                  style: AppTheme.getBodyMedium(screenSize)
                                      .copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Tab Bar
                      Container(
                        margin: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getLargeRadius(screenSize)),
                          border: Border.all(
                              color: AppTheme.getBorderColor(context)),
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
                              text: l10n.information,
                            ),
                            Tab(
                              icon: Icon(Icons.contact_phone_rounded,
                                  size: screenSize.height * 0.022),
                              text: l10n.contact,
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
                            InformationTab(
                              formKey: _formKey,
                              nombreController: _nombreController,
                              codigoController: _codigoController,
                              descripcionController: _descripcionController,
                              directorController: _directorController,
                              yearFoundedController: _yearFoundedController,
                              selectedTipo: _selectedTipo,
                              selectedNiveles: _selectedNiveles,
                              onTipoChanged: (tipo) =>
                                  setState(() => _selectedTipo = tipo),
                              onNivelesChanged: (niveles) =>
                                  setState(() => _selectedNiveles = niveles),
                              isLoading: _isLoading,
                              onSave: _saveSettings,
                              getTipoLabel: _getTipoLabel,
                              getNivelLabel: _getNivelLabel,
                            ),
                            ContactTab(
                              direccionController: _direccionController,
                              telefonoController: _telefonoController,
                              emailController: _emailController,
                              sitioWebController: _sitioWebController,
                              isLoading: _isLoading,
                              onSave: _saveSettings,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTipoLabel(TipoEscuela tipo) {
    final l10n = AppLocalizations.of(context);
    switch (tipo) {
      case TipoEscuela.publica:
        return l10n.public;
      case TipoEscuela.privada:
        return l10n.private;
      case TipoEscuela.mixta:
        return l10n.mixed;
    }
  }

  String _getNivelLabel(NivelEducativo nivel) {
    final l10n = AppLocalizations.of(context);
    switch (nivel) {
      case NivelEducativo.preescolar:
        return l10n.preschool;
      case NivelEducativo.primaria:
        return l10n.primary;
      case NivelEducativo.secundaria:
        return l10n.secondary;
      case NivelEducativo.bachillerato:
        return l10n.highSchool;
      case NivelEducativo.mixto:
        return l10n.mixed;
    }
  }

  void _showImagePicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).imageUploadSoonAvailable),
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
            content:
                Text(AppLocalizations.of(context).errorSaving(e.toString())),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
