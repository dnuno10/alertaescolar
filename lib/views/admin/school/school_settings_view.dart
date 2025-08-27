import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../models/models.dart';
import '../../../components/admin/school/information_tab.dart';
import '../../../components/admin/school/contact_tab.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/school_provider.dart';

class SchoolSettingsView extends StatefulWidget {
  const SchoolSettingsView({super.key});

  @override
  State<SchoolSettingsView> createState() => _SchoolSettingsViewState();
}

class _SchoolSettingsViewState extends State<SchoolSettingsView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late ScrollController _scrollController;
// Add a separate key for each tab
  final _informationFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();
  bool _isKeyboardVisible = false;

  // Form controllers
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _yearFoundedController = TextEditingController();

  // Focus nodes
  final _nombreFocusNode = FocusNode();
  final _codigoFocusNode = FocusNode();
  final _descripcionFocusNode = FocusNode();
  final _yearFoundedFocusNode = FocusNode();
  final _direccionFocusNode = FocusNode();
  final _telefonoFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _sitioWebFocusNode = FocusNode();

  TipoEscuela _selectedTipo = TipoEscuela.publica;

  // Educational levels as booleans to match database structure
  bool _hasPreescolar = false;
  bool _hasPrimaria = false;
  bool _hasSecundaria = false;
  bool _hasBachillerato = false;

  List<NivelEducativo> _selectedNiveles = [NivelEducativo.primaria];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _scrollController.dispose();

    // Dispose controllers
    _nombreController.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _sitioWebController.dispose();
    _descripcionController.dispose();
    _yearFoundedController.dispose();

    // Dispose focus nodes
    _nombreFocusNode.dispose();
    _codigoFocusNode.dispose();
    _descripcionFocusNode.dispose();
    _yearFoundedFocusNode.dispose();
    _direccionFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _emailFocusNode.dispose();
    _sitioWebFocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    final newIsKeyboardVisible = bottomInset > 0;

    if (newIsKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newIsKeyboardVisible;
      });
    }
  }

  Future<void> _loadSchoolData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final schoolProvider =
          Provider.of<SchoolProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context);

      if (userProvider.currentUser?.escuelaId == null) {
        _showErrorDialog(
          l10n.error,
          l10n.noAssociatedSchool,
        );
        return;
      }

      final school = await schoolProvider
          .loadSchool(userProvider.currentUser!.escuelaId!, context: context);

      if (school == null) {
        if (mounted) {
          _showErrorDialog(
            l10n.error,
            l10n.errorLoadingSchoolInfo,
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _nombreController.text = school.nombre;
          _codigoController.text = school.codigo;
          _direccionController.text = school.direccion;
          _telefonoController.text = school.telefono;
          _emailController.text = school.email;
          _sitioWebController.text = school.sitioWeb ?? '';
          _descripcionController.text = school.descripcion ?? '';
          _selectedTipo = school.tipo;

          // Convert educational levels from list to boolean flags
          _hasPreescolar =
              school.nivelesEducativos.contains(NivelEducativo.preescolar);
          _hasPrimaria =
              school.nivelesEducativos.contains(NivelEducativo.primaria);
          _hasSecundaria =
              school.nivelesEducativos.contains(NivelEducativo.secundaria);
          _hasBachillerato =
              school.nivelesEducativos.contains(NivelEducativo.bachillerato);

          // Update selected levels list for backward compatibility
          _updateSelectedNivelesFromBooleans();

          // Extract year from fundacion if available
          _yearFoundedController.text = school.fechaRegistro.year.toString();

          // Extra data that might be available in your actual model
          // Adjust as needed
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        _showErrorDialog(
          l10n.error,
          '${l10n.errorLoadingSchoolInfo}: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _hideKeyboard() {
    // Unfocus all focus nodes
    _nombreFocusNode.unfocus();
    _codigoFocusNode.unfocus();
    _descripcionFocusNode.unfocus();
    _yearFoundedFocusNode.unfocus();
    _direccionFocusNode.unfocus();
    _telefonoFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _sitioWebFocusNode.unfocus();

    // Alternative way to hide keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: GestureDetector(
            onTap: _hideKeyboard,
            child: Stack(
              children: [
                // Header fijo y tab bar
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        AppTheme.getSmallPadding(screenSize),
                    left: AppTheme.getMediumPadding(screenSize),
                    right: AppTheme.getMediumPadding(screenSize),
                    bottom: AppTheme.getLargePadding(screenSize),
                  ),
                  color: AppTheme.getCardColor(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Actions Row
                      Text(
                        l10n.schoolSettings,
                        style: AppTheme.getH1(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Text(
                        l10n.manageAndSearchStudents,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      Container(
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
                    ],
                  ),
                ),
                // Contenido scrolleable debajo del header fijo
                Positioned.fill(
                  top: MediaQuery.of(context).padding.top +
                      AppTheme.getSmallPadding(screenSize) +
                      AppTheme.getLargePadding(screenSize) +
                      AppTheme.getH1(screenSize).fontSize! +
                      AppTheme.getBodyMedium(screenSize).fontSize! +
                      AppTheme.getMediumPadding(screenSize) * 2 +
                      48, // Altura aproximada del TabBar
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        InformationTab(
                          formKey: _informationFormKey,
                          nombreController: _nombreController,
                          codigoController: _codigoController,
                          descripcionController: _descripcionController,
                          yearFoundedController: _yearFoundedController,
                          selectedTipo: _selectedTipo,
                          selectedNiveles: _selectedNiveles,
                          onTipoChanged: (tipo) =>
                              setState(() => _selectedTipo = tipo),
                          onNivelesChanged: (niveles) =>
                              setState(() => _selectedNiveles = niveles),
                          hasPreescolar: _hasPreescolar,
                          hasPrimaria: _hasPrimaria,
                          hasSecundaria: _hasSecundaria,
                          hasBachillerato: _hasBachillerato,
                          onPreescolarChanged: (value) => setState(() {
                            _hasPreescolar = value;
                            _updateSelectedNivelesFromBooleans();
                          }),
                          onPrimariaChanged: (value) => setState(() {
                            _hasPrimaria = value;
                            _updateSelectedNivelesFromBooleans();
                          }),
                          onSecundariaChanged: (value) => setState(() {
                            _hasSecundaria = value;
                            _updateSelectedNivelesFromBooleans();
                          }),
                          onBachilleratoChanged: (value) => setState(() {
                            _hasBachillerato = value;
                            _updateSelectedNivelesFromBooleans();
                          }),
                          isLoading: _isLoading,
                          onSave: _saveSettings,
                          getTipoLabel: _getTipoLabel,
                          getNivelLabel: _getNivelLabel,
                          nombreFocusNode: _nombreFocusNode,
                          codigoFocusNode: _codigoFocusNode,
                          descripcionFocusNode: _descripcionFocusNode,
                          yearFoundedFocusNode: _yearFoundedFocusNode,
                        ),
                        ContactTab(
                          formKey: _contactFormKey,
                          direccionController: _direccionController,
                          telefonoController: _telefonoController,
                          emailController: _emailController,
                          sitioWebController: _sitioWebController,
                          isLoading: _isLoading,
                          onSave: _saveSettings,
                          direccionFocusNode: _direccionFocusNode,
                          telefonoFocusNode: _telefonoFocusNode,
                          emailFocusNode: _emailFocusNode,
                          sitioWebFocusNode: _sitioWebFocusNode,
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón flotante animado
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  left: 0,
                  right: 0,
                  bottom: _isKeyboardVisible ? -1000 : 0,
                  child: SafeArea(
                    minimum:
                        const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                    child: SolidButton(
                      onPressed: _isLoading ? () {} : _saveSettings,
                      label: _isLoading
                          ? AppLocalizations.of(context).saving
                          : AppLocalizations.of(context).updateSettings,
                      icon: _isLoading ? null : Icons.save_rounded,
                      backgroundColor: AppTheme.accentPurple,
                      screenSize: screenSize,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
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
    }
  }

  // Image picker functionality to be implemented later

  void _saveSettings() async {
    // Check which tab is active and validate the appropriate form
    final isInformationTab = _tabController.index == 0;
    final formKey = isInformationTab ? _informationFormKey : _contactFormKey;

    // Safer null check
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    // Validate required fields
    final List<String> missingFields = [];

    if (_nombreController.text.trim().isEmpty) {
      missingFields.add(l10n.schoolName);
    }
    if (_direccionController.text.trim().isEmpty) {
      missingFields.add(l10n.address);
    }
    if (_telefonoController.text.trim().isEmpty) {
      missingFields.add(l10n.phone);
    }
    if (_emailController.text.trim().isEmpty) {
      missingFields.add(l10n.email);
    }
    if (_yearFoundedController.text.trim().isEmpty) {
      missingFields.add(l10n.foundedYear);
    }

    if (missingFields.isNotEmpty) {
      _showErrorDialog(
        l10n.requiredFields,
        '${l10n.pleaseCompleteFields}:\n- ${missingFields.join('\n- ')}',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final schoolProvider =
          Provider.of<SchoolProvider>(context, listen: false);

      if (userProvider.currentUser?.escuelaId == null) {
        _showErrorDialog(
          l10n.error,
          l10n.noAssociatedSchool,
        );
        return;
      }

      // Get current school data
      final currentSchool = schoolProvider.currentSchool;
      if (currentSchool == null) {
        _showErrorDialog(
          l10n.error,
          l10n.couldNotGetSchoolInfo,
        );
        return;
      }

      // Update selected niveles from the boolean flags
      _updateSelectedNivelesFromBooleans();

      // Update school data
      final updatedSchool = currentSchool.copyWith(
        nombre: _nombreController.text.trim(),
        codigo: _codigoController.text.trim(),
        tipo: _selectedTipo,
        nivelesEducativos: _selectedNiveles,
        direccion: _direccionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim(),
        sitioWeb: _sitioWebController.text.trim().isEmpty
            ? null
            : _sitioWebController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      );

      final success =
          await schoolProvider.updateSchool(updatedSchool, context: context);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.settingsUpdated,
                style:
                    AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
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
        } else {
          _showErrorDialog(
            l10n.error,
            schoolProvider.error ?? l10n.unknownError,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        _showErrorDialog(
          l10n.error,
          '${l10n.errorSavingChanges}: ${e.toString()}',
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        final screenSize = MediaQuery.of(context).size;

        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: AppTheme.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(screenSize),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.ok,
                style: TextStyle(color: AppTheme.accentPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to update selected niveles list from boolean flags
  void _updateSelectedNivelesFromBooleans() {
    _selectedNiveles = [];

    if (_hasPreescolar) {
      _selectedNiveles.add(NivelEducativo.preescolar);
    }
    if (_hasPrimaria) {
      _selectedNiveles.add(NivelEducativo.primaria);
    }
    if (_hasSecundaria) {
      _selectedNiveles.add(NivelEducativo.secundaria);
    }
    if (_hasBachillerato) {
      _selectedNiveles.add(NivelEducativo.bachillerato);
    }

    // Default to primaria if nothing is selected
    if (_selectedNiveles.isEmpty) {
      _selectedNiveles.add(NivelEducativo.primaria);
      _hasPrimaria = true;
    }
  }

  // This method was removed as it's no longer needed
}
