import 'package:alertaescolar/components/admin/notifications/section_container.dart';
import 'package:alertaescolar/components/admin/notifications/message_type_option.dart';
import 'package:alertaescolar/components/admin/notifications/recipient_option.dart';
import 'package:alertaescolar/components/admin/notifications/student_selector.dart';
import 'package:alertaescolar/components/admin/notifications/comunicado_type_selector.dart';
import 'package:alertaescolar/components/admin/notifications/priority_selector.dart';
import 'package:alertaescolar/components/admin/notifications/message_content_form.dart';
import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/hints/pull_to_refresh_hint.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/models/notification_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/theme_provider.dart';
import '../../../managers/student_provider.dart';
import '../../../managers/group_provider.dart';
import '../../../managers/turno_provider.dart';
import '../../../managers/user_provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'selectable_students_directory_view.dart';
import '../../../widgets/custom_snack_bar.dart';
import 'notification_review_view.dart';

class NotificationSendView extends StatefulWidget {
  final String? preselectedType;

  const NotificationSendView({
    super.key,
    this.preselectedType,
  });

  @override
  State<NotificationSendView> createState() => _NotificationSendViewState();
}

class _NotificationSendViewState extends State<NotificationSendView>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isNavigating = false;

  String _selectedRecipient = _Recipient.none;
  TipoNotificacion _selectedType = TipoNotificacion.permisoEspecial;

  // Comunicado (enums en models.dart)
  TipoComunicacion _selectedComunicadoType = TipoComunicacion.informativo;
  PrioridadComunicado _selectedPriority = PrioridadComunicado.media;

  // Selecciones
  Alumno? _selectedStudent;
  List<Grupo> _selectedGroups = [];
  List<String> _selectedNivelesEducativos = [];
  Turno? _selectedShift;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get _hasAnyRecipientSelected =>
      _selectedRecipient != _Recipient.none ||
      _selectedStudent != null ||
      _selectedGroups.isNotEmpty ||
      _selectedShift != null;

  void _clearRecipientFilters() {
    setState(() {
      _selectedRecipient = _Recipient.none;
      _selectedStudent = null;
      _selectedGroups.clear();
      _selectedNivelesEducativos.clear();
      _selectedShift = null;
    });
  }

  // --- Listeners para refrescar botón de acción
  void _attachTextListeners() {
    _titleController.addListener(() {
      if (mounted) setState(() {});
    });
    _messageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    if ((widget.preselectedType ?? '').isNotEmpty) {
      // Acepta rutas/strings previos: 'permiso' | 'comunicado'
      final s = widget.preselectedType!.toLowerCase();
      if (s == 'comunicado') _selectedType = TipoNotificacion.comunicado;
      if (s == 'permiso' || s == 'permiso_especial') {
        _selectedType = TipoNotificacion.permisoEspecial;
      }
    }

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();

    _attachTextListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  /// Helper para mostrar snackbars con control de uno activo a la vez
  void _showSnackBar(String message, {bool isError = false}) {
    // Verificar si ya hay un snackbar activo - si es así, no mostrar nuevo
    if (CustomSnackBar.isActive) {
      debugPrint('SnackBar descartado: ya hay uno activo - $message');
      return;
    }

    CustomSnackBar.show(
      context: context,
      message: message,
      isError: isError,
    );
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    // ✅ Asegurar escuelaId desde UserProvider (admin/tutor)
    final escuelaId = await userProvider.ensureEscuelaIdLoaded();

    if (escuelaId == null || escuelaId.trim().isEmpty) {
      debugPrint('NotificationSendView: escuelaId no resuelto');
      if (mounted) {
        _showSnackBar(
          'No se pudo resolver la escuela del usuario. Intenta recargar.',
          isError: true,
        );
      }
      return;
    }

    try {
      await Future.wait([
        groupProvider.loadGroups(escuelaId: escuelaId),
        turnoProvider.loadTurnos(escuelaId: escuelaId),
        studentProvider.loadStudents(escuelaId: escuelaId),
      ]);
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

    // ✅ Reafirmar escuelaId también en el refresh
    final escuelaId = await userProvider.ensureEscuelaIdLoaded();
    if (escuelaId == null || escuelaId.trim().isEmpty) return;

    await Future.wait([
      groupProvider.loadGroups(escuelaId: escuelaId),
      turnoProvider.loadTurnos(escuelaId: escuelaId),
    ]);

    // Limpieza defensiva: si desaparece lo seleccionado
    if (_selectedGroups.isNotEmpty) {
      final ids = groupProvider.grupos.map((g) => g.id).toSet();
      _selectedGroups.removeWhere((g) => !ids.contains(g.id));
    }
    if (_selectedShift != null) {
      final turnoIds = turnoProvider.turnos.map((t) => t.id).toSet();
      if (!turnoIds.contains(_selectedShift!.id)) {
        _selectedShift = null;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Consumer4<ThemeProvider, GroupProvider, TurnoProvider,
        StudentProvider>(
      builder: (context, themeProvider, groupProvider, turnoProvider,
          studentProvider, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: LiquidPullToRefresh(
                onRefresh: _onRefresh,
                color: AppTheme.accentPurple,
                backgroundColor: AppTheme.getBackgroundColor(context),
                height: 120,
                animSpeedFactor: 9.0,
                showChildOpacityTransition: false,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  slivers: [
                    NavHeader(title: l10n.sendNotification),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tipo de mensaje
                            SectionContainer(
                              title: l10n.messageType,
                              screenSize: screenSize,
                              child: Column(
                                children: [
                                  MessageTypeOption(
                                    title: l10n.specialPermission,
                                    value: TipoNotificacion
                                        .permisoEspecial, // <- enum
                                    icon: Icons.assignment_turned_in_rounded,
                                    color: AppTheme.accentBlue,
                                    description:
                                        l10n.requestSpecialPermissionDesc,
                                    screenSize: screenSize,
                                    selectedType: _selectedType,
                                    onSelect: (type) =>
                                        setState(() => _selectedType = type),
                                  ),
                                  SizedBox(
                                      height: AppTheme.getMediumPadding(
                                          screenSize)),
                                  MessageTypeOption(
                                    title: l10n.communication,
                                    value:
                                        TipoNotificacion.comunicado, // <- enum
                                    icon: Icons.campaign_rounded,
                                    color: AppTheme.warningColor,
                                    description:
                                        l10n.sendOfficialCommunicationDesc,
                                    screenSize: screenSize,
                                    selectedType: _selectedType,
                                    onSelect: (type) =>
                                        setState(() => _selectedType = type),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                                height: AppTheme.getLargePadding(screenSize)),

                            // Config de comunicado
                            if (_selectedType ==
                                TipoNotificacion.comunicado) ...[
                              SectionContainer(
                                title: l10n.communicationType,
                                screenSize: screenSize,
                                child: ComunicadoTypeSelector(
                                  selectedType: _selectedComunicadoType,
                                  onTypeSelected: (type) => setState(() {
                                    _selectedComunicadoType = type;
                                    _applyComunicadoSmartDefaults(
                                        type); // <- NUEVO (ver punto 3)
                                  }),
                                  screenSize: screenSize,
                                  enabled: !_isNavigating, // <- NUEVO
                                  enableHaptics: true, // <- NUEVO
                                  // semanticsLabel: l10n.communicationType, // opcional
                                ),
                              ),
                              SizedBox(
                                  height: AppTheme.getLargePadding(screenSize)),
                              SectionContainer(
                                title: l10n.priority,
                                screenSize: screenSize,
                                child: PrioritySelector(
                                  selectedPriority: _selectedPriority,
                                  onPriorityChanged: (p) =>
                                      setState(() => _selectedPriority = p),
                                  screenSize: screenSize,

                                  // NUEVO: inhabilita mientras navegas al review
                                  enabled: !_isNavigating,

                                  // Opcional: háptica al seleccionar prioridad
                                  enableHaptics: true,
                                  // semanticsLabel: l10n.priority, // si quieres sobreescribir etiqueta
                                ),
                              ),
                              SizedBox(
                                  height: AppTheme.getLargePadding(screenSize)),
                            ],

                            // Destinatarios
                            SectionContainer(
                              title: l10n.recipients,
                              screenSize: screenSize,
                              child: Column(
                                children: [
                                  RecipientOption(
                                    title: l10n.individualStudent,
                                    value: _Recipient.individual,
                                    icon: Icons.person_rounded,
                                    description: l10n.selectSpecificStudent,
                                    screenSize: screenSize,
                                    selectedRecipient: _selectedRecipient,
                                    onSelect: (recipient) => setState(
                                        () => _applyRecipientChange(recipient)),
                                  ),
                                  SizedBox(
                                      height:
                                          AppTheme.getSmallPadding(screenSize)),
                                  RecipientOption(
                                    title: l10n.groupClass,
                                    value: _Recipient.grupo,
                                    icon: Icons.group_rounded,
                                    description: l10n.sendToEntireClass,
                                    screenSize: screenSize,
                                    selectedRecipient: _selectedRecipient,
                                    onSelect: (recipient) => setState(
                                        () => _applyRecipientChange(recipient)),
                                  ),
                                  SizedBox(
                                      height:
                                          AppTheme.getSmallPadding(screenSize)),
                                  RecipientOption(
                                    title: l10n.entireShift,
                                    value: _Recipient.turno,
                                    icon: Icons.schedule_rounded,
                                    description: l10n.allStudentsInShift,
                                    screenSize: screenSize,
                                    selectedRecipient: _selectedRecipient,
                                    onSelect: (recipient) => setState(
                                        () => _applyRecipientChange(recipient)),
                                  ),
                                  SizedBox(
                                      height:
                                          AppTheme.getSmallPadding(screenSize)),
                                  RecipientOption(
                                    title: l10n.allStudents,
                                    value: _Recipient.todos,
                                    icon: Icons.school_rounded,
                                    description:
                                        l10n.entireEducationalInstitution,
                                    screenSize: screenSize,
                                    selectedRecipient: _selectedRecipient,
                                    onSelect: (recipient) => setState(
                                        () => _applyRecipientChange(recipient)),
                                  ),

                                  // Controles dinámicos por tipo
                                  if (_selectedRecipient ==
                                      _Recipient.individual) ...[
                                    SizedBox(
                                        height: AppTheme.getMediumPadding(
                                            screenSize)),
                                    StudentSelector(
                                      selectedStudent: _selectedStudent == null
                                          ? null
                                          : {
                                              'id': _selectedStudent!.id,
                                              'escuelaId':
                                                  _selectedStudent!.idEscuela,
                                              'grupoId':
                                                  _selectedStudent!.idGrupo,
                                              'name': _selectedStudent!.nombre,
                                              'matricula':
                                                  _selectedStudent!.matricula,
                                              'nivelEducativo':
                                                  _nivelDesdeDisplayGrupo(
                                                      _selectedStudent!.grupo),
                                              'group': _soloGrupoDesdeDisplay(
                                                  _selectedStudent!.grupo),
                                              'active':
                                                  _selectedStudent!.vinculado,
                                            },
                                      screenSize: screenSize,
                                      onSelectStudent:
                                          _navigateToStudentDirectory,
                                      onClearSelected: () => setState(() =>
                                          _selectedStudent = null), // <- NUEVO
                                    ),
                                  ],
                                  if (_selectedRecipient ==
                                      _Recipient.grupo) ...[
                                    SizedBox(
                                        height: AppTheme.getMediumPadding(
                                            screenSize)),
                                    _buildGroupSelector(context, screenSize),
                                  ],
                                  if (_selectedRecipient ==
                                      _Recipient.turno) ...[
                                    SizedBox(
                                        height: AppTheme.getMediumPadding(
                                            screenSize)),
                                    _buildShiftSelector(context, screenSize),
                                  ],
                                ],
                              ),
                            ),

                            if (_hasAnyRecipientSelected)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _clearRecipientFilters,
                                  icon:
                                      const Icon(Icons.filter_alt_off_outlined),
                                  label: const Text('Limpiar filtros'),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
                              ),
                            SizedBox(
                                height: AppTheme.getSmallPadding(screenSize)),

                            // Contenido del mensaje
                            SectionContainer(
                              title: l10n.messageContent,
                              screenSize: screenSize,
                              child: MessageContentForm(
                                titleController: _titleController,
                                messageController: _messageController,
                                selectedType: _selectedType.dbValue,
                                screenSize: screenSize,
                                onTitleChanged: (_) => setState(() {}),
                                onMessageChanged: (_) => setState(() {}),
                              ),
                            ),

                            SizedBox(
                                height: AppTheme.getLargePadding(screenSize)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomOutlineButton(
                        color: AppTheme.getTextPrimaryColor(
                            context), // color opaco
                        label: l10n.cancel,
                        enableHaptics: true, // delega háptica al botón
                        onPressed: () => Navigator.pop(context),
                        screenSize: screenSize,
                        // opcional: icono para mayor claridad
                        // icon: Icons.close_rounded,
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                    Expanded(
                      flex: 2,
                      child: SolidButton(
                        label: _selectedType == TipoNotificacion.comunicado
                            ? 'Revisar Comunicado'
                            : 'Revisar Permiso',
                        onPressed: _canSendMessage()
                            ? () {
                                HapticFeedback.mediumImpact();
                                _sendNotification();
                              }
                            : null,
                        screenSize: screenSize,
                        icon: Icons.preview_rounded,
                        enableHaptics: false, // ya hacemos Haptic arriba
                        isLoading: _isNavigating, // <- NUEVO
                        showLoaderInIconSlot: true, // mantiene layout
                        // backgroundColor:  // QUITA esta prop para no duplicar lógica de disabled
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // -----------------------------
  // Selectores
  // -----------------------------
  Widget _buildGroupSelector(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        // Estado de carga / error
        if (groupProvider.isLoading) {
          return _InlineLoader(
            text: 'Cargando grupos…',
            color: AppTheme.accentBlue,
            screenSize: screenSize,
          );
        }

        if ((groupProvider.error ?? '').isNotEmpty) {
          return _ErrorBanner(
            message: groupProvider.error!,
            actionLabel: 'Reintentar',
            color: AppTheme.accentBlue,
            onTap: _onRefresh,
            screenSize: screenSize,
          );
        }

        final groupedByLevel = <String, List<Grupo>>{};
        for (final grupo in groupProvider.grupos) {
          groupedByLevel.putIfAbsent(grupo.nivelEducativo, () => []).add(grupo);
        }

        final hasGroups = groupedByLevel.isNotEmpty;

        // Limpieza defensiva si cambió la data en tiempo real
        if (_selectedGroups.isNotEmpty) {
          final ids = groupProvider.grupos.map((g) => g.id).toSet();
          final removed =
              _selectedGroups.where((g) => !ids.contains(g.id)).toList();
          if (removed.isNotEmpty) {
            _selectedGroups.removeWhere((g) => !ids.contains(g.id));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.accentBlue.withOpacity(0.05),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                // ignore: deprecated_member_use
                border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.accentBlue,
                      size: screenSize.height * 0.02),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      hasGroups
                          ? l10n.chooseClassForNotification
                          : 'No hay grupos disponibles',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasGroups)
                    TextButton(
                      onPressed: _onRefresh,
                      child: const Text('Actualizar'),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            if (hasGroups)
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showGroupSelectionDialog(context, groupedByLevel);
                },
                child: Container(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: _selectedGroups.isNotEmpty
                        // ignore: deprecated_member_use
                        ? AppTheme.accentBlue.withOpacity(0.0)
                        : AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: _selectedGroups.isNotEmpty
                          ? AppTheme.accentBlue
                          : AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getShadowColor(context),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: (_selectedGroups.isNotEmpty
                                  ? AppTheme.accentBlue
                                  : AppTheme.getBorderColor(context))
                              // ignore: deprecated_member_use
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          Icons.class_rounded,
                          color: _selectedGroups.isNotEmpty
                              ? AppTheme.accentBlue
                              : AppTheme.getTextSecondaryColor(context),
                          size: screenSize.height * 0.025,
                        ),
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedGroups.isNotEmpty
                                  ? '${_selectedGroups.length} grupos seleccionados'
                                  : l10n.selectClass,
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: _selectedGroups.isNotEmpty
                                    ? AppTheme.getTextPrimaryColor(context)
                                    : AppTheme.getTextSecondaryColor(context),
                                fontWeight: _selectedGroups.isNotEmpty
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                                height:
                                    AppTheme.getSmallPadding(screenSize) * 0.3),
                            Text(
                              _selectedGroups.isNotEmpty
                                  ? _selectedGroups
                                      .map((g) => g.grupo)
                                      .join(', ')
                                  : l10n.tapToChooseClass,
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize) * 0.6),
                        decoration: BoxDecoration(
                          color: _selectedGroups.isNotEmpty
                              // ignore: deprecated_member_use
                              ? AppTheme.accentBlue.withOpacity(0.15)
                              : AppTheme.getBorderColor(context)
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          _selectedGroups.isNotEmpty
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          color: _selectedGroups.isNotEmpty
                              ? AppTheme.accentBlue
                              : AppTheme.getTextSecondaryColor(context),
                          size: screenSize.height * 0.022,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildShiftSelector(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Consumer<TurnoProvider>(
      builder: (context, turnoProvider, child) {
        // Estado de carga / error
        if (turnoProvider.isLoading) {
          return _InlineLoader(
            text: 'Cargando turnos…',
            color: AppTheme.accentOrange,
            screenSize: screenSize,
          );
        }

        if ((turnoProvider.error ?? '').isNotEmpty) {
          return _ErrorBanner(
            message: turnoProvider.error!,
            actionLabel: 'Reintentar',
            color: AppTheme.accentOrange,
            onTap: _onRefresh,
            screenSize: screenSize,
          );
        }

        final hasTurnos = turnoProvider.turnos.isNotEmpty;

        // Limpieza defensiva si cambió la data en tiempo real
        if (_selectedShift != null) {
          final ids = turnoProvider.turnos.map((t) => t.id).toSet();
          if (!ids.contains(_selectedShift!.id)) {
            _selectedShift = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.accentOrange.withOpacity(0.05),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border:
                    // ignore: deprecated_member_use
                    Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.accentOrange,
                      size: screenSize.height * 0.02),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      hasTurnos
                          ? l10n.allStudentsInShift
                          : 'No hay turnos disponibles',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasTurnos)
                    TextButton(
                      onPressed: _onRefresh,
                      child: const Text('Actualizar'),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            if (hasTurnos)
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showShiftSelectionDialog(context, turnoProvider.turnos);
                },
                child: Container(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: _selectedShift != null
                        // ignore: deprecated_member_use
                        ? AppTheme.accentOrange.withOpacity(0.0)
                        : AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: _selectedShift != null
                          ? AppTheme.accentOrange
                          : AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getShadowColor(context),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: (_selectedShift != null
                                  ? AppTheme.accentOrange
                                  : AppTheme.getBorderColor(context))
                              // ignore: deprecated_member_use
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          Icons.schedule_rounded,
                          color: _selectedShift != null
                              ? AppTheme.accentOrange
                              : AppTheme.getTextSecondaryColor(context),
                          size: screenSize.height * 0.025,
                        ),
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedShift?.turno ?? 'Seleccionar turno',
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: _selectedShift != null
                                    ? AppTheme.getTextPrimaryColor(context)
                                    : AppTheme.getTextSecondaryColor(context),
                                fontWeight: _selectedShift != null
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                                height:
                                    AppTheme.getSmallPadding(screenSize) * 0.3),
                            Text(
                              _selectedShift != null
                                  ? _selectedShift!.horarioCompleto
                                  : 'Toca para elegir turno',
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize) * 0.6),
                        decoration: BoxDecoration(
                          color: _selectedShift != null
                              // ignore: deprecated_member_use
                              ? AppTheme.accentOrange.withOpacity(0.15)
                              : AppTheme.getBorderColor(context)
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          _selectedShift != null
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          color: _selectedShift != null
                              ? AppTheme.accentOrange
                              : AppTheme.getTextSecondaryColor(context),
                          size: screenSize.height * 0.022,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // -----------------------------
  // Diálogos
  // -----------------------------
  void _showGroupSelectionDialog(
    BuildContext context,
    Map<String, List<Grupo>> groupedByLevel,
  ) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Estado temporal
    List<Grupo> tempSelectedGroups = List<Grupo>.from(_selectedGroups);
    List<String> tempSelectedLevels =
        List<String>.from(_selectedNivelesEducativos);

    // Niveles INICIAN COLAPSADOS
    final Map<String, bool> expandedByLevel = {
      for (final entry in groupedByLevel.entries) entry.key: false,
    };

    // Shorthands de estilo
    final Color border = AppTheme.getBorderColor(context);
    final double rSmall = AppTheme.getSmallRadius(screenSize);
    final double rMed = AppTheme.getMediumRadius(screenSize);
    final double rLg = AppTheme.getLargeRadius(screenSize);
    final double pXs = AppTheme.getSmallPadding(screenSize) * 0.5;
    final double pSm = AppTheme.getSmallPadding(screenSize);
    final double pMd = AppTheme.getMediumPadding(screenSize);

    bool isLevelFullySelected(String level, List<Grupo> groups) {
      return groups.every((g) => tempSelectedGroups.contains(g));
    }

    void toggleLevel(String level, List<Grupo> groups, bool select) {
      if (select) {
        if (!tempSelectedLevels.contains(level)) tempSelectedLevels.add(level);
        for (final g in groups) {
          if (!tempSelectedGroups.contains(g)) tempSelectedGroups.add(g);
        }
      } else {
        tempSelectedLevels.remove(level);
        tempSelectedGroups.removeWhere((g) => groups.contains(g));
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Tile súper compacto de grupo con indentación/guía
          Widget groupTile(Grupo group, {required Color accent}) {
            final selected = tempSelectedGroups.contains(group);
            return InkWell(
              onTap: () {
                setDialogState(() {
                  if (selected) {
                    tempSelectedGroups.remove(group);
                    tempSelectedLevels.remove(group.nivelEducativo);
                  } else {
                    tempSelectedGroups.add(group);
                    final levelGroups =
                        groupedByLevel[group.nivelEducativo] ?? [];
                    if (levelGroups.isNotEmpty &&
                        levelGroups
                            .every((g) => tempSelectedGroups.contains(g))) {
                      if (!tempSelectedLevels.contains(group.nivelEducativo)) {
                        tempSelectedLevels.add(group.nivelEducativo);
                      }
                    }
                  }
                });
              },
              borderRadius: BorderRadius.circular(rMed),
              child: Container(
                // CONTENEDOR MÁS BAJO
                padding:
                    EdgeInsets.symmetric(horizontal: pSm, vertical: pXs * 0.6),
                decoration: BoxDecoration(
                  color: selected
                      // ignore: deprecated_member_use
                      ? AppTheme.accentBlue.withOpacity(0.06)
                      : AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(rMed),
                  border: Border.all(
                      color: selected ? accent : border,
                      width: selected ? 2 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Checkbox pequeño y denso
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: selected,
                        onChanged: (_) {},
                        activeColor: accent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                      ),
                    ),
                    SizedBox(width: pXs),
                    // Etiqueta compacta
                    Text(
                      group.grupo,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }

          // Header del nivel (checkbox maestro + expand/collapse)
          Widget levelHeader(String level, List<Grupo> groups) {
            final accent = AppTheme.accentBlue;
            final fully = isLevelFullySelected(level, groups);
            final partially =
                !fully && groups.any((g) => tempSelectedGroups.contains(g));
            final expanded = expandedByLevel[level] ?? false;

            return Container(
              padding: EdgeInsets.all(pSm),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(rMed),
                // ignore: deprecated_member_use
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  // Checkbox maestro (triestado)
                  Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: Theme.of(context).checkboxTheme.copyWith(
                            visualDensity: const VisualDensity(
                                horizontal: -2, vertical: -2),
                          ),
                    ),
                    child: Checkbox(
                      value: fully ? true : (partially ? null : false),
                      tristate: true,
                      onChanged: (val) {
                        setDialogState(() {
                          final select = (val ?? false);
                          toggleLevel(level, groups, select);
                        });
                      },
                      activeColor: accent,
                    ),
                  ),
                  SizedBox(width: pSm * 0.6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level,
                          style: AppTheme.getBodyLarge(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${groups.length} grupos',
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setDialogState(() {
                        expandedByLevel[level] = !expanded;
                      });
                    },
                    icon: Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            );
          }

          // Sección del nivel con INDENTACIÓN y GRID compacto
          Widget levelSection(String level, List<Grupo> groups) {
            final accent = AppTheme.accentBlue;
            final expanded = expandedByLevel[level] ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                levelHeader(level, groups),
                if (expanded) ...[
                  SizedBox(height: pSm),

                  // INDENTACIÓN + guía visual a la izquierda
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          // ignore: deprecated_member_use
                          color: accent.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: pSm), // sangría de clases
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // grid súper compacto
                          const double minTileWidth = 140; // más angosto
                          int columns = (constraints.maxWidth / minTileWidth)
                              .floor()
                              .clamp(1, 5);
                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: pSm,
                              mainAxisSpacing: pSm * 0.8,
                              // MÁS PLANO (menos alto)
                              childAspectRatio: 2,
                            ),
                            itemCount: groups.length,
                            itemBuilder: (context, i) =>
                                groupTile(groups[i], accent: accent),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                SizedBox(height: pSm),
              ],
            );
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rLg),
            ),
            elevation: 8,
            child: Container(
              width: screenSize.width * 0.9,
              constraints: BoxConstraints(maxHeight: screenSize.height * 0.75),
              padding: EdgeInsets.all(pMd),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(rLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(pSm * 0.8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppTheme.accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(rSmall),
                        ),
                        child: Icon(
                          Icons.class_rounded,
                          color: AppTheme.accentBlue,
                          size: screenSize.height * 0.025,
                        ),
                      ),
                      SizedBox(width: pMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.selectClass,
                              style: AppTheme.getH2(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.chooseClassForNotification,
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: pMd),

                  // Contenido
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupedByLevel.entries.map((e) {
                          return levelSection(e.key, e.value);
                        }).toList(),
                      ),
                    ),
                  ),

                  SizedBox(height: pMd),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: pMd),
                            side: BorderSide(color: border),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: pMd),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedGroups = tempSelectedGroups;
                              _selectedNivelesEducativos = tempSelectedLevels;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue,
                            padding: EdgeInsets.symmetric(vertical: pMd),
                          ),
                          child: Text(
                            'Confirmar',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showShiftSelectionDialog(BuildContext context, List<Turno> turnos) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    Turno? tempSelectedShift = _selectedShift;

    Color border = AppTheme.getBorderColor(context);
    final double rSmall = AppTheme.getSmallRadius(screenSize);
    final double rMed = AppTheme.getMediumRadius(screenSize);
    final double pSm = AppTheme.getSmallPadding(screenSize);
    final double pMd = AppTheme.getMediumPadding(screenSize);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Widget buildRadioTile({
            required bool selected,
            required VoidCallback onTap,
            required Widget title,
            Widget? subtitle,
            required Color accent,
            EdgeInsetsGeometry? margin,
          }) {
            return InkWell(
              borderRadius: BorderRadius.circular(rMed),
              onTap: onTap,
              child: Container(
                margin: margin ?? EdgeInsets.only(bottom: pSm),
                padding: EdgeInsets.all(pMd),
                decoration: BoxDecoration(
                  color: selected
                      // ignore: deprecated_member_use
                      ? accent.withOpacity(0.06)
                      : AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(rMed),
                  border: Border.all(
                      color: selected ? accent : border,
                      width: selected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    // Icon chip
                    Container(
                      padding: EdgeInsets.all(pSm),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(rSmall),
                      ),
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: selected
                            ? accent
                            : AppTheme.getTextSecondaryColor(context),
                        size: screenSize.height * 0.024,
                      ),
                    ),
                    SizedBox(width: pMd),

                    // Textos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style: AppTheme.getBodyLarge(screenSize).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                            child: title,
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: pSm * 0.4),
                            DefaultTextStyle(
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                              child: subtitle,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Radio visual
                    Radio<bool>(
                      value: true,
                      groupValue: selected,
                      onChanged: (_) => onTap(),
                      activeColor: accent,
                    ),
                  ],
                ),
              ),
            );
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            ),
            elevation: 8,
            child: Container(
              width: screenSize.width * 0.9,
              constraints: BoxConstraints(maxHeight: screenSize.height * 0.7),
              padding: EdgeInsets.all(pMd),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(pSm * 0.8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(rSmall),
                        ),
                        child: Icon(Icons.schedule_rounded,
                            color: AppTheme.accentOrange,
                            size: screenSize.height * 0.025),
                      ),
                      SizedBox(width: pMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar turno',
                              style: AppTheme.getH2(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.allStudentsInShift,
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded,
                            color: AppTheme.getTextSecondaryColor(context)),
                      ),
                    ],
                  ),
                  SizedBox(height: pMd),

                  // Lista de turnos (MISMO estilo que grupos, sin sombra)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: turnos.map((turno) {
                          final selected = tempSelectedShift?.id == turno.id;
                          return buildRadioTile(
                            selected: selected,
                            accent: AppTheme.accentOrange,
                            onTap: () {
                              setDialogState(() {
                                tempSelectedShift = turno;
                              });
                            },
                            title: Text(turno.turno),
                            subtitle: Text(turno.horarioCompleto),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  SizedBox(height: pMd),

                  // Botones (idénticos en layout a grupos)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: pMd),
                            side: BorderSide(color: border),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: pMd),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedShift = tempSelectedShift;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentOrange,
                            padding: EdgeInsets.symmetric(vertical: pMd),
                          ),
                          child: Text(
                            'Confirmar',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToStudentDirectory() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectableStudentsDirectoryView(
          selectionMode: true,
          allowMultiSelect: false,
        ),
      ),
    );

    if (!mounted || result == null) return;

    try {
      // 1) ya es un Alumno
      if (result is Alumno) {
        setState(() => _selectedStudent = result);
        return;
      }

      // 2) contrato unificado
      if (result is Map) {
        if (result['alumno'] is Map<String, dynamic>) {
          final alumno = Alumno.fromJson(
              Map<String, dynamic>.from(result['alumno'] as Map));
          setState(() => _selectedStudent = alumno);
          return;
        }
        if (result['alumnos'] is List &&
            (result['alumnos'] as List).isNotEmpty) {
          final primero = Map<String, dynamic>.from(
              (result['alumnos'] as List).first as Map);
          final alumno = Alumno.fromJson(primero);
          setState(() => _selectedStudent = alumno);
          return;
        }

        // 3) fila SQL-like
        if (result['id_alumno'] != null) {
          setState(() {
            _selectedStudent = Alumno(
              id: (result['id_alumno'] ?? '').toString(),
              nombre: (result['nombre'] ?? '').toString(),
              idGrupo: (result['id_grupo'] ?? '').toString(),
              grupo:
                  (result['grupo_display'] ?? result['grupo'] ?? '').toString(),
              idEscuela: (result['id_escuela'] ?? '').toString(),
              matricula: (result['matricula'] ?? '').toString(),
              fechaRegistro: DateTime.tryParse(
                    (result['fecha_registro'] ??
                            DateTime.now().toIso8601String())
                        .toString(),
                  ) ??
                  DateTime.now(),
              idTurno: (result['id_turno'] ?? '').toString(),
              turno: TurnoEnum.desconocido,
              idLlave: result['id_llave']?.toString(),
              vinculado: (result['vinculado'] ?? false) == true,
            );
          });
          return;
        }

        // 4) fallback: intentar parsear el propio map como Alumno JSON
        if (result is Map<String, dynamic>) {
          final alumno = Alumno.fromJson(result);
          setState(() => _selectedStudent = alumno);
          return;
        }
      }
    } catch (e) {
      debugPrint('Seleccion de alumno error: $e');
    }
  }

  bool _hasValidRecipient() => switch (_selectedRecipient) {
        _Recipient.individual => _selectedStudent != null,
        _Recipient.grupo => _selectedGroups.isNotEmpty,
        _Recipient.turno => _selectedShift != null,
        _Recipient.todos => true,
        _Recipient.none => false,
        _ => false,
      };

  bool _canSendMessage() {
    final titleOk = _titleController.text.trim().isNotEmpty;
    final msgOk = _messageController.text.trim().isNotEmpty;
    return titleOk && msgOk && _hasValidRecipient();
  }

  int _priorityRank(PrioridadComunicado p) {
    switch (p) {
      case PrioridadComunicado.baja:
        return 0;
      case PrioridadComunicado.media:
        return 1;
      case PrioridadComunicado.alta:
        return 2;
      case PrioridadComunicado.critica:
        return 3;
    }
  }

  PrioridadComunicado _suggestedPriorityFor(TipoComunicacion t) {
    switch (t) {
      case TipoComunicacion.emergencia:
        return PrioridadComunicado.critica;
      case TipoComunicacion.suspencionClases:
        return PrioridadComunicado.alta;
      case TipoComunicacion.cambioHorario:
      case TipoComunicacion.recordatorioPago:
      case TipoComunicacion.citatorio:
      case TipoComunicacion.evento:
      case TipoComunicacion.paseo:
        return PrioridadComunicado.media;
      case TipoComunicacion.celebracion:
      case TipoComunicacion.informativo:
        return PrioridadComunicado.baja;
    }
  }

  void _applyRecipientChange(String recipient) {
    _selectedRecipient = recipient;

    // Limpia selecciones incompatibles
    switch (recipient) {
      case _Recipient.individual:
        _selectedGroups.clear();
        _selectedShift = null;
        break;
      case _Recipient.grupo:
        _selectedStudent = null;
        _selectedShift = null;
        break;
      case _Recipient.turno:
        _selectedStudent = null;
        _selectedGroups.clear();
        break;
      case _Recipient.todos:
        _selectedStudent = null;
        _selectedGroups.clear();
        _selectedShift = null;
        break;
    }

    setState(() {}); // refresca UI

    // 🔔 Auto-abrir el picker correspondiente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openRecipientPickerIfNeeded();
    });
  }

  void _openRecipientPickerIfNeeded() {
    switch (_selectedRecipient) {
      case _Recipient.individual:
        HapticFeedback.selectionClick();
        _navigateToStudentDirectory();
        break;

      case _Recipient.grupo:
        // Construye groupedByLevel desde el provider
        final groupProvider =
            Provider.of<GroupProvider>(context, listen: false);
        final groupedByLevel = <String, List<Grupo>>{};
        for (final g in groupProvider.grupos) {
          groupedByLevel.putIfAbsent(g.nivelEducativo, () => []).add(g);
        }
        if (groupedByLevel.isNotEmpty) {
          HapticFeedback.selectionClick();
          _showGroupSelectionDialog(context, groupedByLevel);
        }
        break;

      case _Recipient.turno:
        final turnoProvider =
            Provider.of<TurnoProvider>(context, listen: false);
        if (turnoProvider.turnos.isNotEmpty) {
          HapticFeedback.selectionClick();
          _showShiftSelectionDialog(context, turnoProvider.turnos);
        }
        break;

      case _Recipient.todos:
      default:
        // No hay modal que abrir
        break;
    }
  }

  void _applyComunicadoSmartDefaults(TipoComunicacion t) {
    final suggested = _suggestedPriorityFor(t);

    // No bajar prioridad si ya es más alta:
    if (_priorityRank(suggested) > _priorityRank(_selectedPriority)) {
      _selectedPriority = suggested;
    }

    setState(() {}); // refrescar UI si se llama desde onTypeSelected
  }

  void _sendNotification() async {
    if (_isNavigating) return;

    final ok = await _validateForm();
    if (!ok) return;

    setState(() => _isNavigating = true);
    // ignore: use_build_context_synchronously
    FocusScope.of(context).unfocus();

    final draft = _buildDraft();

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => NotificationReviewView(draft: draft),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  NotificationDraft _buildDraft() {
    // NOTA: Validaciones de estudiantes activos:
    // - Para 'individual': Se valida aquí en frontend (_validateIndividualStudentActive)
    // - Para 'grupo'/'turno'/'todos': Se filtran automáticamente en backend (NotificationSendService._filterActiveStudents)
    //
    // Un estudiante se considera activo si:
    // 1. Tiene tutores registrados en alumno_tutores
    // 2. Tiene llave activa (llaves.activo = true)
    // 3. Está dentro de la ventana de vigencia de la llave
    return NotificationDraft(
      tipoMensaje: _selectedType.dbValue, // 'permiso'|'comunicado'
      tipoDestinatario:
          _selectedRecipient, // 'individual'|'grupo'|'turno'|'todos'
      titulo: _titleController.text.trim(),
      mensaje: _messageController.text.trim(),
      tipoComunicado: _selectedType == TipoNotificacion.comunicado
          ? _selectedComunicadoType.dbValue
          : null,
      prioridad: _selectedType == TipoNotificacion.comunicado
          ? _selectedPriority.dbValue
          : null,
      alumnoId: _selectedRecipient == _Recipient.individual
          ? _selectedStudent?.id
          : null,
      grupoIds: _selectedRecipient == _Recipient.grupo
          ? _selectedGroups.map((g) => g.id).toList()
          : null,
      turnoId:
          _selectedRecipient == _Recipient.turno ? _selectedShift?.id : null,
    );
  }

  Future<bool> _validateForm() async {
    final title = _titleController.text.trim();
    final body = _messageController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Por favor ingresa un título para el mensaje',
          isError: true);
      return false;
    }
    if (body.isEmpty) {
      _showSnackBar('Por favor ingresa el contenido del mensaje',
          isError: true);
      return false;
    }
    if (title.length < 3) {
      _showSnackBar('El título es muy corto', isError: true);
      return false;
    }

    // ✅ Alineado a MessageContentForm (maxTitleLength:80, maxMessageLength:500)
    if (title.length > 80) {
      _showSnackBar('El título no debe exceder 80 caracteres', isError: true);
      return false;
    }
    if (body.length > 500) {
      _showSnackBar('El mensaje no debe exceder 500 caracteres', isError: true);
      return false;
    }

    // ✅ Validación de destinatario con switch expression (Dart 3)
    final hasValidRecipient = switch (_selectedRecipient) {
      _Recipient.individual => _selectedStudent != null,
      _Recipient.grupo => _selectedGroups.isNotEmpty,
      _Recipient.turno => _selectedShift != null,
      _Recipient.todos => true,
      _ => false,
    };

    if (!hasValidRecipient) {
      _showSnackBar('Por favor elige al menos un destinatario válido',
          isError: true);
      return false;
    }

    // ✅ Coherencia SQL/escuela cuando es individual (usa id_escuela del alumno)
    if (_selectedRecipient == _Recipient.individual &&
        _selectedStudent != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final escuelaActual = await userProvider.ensureEscuelaIdLoaded();
      final escuelaAlumno = (_selectedStudent!.idEscuela).toString();

      if ((escuelaActual ?? '').isEmpty ||
          escuelaAlumno != (escuelaActual ?? '')) {
        _showSnackBar('El alumno seleccionado no pertenece a tu escuela.',
            isError: true);
        return false;
      }

      // ✅ NUEVA VALIDACIÓN: Para estudiante individual, verificar que esté activo
      final isStudentActive =
          await _validateIndividualStudentActive(_selectedStudent!);
      if (!isStudentActive) {
        return false; // El error ya se mostró en _validateIndividualStudentActive
      }
    }

    return true;
  }

  /// Valida que un estudiante individual esté activo según las mismas reglas que selectable_students_directory_view
  /// Un estudiante está activo si:
  /// 1. Tiene tutores registrados (hasTutores)
  /// 2. Está dentro de la ventana de vigencia de la llave
  Future<bool> _validateIndividualStudentActive(Alumno student) async {
    try {
      final supabase = Supabase.instance.client;

      // Verificar si tiene tutores registrados (equivalent to student.hasTutores)
      final tutorResponse = await supabase
          .from('alumno_tutores')
          .select('id')
          .eq('id_alumno', student.id)
          .limit(1);

      final hasTutores = tutorResponse.isNotEmpty;

      if (!hasTutores) {
        _showSnackBar(
          'No se puede enviar comunicado a un estudiante sin tutores registrados',
          isError: true,
        );
        return false;
      }

      // Verificar ventana de vigencia de la llave (equivalent to dentroVentana logic)
      final llaveResponse = await supabase
          .from('llaves')
          .select('fecha_registro, fecha_desactivacion, activo')
          .eq('id_alumno', student.id)
          .maybeSingle();

      if (llaveResponse != null) {
        final now = DateTime.now();
        final fechaRegistroLlave = llaveResponse['fecha_registro'] != null
            ? DateTime.parse(llaveResponse['fecha_registro'].toString())
            : null;
        final fechaDesactivacionLlave = llaveResponse['fecha_desactivacion'] !=
                null
            ? DateTime.parse(llaveResponse['fecha_desactivacion'].toString())
            : null;
        final llaveActiva = llaveResponse['activo'] == true;

        // Usar fecha_registro del alumno si no hay fecha_registro de llave
        final start = fechaRegistroLlave ?? student.fechaRegistro;
        final end = fechaDesactivacionLlave;

        final dentroVentana =
            !now.isBefore(start) && (end == null || !now.isAfter(end));

        if (!llaveActiva || !dentroVentana) {
          _showSnackBar(
            'No se puede enviar comunicado a un estudiante inactivo o con llave expirada',
            isError: true,
          );
          return false;
        }
      } else {
        // No tiene llave asignada
        _showSnackBar(
          'No se puede enviar comunicado a un estudiante sin llave asignada',
          isError: true,
        );
        return false;
      }

      return true;
    } catch (e) {
      _showSnackBar('Error al validar el estudiante: $e', isError: true);
      return false;
    }
  }

  String _nivelDesdeDisplayGrupo(String display) {
    // Espera formatos como "Primaria - 3°B" o "Secundaria - 1°A"
    final parts = display.split(' - ');
    return parts.length >= 2 ? parts.first.trim() : '';
  }

  String _soloGrupoDesdeDisplay(String display) {
    final parts = display.split(' - ');
    return parts.length >= 2 ? parts.last.trim() : display.trim();
  }
}

// -----------------------------
// Constantes de opción
// -----------------------------
class _Recipient {
  static const none = 'none';
  static const individual = 'individual';
  static const grupo = 'grupo';
  static const turno = 'turno';
  static const todos = 'todos';
}

/// -----------------------------
/// Widgets auxiliares inline
/// -----------------------------
class _InlineLoader extends StatelessWidget {
  final String text;
  final Color color;
  final Size screenSize;
  const _InlineLoader({
    required this.text,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenSize.height * 0.024,
            height: screenSize.height * 0.024,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: color),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              text,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onTap;
  final Color color;
  final Size screenSize;
  const _ErrorBanner({
    required this.message,
    required this.actionLabel,
    required this.onTap,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: color),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              message,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
