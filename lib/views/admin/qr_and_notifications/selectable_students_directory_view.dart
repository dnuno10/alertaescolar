import 'dart:async';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../utils/modern_dropdown.dart';

class SelectableStudentsDirectoryView extends StatefulWidget {
  final bool selectionMode;
  final bool allowMultiSelect;
  final Map<String, dynamic>? arguments;

  const SelectableStudentsDirectoryView({
    super.key,
    this.selectionMode = true,
    this.allowMultiSelect = false,
    this.arguments,
  });

  @override
  State<SelectableStudentsDirectoryView> createState() =>
      _SelectableStudentsDirectoryViewState();
}

class _SelectableStudentsDirectoryViewState
    extends State<SelectableStudentsDirectoryView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Para anclar el overlay de sugerencias al input
  final LayerLink _searchFieldLink = LayerLink();
  final GlobalKey _searchFieldKey = GlobalKey();
  double _searchFieldWidth = 0;
  double _searchFieldHeight = 0;
  OverlayEntry? _suggestionsOverlay;

  // Debounce para tecleo
  Timer? _debounce;

  // Filtros (renombrados para reflejar columnas reales)
  String _selectedNivelEducativo =
      'all'; // grupos.nivel_educativo (o nombre de niveles_educativos)
  String _selectedGrupoNombre = 'all'; // grupos.grupo
  String _selectedEstado =
      'all'; // 'all' | 'active' | 'inactive' (active = alumno_tutores + llave.activo)
  String _selectedTurnoNombre = 'all'; // turnos.turno

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchTextChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        _removeSuggestionsOverlay();
      } else {
        _updateSearchFieldSize();
        _updateSuggestionsOverlay();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _updateSearchFieldSize();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeSuggestionsOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateSearchFieldSize() {
    final ctx = _searchFieldKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final newWidth = box.size.width;
    final newHeight = box.size.height;
    if (_searchFieldWidth != newWidth || _searchFieldHeight != newHeight) {
      _searchFieldWidth = newWidth;
      _searchFieldHeight = newHeight;
      if (_suggestionsOverlay != null) {
        _updateSuggestionsOverlay();
      }
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    final userId = userProvider.currentUser?.id;
    String? escuelaId =
        userProvider.currentUser?.escuelaId ?? widget.arguments?['escuelaId'];

    try {
      escuelaId ??=
          await studentProvider.getAdminEscuelaUuidByUserId(userId ?? '');

      debugPrint(
          'Resolved escuelaId for selectable directory: $escuelaId (userId=$userId)');

      if (escuelaId == null) {
        throw Exception('No se encontró escuela asociada al usuario');
      }

      await studentProvider.loadStudents(escuelaId: escuelaId, userId: userId);

      if (mounted) _filterStudents();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  void _onSearchTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      _filterStudents();
      _updateSearchFieldSize();
      _updateSuggestionsOverlay();
    });
  }

  void _filterStudents() {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    studentProvider.filterStudents(
      searchQuery: _searchController.text,
      grupo: _selectedGrupoNombre,
      nivelEducativo: _selectedNivelEducativo,
      status: _selectedEstado,
      turno: _selectedTurnoNombre,
    );
  }

  List<StudentDetails> _buildNameSuggestions({
    required StudentProvider studentProvider,
    required String query,
    int limit = 8,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    // Base filtrada por selects
    final base = studentProvider.getFilteredBy(
      grupo: _selectedGrupoNombre,
      nivelEducativo: _selectedNivelEducativo,
      status: _selectedEstado,
      turno: _selectedTurnoNombre,
    );

    // Orden: startsWith -> contains
    final starts = <StudentDetails>[];
    final contains = <StudentDetails>[];
    for (final s in base) {
      final name = s.nombre.toLowerCase();
      if (name.startsWith(q)) {
        starts.add(s);
      } else if (name.contains(q)) {
        contains.add(s);
      }
    }
    final combined = [...starts, ...contains];
    return combined.length > limit ? combined.sublist(0, limit) : combined;
  }

  void _updateSuggestionsOverlay() {
    if (!mounted) return;

    if (!_searchFocusNode.hasFocus || _searchController.text.trim().isEmpty) {
      _removeSuggestionsOverlay();
      return;
    }

    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    final suggestions = _buildNameSuggestions(
      studentProvider: studentProvider,
      query: _searchController.text,
    );

    if (suggestions.isEmpty) {
      _removeSuggestionsOverlay();
      return;
    }

    final overlay = Overlay.of(context);
    _suggestionsOverlay?.remove();

    final screenSize = MediaQuery.of(context).size;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = screenSize.height * 0.4;

    _suggestionsOverlay = OverlayEntry(
      builder: (context) {
        final yOffset = (_searchFieldHeight > 0 ? _searchFieldHeight : 48) + 6;

        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeSuggestionsOverlay,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _searchFieldLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, yOffset.toDouble()),
                  child: Material(
                    elevation: 8,
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _searchFieldWidth > 0
                            ? _searchFieldWidth
                            : screenSize.width - 32,
                        minWidth:
                            _searchFieldWidth > 0 ? _searchFieldWidth : 240,
                        maxHeight: maxHeight,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.only(
                          top: AppTheme.getSmallPadding(screenSize),
                          bottom: (viewInsets > 0 ? 8 : 0),
                          left: AppTheme.getSmallPadding(screenSize),
                          right: AppTheme.getSmallPadding(screenSize),
                        ),
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color:
                              AppTheme.getBorderColor(context).withOpacity(0.2),
                        ),
                        itemBuilder: (context, index) {
                          final s = suggestions[index];
                          final consideredActive =
                              (s.hasTutores && s.llaveActiva);

                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _removeSuggestionsOverlay();
                              _selectStudent(s);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.getSmallPadding(screenSize),
                                horizontal:
                                    AppTheme.getSmallPadding(screenSize),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person_outline_rounded,
                                      color: AppTheme.accentBlue),
                                  SizedBox(
                                      width:
                                          AppTheme.getSmallPadding(screenSize)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.nombre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              AppTheme.getBodyMedium(screenSize)
                                                  .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.getTextPrimaryColor(
                                                context),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '${s.nivelEducativo} • ${s.grupo}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.getCaptionSmall(
                                                  screenSize)
                                              .copyWith(
                                            color:
                                                AppTheme.getTextSecondaryColor(
                                                    context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          AppTheme.getSmallPadding(screenSize)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppTheme.getSmallPadding(screenSize),
                                      vertical:
                                          AppTheme.getSmallPadding(screenSize) *
                                              0.4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: consideredActive
                                          ? AppTheme.successColor
                                              .withOpacity(0.12)
                                          : AppTheme.errorColor
                                              .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.getSmallRadius(screenSize)),
                                    ),
                                    child: Text(
                                      consideredActive
                                          ? AppLocalizations.of(context).active
                                          : AppLocalizations.of(context)
                                              .inactive,
                                      style:
                                          AppTheme.getCaptionSmall(screenSize)
                                              .copyWith(
                                        color: consideredActive
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(_suggestionsOverlay!);
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  // Grupos disponibles basados en el nivel educativo seleccionado (desde BD)
  List<String> _getAvailableGrupoNames() {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    if (_selectedNivelEducativo == 'all') {
      final all = studentProvider.availableGrupos
          .map((g) => g.grupo)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return ['all', ...all];
    } else {
      final names = studentProvider
          .getGrupoNamesByNivelEducativo(_selectedNivelEducativo);
      return ['all', ...names];
    }
  }

  void _selectStudent(StudentDetails student) {
    if (!widget.selectionMode) return;

    final alumnoJson = {
      'id': student.id,
      'nombre': student.nombre,
      'id_grupo': student.grupoId,
      'grupo': student.grupo,
      'id_escuela': student.escuelaId,
      'matricula': student.matricula,
      'fecha_registro': (student.fechaRegistro).toIso8601String(),
      'id_turno': student.turnoId ?? '',
      'vinculado': (student.hasTutores && student.llaveActiva),
      'id_llave': student.llaveId ?? '',
    };

    Navigator.pop(context, {'alumno': alumnoJson});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, StudentProvider>(
      builder: (context, themeProvider, studentProvider, child) {
        final filteredStudents = studentProvider.filteredStudents;

        // *** Estos 3 combos vienen 100% de BD ***
        final availableNiveles = [
          'all',
          ...studentProvider.getAvailableNivelesEducativos(),
        ];
        final availableGroups = _getAvailableGrupoNames();
        final availableTurnos = [
          'all',
          ...studentProvider.getAvailableTurnoNames(),
        ];

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  NavHeader(title: l10n.selectStudent),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                      child: Container(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getLargeRadius(screenSize)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getShadowColor(context)
                                  .withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header + Clear
                            Row(
                              children: [
                                Icon(
                                  Icons.person_search_rounded,
                                  color: AppTheme.accentBlue,
                                  size: screenSize.width * 0.06,
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.getMediumPadding(screenSize)),
                                Expanded(
                                  child: Text(
                                    'Seleccionar Estudiante',
                                    style: AppTheme.getH2(screenSize).copyWith(
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      _selectedGrupoNombre = 'all';
                                      _selectedNivelEducativo = 'all';
                                      _selectedEstado = 'all';
                                      _selectedTurnoNombre = 'all';
                                      _searchController.clear();
                                    });
                                    _filterStudents();
                                    _removeSuggestionsOverlay();
                                  },
                                  child: Text(
                                    l10n.clear,
                                    style: AppTheme.getCaption(screenSize)
                                        .copyWith(
                                      color: AppTheme.accentBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),

                            // SEARCH (anclado y medible)
                            CompositedTransformTarget(
                              link: _searchFieldLink,
                              child: Container(
                                key: _searchFieldKey,
                                child: CustomInputField(
                                  controller: _searchController,
                                  label: l10n.searchByName,
                                  icon: Icons.search_rounded,
                                  screenSize: screenSize,
                                  keyboardType: TextInputType.text,
                                  focusNode: _searchFocusNode,
                                  onSubmitted: (_) =>
                                      _removeSuggestionsOverlay(),
                                ),
                              ),
                            ),

                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),

                            // Filtros dinámicos desde BD
                            Row(
                              children: [
                                // Nivel educativo (tabla niveles_educativos.nombre)
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: 'Nivel Educativo',
                                    value: _selectedNivelEducativo,
                                    items: availableNiveles,
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedNivelEducativo =
                                            value ?? 'all';
                                        _selectedGrupoNombre =
                                            'all'; // reset grupo
                                      });
                                      _filterStudents();
                                      _updateSuggestionsOverlay();
                                    },
                                    getLabel: (String value) =>
                                        value == 'all' ? l10n.all : value,
                                    screenSize: screenSize,
                                    backgroundColor:
                                        AppTheme.accentBlue.withOpacity(0.05),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.getMediumPadding(screenSize)),
                                // Grupo (tabla grupos.grupo)
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: l10n.group,
                                    value: _selectedGrupoNombre,
                                    items: availableGroups,
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedGrupoNombre = value ?? 'all';
                                      });
                                      _filterStudents();
                                      _updateSuggestionsOverlay();
                                    },
                                    getLabel: (String value) =>
                                        value == 'all' ? l10n.all : value,
                                    screenSize: screenSize,
                                    backgroundColor:
                                        AppTheme.accentPurple.withOpacity(0.05),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: AppTheme.getSmallPadding(screenSize)),
                            Row(
                              children: [
                                // Estado (activo/inactivo según regla: alumno_tutores + llave.activo)
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: l10n.status,
                                    value: _selectedEstado,
                                    items: const ['all', 'active', 'inactive'],
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedEstado = value ?? 'all';
                                      });
                                      _filterStudents();
                                      _updateSuggestionsOverlay();
                                    },
                                    getLabel: (String value) {
                                      switch (value) {
                                        case 'all':
                                          return l10n.all;
                                        case 'active':
                                          return l10n.active;
                                        case 'inactive':
                                          return l10n.inactive;
                                        default:
                                          return value;
                                      }
                                    },
                                    screenSize: screenSize,
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.getMediumPadding(screenSize)),
                                // Turno (tabla turnos.turno)
                                Expanded(
                                  child: ModernDropdown<String>(
                                    label: 'Turno',
                                    value: _selectedTurnoNombre,
                                    items: availableTurnos,
                                    onChanged: (String? value) {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _selectedTurnoNombre = value ?? 'all';
                                      });
                                      _filterStudents();
                                      _updateSuggestionsOverlay();
                                    },
                                    getLabel: (String value) =>
                                        value == 'all' ? l10n.all : value,
                                    screenSize: screenSize,
                                  ),
                                ),
                              ],
                            ),

                            if (studentProvider.students.isNotEmpty) ...[
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              Container(
                                padding: EdgeInsets.all(
                                    AppTheme.getSmallPadding(screenSize)),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getSmallRadius(screenSize)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: AppTheme.accentBlue,
                                      size: screenSize.height * 0.02,
                                    ),
                                    SizedBox(
                                        width: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Expanded(
                                      child: Text(
                                        'Mostrando ${filteredStudents.length} de ${studentProvider.students.length} estudiantes',
                                        style:
                                            AppTheme.getCaptionSmall(screenSize)
                                                .copyWith(
                                          color: AppTheme.accentBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (filteredStudents.isNotEmpty) ...[
                              SizedBox(
                                  height: AppTheme.getLargePadding(screenSize)),
                              Text(
                                'Estudiantes Disponibles',
                                style:
                                    AppTheme.getSubtitle1(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              ...filteredStudents.map((student) {
                                final consideredActive =
                                    (student.hasTutores && student.llaveActiva);

                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom:
                                          AppTheme.getSmallPadding(screenSize)),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.getMediumRadius(screenSize)),
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        _selectStudent(student);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(
                                            AppTheme.getMediumPadding(
                                                screenSize)),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                AppTheme.getBorderColor(context)
                                                    .withOpacity(0.3),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.getMediumRadius(
                                                  screenSize)),
                                        ),
                                        child: Row(
                                          children: [
                                            // Avatar
                                            Container(
                                              width: screenSize.width * 0.12,
                                              height: screenSize.width * 0.12,
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentBlue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppTheme.getSmallRadius(
                                                            screenSize)),
                                              ),
                                              child: Icon(
                                                Icons.person_rounded,
                                                color: AppTheme.accentBlue,
                                                size: screenSize.width * 0.06,
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                    AppTheme.getMediumPadding(
                                                        screenSize)),
                                            // Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    student.nombre,
                                                    style:
                                                        AppTheme.getBodyMedium(
                                                                screenSize)
                                                            .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppTheme
                                                          .getTextPrimaryColor(
                                                              context),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: AppTheme
                                                              .getSmallPadding(
                                                                  screenSize) *
                                                          0.3),
                                                  Text(
                                                    '${student.nivelEducativo} - ${student.grupo}',
                                                    style: AppTheme.getCaption(
                                                            screenSize)
                                                        .copyWith(
                                                      color: AppTheme
                                                          .getTextSecondaryColor(
                                                              context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Estado + flecha
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: AppTheme
                                                        .getSmallPadding(
                                                            screenSize),
                                                    vertical: AppTheme
                                                            .getSmallPadding(
                                                                screenSize) *
                                                        0.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: consideredActive
                                                        ? AppTheme.successColor
                                                            .withOpacity(0.1)
                                                        : AppTheme.errorColor
                                                            .withOpacity(0.1),
                                                    borderRadius: BorderRadius
                                                        .circular(AppTheme
                                                            .getSmallRadius(
                                                                screenSize)),
                                                  ),
                                                  child: Text(
                                                    consideredActive
                                                        ? l10n.active
                                                        : l10n.inactive,
                                                    style: AppTheme
                                                            .getCaptionSmall(
                                                                screenSize)
                                                        .copyWith(
                                                      color: consideredActive
                                                          ? AppTheme
                                                              .successColor
                                                          : AppTheme.errorColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: AppTheme
                                                            .getSmallPadding(
                                                                screenSize) *
                                                        0.3),
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: AppTheme
                                                      .getTextSecondaryColor(
                                                          context),
                                                  size:
                                                      screenSize.height * 0.025,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ] else ...[
                              SizedBox(
                                  height: AppTheme.getLargePadding(screenSize)),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.person_search_rounded,
                                      size: screenSize.height * 0.08,
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                    SizedBox(
                                        height: AppTheme.getMediumPadding(
                                            screenSize)),
                                    Text(
                                      'No se encontraron estudiantes',
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
