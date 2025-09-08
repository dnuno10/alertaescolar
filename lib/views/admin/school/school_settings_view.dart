// lib/views/school/school_settings_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final _informationFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  // Controllers (solo columnas de `escuelas`)
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _sitioWebController = TextEditingController();

  // Focus
  final _nombreFocusNode = FocusNode();
  final _codigoFocusNode = FocusNode();
  final _descripcionFocusNode = FocusNode();
  final _direccionFocusNode = FocusNode();
  final _telefonoFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _sitioWebFocusNode = FocusNode();

  // Estado
  TipoEscuela _selectedTipo = TipoEscuela.publica;
  bool _isLoading = false;
  bool _formDirty = false; // evita clobber de UI durante edición

  // Listeners y referencias seguras a providers
  VoidCallback? _providerListener;
  VoidCallback? _userListener;
  SchoolProvider? _sp;
  UserProvider? _up;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    // Cualquier cambio en los campos marca el form como "sucio"
    for (final c in [
      _nombreController,
      _codigoController,
      _descripcionController,
      _direccionController,
      _telefonoController,
      _emailController,
      _sitioWebController,
    ]) {
      c.addListener(() {
        _formDirty = true;
      });
    }

    // Carga inicial tras el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolData();
    });
  }

  /// Obtiene referencias a los providers de manera segura y (re)adjunta listeners
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newSp = context.read<SchoolProvider>();
    final newUp = context.read<UserProvider>();

    // Si cambió alguna instancia del provider, limpia listeners previos y re-anexa
    final spChanged = !identical(_sp, newSp);
    final upChanged = !identical(_up, newUp);

    if (spChanged && _sp != null && _providerListener != null) {
      _sp!.removeListener(_providerListener!);
    }
    if (upChanged && _up != null && _userListener != null) {
      _up!.removeListener(_userListener!);
    }

    _sp = newSp;
    _up = newUp;

    // Crear listeners si no existen (o recrearlos si cambiaron instancias)
    _providerListener ??= () {
      final s = _sp?.currentSchool;
      if (s == null || !mounted) return;
      if (_formDirty) return; // no sobreescribir mientras el usuario edita
      _populateControllers(s);
      if (mounted) setState(() {}); // refresca dropdown, etc.
    };

    _userListener ??= () async {
      if (!mounted) return;
      final id = _up?.currentUser?.escuelaId;
      if (id == null || id.isEmpty) return;
      if (_sp?.currentSchool?.id == id) return;
      if (_formDirty) return; // no recargar en medio de edición
      await _loadSchoolData();
    };

    // Adjuntar listeners a las instancias actuales
    _sp!.addListener(_providerListener!);
    _up!.addListener(_userListener!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();

    // ⚠️ No usar `context.read` aquí: el Element ya puede estar desactivado.
    if (_providerListener != null && _sp != null) {
      _sp!.removeListener(_providerListener!);
    }
    if (_userListener != null && _up != null) {
      _up!.removeListener(_userListener!);
    }

    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _sitioWebController.dispose();

    _nombreFocusNode.dispose();
    _codigoFocusNode.dispose();
    _descripcionFocusNode.dispose();
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

  void _populateControllers(Escuela school) {
    if (!_nombreFocusNode.hasFocus) _nombreController.text = school.nombre;
    if (!_codigoFocusNode.hasFocus)
      _codigoController.text = school.codigo ?? '';
    if (!_descripcionFocusNode.hasFocus) {
      _descripcionController.text = school.descripcion ?? '';
    }
    if (!_direccionFocusNode.hasFocus)
      _direccionController.text = school.direccion;
    if (!_telefonoFocusNode.hasFocus)
      _telefonoController.text = school.telefono;
    if (!_emailFocusNode.hasFocus) _emailController.text = school.email;
    if (!_sitioWebFocusNode.hasFocus)
      _sitioWebController.text = school.sitioWeb ?? '';

    // Solo cambia el dropdown si no hay edición en curso
    if (!_formDirty) _selectedTipo = school.tipo;
  }

  Future<void> _loadSchoolData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userProvider = _up ?? context.read<UserProvider>();
      final schoolProvider = _sp ?? context.read<SchoolProvider>();
      final l10n = AppLocalizations.of(context);

      // 🚫 sin polling: usa el contrato del UserProvider
      String escuelaId;
      try {
        escuelaId = await userProvider.ensureEscuelaIdOrThrow();
      } catch (_) {
        _showErrorDialog(l10n.error, l10n.noAssociatedSchool);
        return;
      }

      // Carga inicial (sin watcher/polling)
      final school =
          await schoolProvider.loadSchool(escuelaId, forceRefresh: true);

      if (school != null && mounted) {
        // Este repoblamiento es inicial, no está "sucio"
        _formDirty = false;
        _populateControllers(school);
        setState(() {}); // refresca UI
      } else if (school == null && userProvider.isAdmin()) {
        if (!mounted) return;
        _nombreController.text = '';
        _codigoController.text = '';
        _descripcionController.text = '';
        _direccionController.text = '';
        _telefonoController.text = '';
        _emailController.text = userProvider.currentUser?.email ?? '';
        _sitioWebController.text = '';
        _selectedTipo = TipoEscuela.publica;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.couldNotGetSchoolInfo,
                style:
                    AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
      } else if (school == null) {
        final msg = (schoolProvider.error?.isNotEmpty ?? false)
            ? '${l10n.errorLoadingSchoolInfo}: ${schoolProvider.error}'
            : l10n.couldNotGetSchoolInfo;
        _showErrorDialog(l10n.error, msg);
      }
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

    final headerHeight = MediaQuery.of(context).padding.top +
        AppTheme.getSmallPadding(screenSize) +
        AppTheme.getMediumPadding(screenSize) +
        AppTheme.getH1(screenSize).fontSize! +
        AppTheme.getBodyMedium(screenSize).fontSize! +
        AppTheme.getMediumPadding(screenSize) * 2 +
        64;

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
                // Header + Tabs
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
                          selectedTipo: _selectedTipo,
                          onTipoChanged: (tipo) =>
                              setState(() => _selectedTipo = tipo),
                          isLoading: _isLoading,
                          onSave: _saveSettings,
                          getTipoLabel: _getTipoLabel,
                          nombreFocusNode: _nombreFocusNode,
                          codigoFocusNode: _codigoFocusNode,
                          descripcionFocusNode: _descripcionFocusNode,
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

                // Botón Guardar
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

  Future<void> _saveSettings() async {
    final isInformationTab = _tabController.index == 0;
    final formKey = isInformationTab ? _informationFormKey : _contactFormKey;
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final l10n = AppLocalizations.of(context);

    // Guard temprano de sesión (evita UPDATE anónimo/RLS)
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) {
      _showErrorDialog(l10n.error,
          'Tu sesión ha expirado. Inicia sesión e intenta de nuevo.');
      return;
    }

    final missing = <String>[];
    if (_nombreController.text.trim().isEmpty) missing.add(l10n.schoolName);
    if (_direccionController.text.trim().isEmpty) missing.add(l10n.address);
    if (_telefonoController.text.trim().isEmpty) missing.add(l10n.phone);
    if (_emailController.text.trim().isEmpty) missing.add(l10n.email);

    if (missing.isNotEmpty) {
      _showErrorDialog(
        l10n.requiredFields,
        '${l10n.pleaseCompleteFields}:\n- ${missing.join('\n- ')}',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userProvider = _up ?? context.read<UserProvider>();
      final schoolProvider = _sp ?? context.read<SchoolProvider>();

      // Asegura escuelaId mediante el contrato del provider
      String escuelaId;
      try {
        escuelaId = await userProvider.ensureEscuelaIdOrThrow();
      } catch (_) {
        _showErrorDialog(l10n.error, l10n.noAssociatedSchool);
        return;
      }

      final currentSchool = schoolProvider.currentSchool;
      if (currentSchool == null || currentSchool.id != escuelaId) {
        _showErrorDialog(l10n.error, l10n.couldNotGetSchoolInfo);
        return;
      }

      final updatedSchool = currentSchool.copyWith(
        nombre: _nombreController.text.trim(),
        codigo: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
        tipo: _selectedTipo,
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
        _formDirty = false; // ya no está sucio
        _populateControllers(updatedSchool); // asegura UI consistente

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
}

extension on PlatformDispatcher {
  FlutterView? get firstOrNull => views.isNotEmpty ? views.first : null;
}
