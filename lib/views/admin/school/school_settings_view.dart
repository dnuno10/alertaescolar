import 'dart:ui';

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
  bool _isKeyboardVisible = false;

  // Keys por pestaña (validación independiente)
  final _informationFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  // Controllers
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

  // Estado
  TipoEscuela _selectedTipo = TipoEscuela.publica;

  // Niveles (banderas para UI) + lista para modelo
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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchoolData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();

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
    final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    final bottomInset = view?.viewInsets.bottom ?? 0;
    final visible = bottomInset > 0;
    if (visible != _isKeyboardVisible && mounted) {
      setState(() => _isKeyboardVisible = visible);
    }
  }

  /// Espera breve y defensiva a que el UserProvider resuelva escuelaId
  /// Espera más generosa a que el UserProvider resuelva escuelaId (primer arranque)
  Future<String?> _waitForEscuelaId(UserProvider up,
      {Duration timeout = const Duration(seconds: 8)}) async {
    final start = DateTime.now();
    String? id = up.currentUser?.escuelaId;

    while ((id == null || id.isEmpty) &&
        DateTime.now().difference(start) < timeout) {
      await Future.delayed(const Duration(milliseconds: 150));
      id = await up.ensureEscuelaIdLoaded();
      id ??= up.currentUser?.escuelaId;
    }
    return id;
  }

  /// Intenta cargar la escuela con reintentos y backoff
  Future<Escuela?> _loadSchoolWithRetry(SchoolProvider sp, String escuelaId,
      {int maxAttempts = 3}) async {
    int attempt = 0;
    Duration wait = const Duration(milliseconds: 350);

    while (attempt < maxAttempts) {
      final school = await sp.loadSchool(escuelaId);
      if (school != null) return school;

      // Si hubo error de red/latencia, espera y reintenta
      await Future.delayed(wait);
      wait *= 2;
      attempt++;
    }
    return null;
  }

  Future<void> _loadSchoolData() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final schoolProvider =
          Provider.of<SchoolProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context);

      // 1) Espera (más larga) por escuelaId
      final escuelaId = await _waitForEscuelaId(userProvider);
      if (escuelaId == null || escuelaId.isEmpty) {
        _showErrorDialog(l10n.error, l10n.noAssociatedSchool);
        return;
      }

      // 2) Carga con reintentos (absorbe el lag del primer login)
      Escuela? school = await _loadSchoolWithRetry(schoolProvider, escuelaId);

      // 3) Si sigue null y es admin → no mostrar diálogo; abrir formulario vacío con defaults
      final isAdmin = userProvider.isAdmin();
      if (school == null && isAdmin) {
        if (!mounted) return;
        // Estado “suave”: formulario en blanco, sin modal de error
        setState(() {
          _nombreController.text = '';
          _codigoController.text = '';
          _direccionController.text = '';
          _telefonoController.text = '';
          _emailController.text = userProvider.currentUser?.email ?? '';
          _sitioWebController.text = '';
          _descripcionController.text = '';
          _selectedTipo = TipoEscuela.publica;

          _hasPreescolar = false;
          _hasPrimaria = true; // default para no dejar vacío
          _hasSecundaria = false;
          _hasBachillerato = false;
          _updateSelectedNivelesFromBooleans();

          _yearFoundedController.text =
              DateTime.now().year.toString(); // placeholder
        });

        // Mensaje no intrusivo (SnackBar) en lugar de diálogo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.couldNotGetSchoolInfo, // Mantén tu string
                style: AppTheme.getCaption(MediaQuery.of(context).size)
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppTheme.warningColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(MediaQuery.of(context).size),
                ),
              ),
            ),
          );
        }
        return; // ✅ No abrimos diálogo
      }

      // 4) Caso normal: school cargada
      if (school == null) {
        // Usuario no admin (padre/tutor) o error real persistente
        final msg = (schoolProvider.error?.isNotEmpty ?? false)
            ? '${l10n.errorLoadingSchoolInfo}: ${schoolProvider.error}'
            : l10n.couldNotGetSchoolInfo;
        _showErrorDialog(l10n.error, msg);
        return;
      }

      if (!mounted) return;
      setState(() {
        _nombreController.text = school.nombre;
        _codigoController.text = school.codigo ?? '';
        _direccionController.text = school.direccion;
        _telefonoController.text = school.telefono;
        _emailController.text = school.email;
        _sitioWebController.text = school.sitioWeb ?? '';
        _descripcionController.text = school.descripcion ?? '';
        _selectedTipo = school.tipo;

        _hasPreescolar =
            school.nivelesEducativos.contains(NivelEducativo.preescolar);
        _hasPrimaria =
            school.nivelesEducativos.contains(NivelEducativo.primaria);
        _hasSecundaria =
            school.nivelesEducativos.contains(NivelEducativo.secundaria);
        _hasBachillerato =
            school.nivelesEducativos.contains(NivelEducativo.bachillerato);
        _updateSelectedNivelesFromBooleans();

        _yearFoundedController.text = school.fechaRegistro.year.toString();
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        _showErrorDialog(l10n.error, '${l10n.errorLoadingSchoolInfo}: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _hideKeyboard() => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Altura estimada del header + tabs (mantén esto simple y estable)
    final headerHeight = MediaQuery.of(context).padding.top +
        AppTheme.getSmallPadding(screenSize) +
        AppTheme.getMediumPadding(screenSize) +
        AppTheme.getH1(screenSize).fontSize! +
        AppTheme.getBodyMedium(screenSize).fontSize! +
        AppTheme.getMediumPadding(screenSize) * 2 +
        64; // alto aproximado del TabBar

    // Render defensivo: mientras el UserProvider se hidrata, muestra loader y evita diálogos prematuros.
    return Consumer3<ThemeProvider, UserProvider, SchoolProvider>(
      builder: (context, themeProvider, userProvider, schoolProvider, child) {
        final userLoading = userProvider.isLoadingUser == true;

        if (userLoading) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: GestureDetector(
            onTap: _hideKeyboard,
            child: Stack(
              children: [
                // Header + TabBar
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

                // Contenido
                Positioned.fill(
                  top: headerHeight,
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
                          onPreescolarChanged: (v) {
                            setState(() {
                              _hasPreescolar = v;
                              _updateSelectedNivelesFromBooleans();
                            });
                          },
                          onPrimariaChanged: (v) {
                            setState(() {
                              _hasPrimaria = v;
                              _updateSelectedNivelesFromBooleans();
                            });
                          },
                          onSecundariaChanged: (v) {
                            setState(() {
                              _hasSecundaria = v;
                              _updateSelectedNivelesFromBooleans();
                            });
                          },
                          onBachilleratoChanged: (v) {
                            setState(() {
                              _hasBachillerato = v;
                              _updateSelectedNivelesFromBooleans();
                            });
                          },
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

                // Botón Guardar (oculto si el teclado está visible)
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

  Future<void> _saveSettings() async {
    // Valida solo la pestaña activa
    final isInformationTab = _tabController.index == 0;
    final formKey = isInformationTab ? _informationFormKey : _contactFormKey;
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final l10n = AppLocalizations.of(context);

    // Campos requeridos (por diseño)
    final missing = <String>[];
    if (_nombreController.text.trim().isEmpty) missing.add(l10n.schoolName);
    if (_direccionController.text.trim().isEmpty) missing.add(l10n.address);
    if (_telefonoController.text.trim().isEmpty) missing.add(l10n.phone);
    if (_emailController.text.trim().isEmpty) missing.add(l10n.email);
    if (_yearFoundedController.text.trim().isEmpty) {
      missing.add(l10n.foundedYear);
    }

    if (missing.isNotEmpty) {
      _showErrorDialog(
        l10n.requiredFields,
        '${l10n.pleaseCompleteFields}:\n- ${missing.join('\n- ')}',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final schoolProvider =
          Provider.of<SchoolProvider>(context, listen: false);

      // Unificar con el flujo de carga: usa ensureEscuelaIdLoaded
      final escuelaId = await userProvider.ensureEscuelaIdLoaded();
      if (escuelaId == null || escuelaId.isEmpty) {
        _showErrorDialog(l10n.error, l10n.noAssociatedSchool);
        return;
      }

      final currentSchool = schoolProvider.currentSchool;
      if (currentSchool == null) {
        _showErrorDialog(l10n.error, l10n.couldNotGetSchoolInfo);
        return;
      }

      _updateSelectedNivelesFromBooleans();

      final updatedSchool = currentSchool.copyWith(
        nombre: _nombreController.text.trim(),
        codigo: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
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

      final ok = await schoolProvider.updateSchool(updatedSchool);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.settingsUpdated,
              style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(MediaQuery.of(context).size),
              ),
            ),
          ),
        );
      } else {
        _showErrorDialog(l10n.error, schoolProvider.error ?? l10n.unknownError);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context);
      _showErrorDialog(l10n.error, '${l10n.errorSavingChanges}: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            child: Text(AppLocalizations.of(context).ok,
                style: TextStyle(color: AppTheme.accentPurple)),
          ),
        ],
      ),
    );
  }

  void _updateSelectedNivelesFromBooleans() {
    final niveles = <NivelEducativo>[];
    if (_hasPreescolar) niveles.add(NivelEducativo.preescolar);
    if (_hasPrimaria) niveles.add(NivelEducativo.primaria);
    if (_hasSecundaria) niveles.add(NivelEducativo.secundaria);
    if (_hasBachillerato) niveles.add(NivelEducativo.bachillerato);

    if (niveles.isEmpty) {
      // por defecto primaria
      _hasPrimaria = true;
      niveles.add(NivelEducativo.primaria);
    }
    _selectedNiveles = niveles;
  }
}

extension on PlatformDispatcher {
  // para compatibilidad en algunos entornos
  FlutterView? get firstOrNull => views.isNotEmpty ? views.first : null;
}
