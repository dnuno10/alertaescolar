import 'dart:async';
import 'package:alertaescolar/components/admin/directory/directory_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:flutter/services.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../utils/modern_dropdown.dart';
import 'student_profile_admin_view.dart';

class StudentsDirectoryView extends StatefulWidget {
  const StudentsDirectoryView({super.key});

  @override
  State<StudentsDirectoryView> createState() => _StudentsDirectoryViewState();
}

class _StudentsDirectoryViewState extends State<StudentsDirectoryView> {
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

  // NOMBRES ALINEADOS A LA BD
  String _selectedNivelEducativo = 'all'; // grupos.nivel_educativo
  String _selectedGrupoNombre = 'all'; // grupos.grupo
  String _selectedEstado =
      'all'; // 'all' | 'active' | 'inactive' (hasTutores && llaveActiva)
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

    // Carga inicial cuando el widget ya está montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _updateSearchFieldSize();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeSuggestionsOverlay();
    _searchController.removeListener(_onSearchTextChanged);
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

    final String? userId = userProvider.currentUser?.id;
    String? escuelaId = userProvider.currentUser?.escuelaId;

    try {
      // Resolver SOLO por ADMIN si no viene en el usuario
      if ((escuelaId == null || escuelaId.isEmpty) &&
          userId != null &&
          userId.isNotEmpty) {
        escuelaId = await studentProvider.getAdminEscuelaUuidByUserId(userId);
      }

      if (escuelaId == null || escuelaId.trim().isEmpty) {
        throw Exception('No se encontró escuela asociada al administrador');
      }

      // Carga alumnos + catálogos (niveles, grupos, turnos) desde BD
      await studentProvider.loadStudents(escuelaId: escuelaId);

      if (mounted) _filterStudents();
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
    }
  }

  Future<void> _loadStudents() async {
    if (!mounted) return;

    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      String? escuelaUuid = userProvider.currentUser?.escuelaId;
      final String? userId = userProvider.currentUser?.id;

      if ((escuelaUuid == null || escuelaUuid.isEmpty) &&
          userId != null &&
          userId.isNotEmpty) {
        escuelaUuid = await studentProvider.getAdminEscuelaUuidByUserId(userId);
      }

      if (escuelaUuid == null || escuelaUuid.isEmpty) {
        debugPrint('No se pudo resolver el UUID de la escuela del admin.');
        return;
      }

      await studentProvider.loadStudents(escuelaId: escuelaUuid);
      if (mounted) _filterStudents();
    } catch (e) {
      debugPrint('Error in _loadStudents: $e');
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
    if (!mounted) return;
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    studentProvider.filterStudents(
      searchQuery: _searchController.text,
      grupo: _selectedGrupoNombre, // nombre del grupo
      nivelEducativo: _selectedNivelEducativo, // nombre del nivel
      status: _selectedEstado,
      turno: _selectedTurnoNombre, // nombre del turno
    );
  }

  // Sugerencias por nombre (orden: startsWith -> contains), respetando filtros seleccionados
  List<StudentDetails> _buildNameSuggestions({
    required StudentProvider studentProvider,
    required String query,
    int limit = 8,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final base = studentProvider.getFilteredBy(
      grupo: _selectedGrupoNombre,
      nivelEducativo: _selectedNivelEducativo,
      status: _selectedEstado,
      turno: _selectedTurnoNombre,
    );

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
                      AppTheme.getMediumRadius(screenSize),
                    ),
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
                          top: AppTheme.getSmallPadding(screenSize) * 0.5,
                          bottom: (viewInsets > 0 ? 6 : 0),
                          left: AppTheme.getSmallPadding(screenSize),
                          right: AppTheme.getSmallPadding(screenSize),
                        ),
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color:
                              // ignore: deprecated_member_use
                              AppTheme.getBorderColor(context).withOpacity(0.2),
                        ),
                        itemBuilder: (context, index) {
                          final s = suggestions[index];

                          // === ESTADO ACTIVO CORRECTO (ventana de vigencia + vínculo) ===
                          final now = DateTime.now();
                          final start = s.fechaRegistroLlave ?? s.fechaRegistro;
                          final end = s.fechaDesactivacionLlave;
                          final dentroVentana = !now.isBefore(start) &&
                              (end == null || !now.isAfter(end));
                          final consideredActive =
                              s.hasTutores && dentroVentana;

                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _openStudentProfile(s);
                            },
                            child: Padding(
                              // Menor padding para bajar la altura
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    AppTheme.getSmallPadding(screenSize) * 0.5,
                                horizontal:
                                    AppTheme.getSmallPadding(screenSize),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // SIN ÍCONO para compactar

                                  // Contenido principal (2 líneas compactas con elipsis)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
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
                                    width: AppTheme.getSmallPadding(screenSize),
                                  ),

                                  // Estado muy compacto: punto + texto pequeño
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: consideredActive
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        consideredActive
                                            ? AppLocalizations.of(context)
                                                .active
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
                                    ],
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
      // Si no hay nivel, todos los grupos únicos de la escuela
      final all = studentProvider.availableGrupos
          .map((g) => g.grupo)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return ['all', ...all];
    } else {
      // Solo los grupos del nivel seleccionado
      final names = studentProvider
          .getGrupoNamesByNivelEducativo(_selectedNivelEducativo);
      return ['all', ...names];
    }
  }

  void _openStudentProfile(StudentDetails student) {
    _removeSuggestionsOverlay();
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileAdminView(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, StudentProvider>(
      builder: (context, themeProvider, studentProvider, child) {
        final allStudents = studentProvider.filteredStudents;

        // Loading
        if (studentProvider.isLoading && studentProvider.students.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (studentProvider.error != null && studentProvider.students.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    studentProvider.error!,
                    style: AppTheme.getBodyMedium(screenSize),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _loadStudents();
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        // Opciones para dropdowns (desde BD)
        final availableNiveles = [
          'all',
          ...studentProvider.getAvailableNivelesEducativos()
        ];
        final availableGroups = _getAvailableGrupoNames();
        final availableTurnos = [
          'all',
          ...studentProvider.getAvailableTurnoNames()
        ];

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              LiquidPullToRefresh(
                onRefresh: _loadStudents, // ya tienes este método definido
                color: AppTheme.accentPurple,
                backgroundColor: AppTheme.getBackgroundColor(context),
                height: 120,
                animSpeedFactor: 9.0,
                showChildOpacityTransition: false,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    DirectoryHeader(
                      title: l10n.studentsDirectory,
                      subtitle: l10n.manageAndSearchStudents,
                      isSliverAppBar:
                          true, // o false según el estilo que quieras
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card de filtros
                            Container(
                              padding: EdgeInsets.all(
                                  AppTheme.getMediumPadding(screenSize)),
                              decoration: BoxDecoration(
                                color: AppTheme.getCardColor(context),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getLargeRadius(screenSize)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.getShadowColor(context)
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header filtros
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        color: AppTheme.accentPurple,
                                        size: screenSize.width * 0.06,
                                      ),
                                      SizedBox(
                                          width: AppTheme.getMediumPadding(
                                              screenSize)),
                                      Expanded(
                                        child: Text(
                                          l10n.searchFilters,
                                          style: AppTheme.getH2(screenSize)
                                              .copyWith(
                                            color: AppTheme.getTextPrimaryColor(
                                                context),
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
                                            color: AppTheme.accentPurple,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                      height: AppTheme.getMediumPadding(
                                          screenSize)),

                                  // Buscador (anclado y medible para overlay)
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
                                      height: AppTheme.getMediumPadding(
                                          screenSize)),

                                  // Dropdowns dinámicos
                                  Row(
                                    children: [
                                      // Nivel educativo
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
                                        ),
                                      ),
                                      SizedBox(
                                          width: AppTheme.getMediumPadding(
                                              screenSize)),
                                      // Grupo (filtrado por nivel)
                                      Expanded(
                                        child: ModernDropdown<String>(
                                          label: l10n.group,
                                          value: _selectedGrupoNombre,
                                          items: availableGroups,
                                          onChanged: (String? value) {
                                            HapticFeedback.mediumImpact();
                                            setState(() {
                                              _selectedGrupoNombre =
                                                  value ?? 'all';
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

                                  SizedBox(
                                      height:
                                          AppTheme.getSmallPadding(screenSize)),

                                  // Estado y Turno
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ModernDropdown<String>(
                                          label: l10n.status,
                                          value: _selectedEstado,
                                          items: const [
                                            'all',
                                            'active',
                                            'inactive'
                                          ],
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
                                          width: AppTheme.getMediumPadding(
                                              screenSize)),
                                      Expanded(
                                        child: ModernDropdown<String>(
                                          label: 'Turno',
                                          value: _selectedTurnoNombre,
                                          items: availableTurnos,
                                          onChanged: (String? value) {
                                            HapticFeedback.mediumImpact();
                                            setState(() {
                                              _selectedTurnoNombre =
                                                  value ?? 'all';
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

                                  // Resumen resultados
                                  if (studentProvider.students.isNotEmpty) ...[
                                    SizedBox(
                                        height: AppTheme.getMediumPadding(
                                            screenSize)),
                                    Container(
                                      padding: EdgeInsets.all(
                                          AppTheme.getSmallPadding(screenSize)),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentBlue
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.getSmallRadius(
                                                screenSize)),
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
                                              'Mostrando ${allStudents.length} de ${studentProvider.students.length} estudiantes',
                                              style: AppTheme.getCaptionSmall(
                                                      screenSize)
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
                                ],
                              ),
                            ),

                            // Lista de estudiantes
                            SizedBox(
                                height: AppTheme.getLargePadding(screenSize)),

                            if (allStudents.isEmpty &&
                                studentProvider.students.isNotEmpty)
                              // No hay coincidencias con filtros
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                    AppTheme.getLargePadding(screenSize)),
                                decoration: BoxDecoration(
                                  color: AppTheme.getCardColor(context),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getLargeRadius(screenSize)),
                                  border: Border.all(
                                      color: AppTheme.getBorderColor(context)),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: screenSize.height * 0.08,
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                    SizedBox(
                                        height: AppTheme.getMediumPadding(
                                            screenSize)),
                                    Text(
                                      l10n.noStudentsFound,
                                      style: AppTheme.getSubtitle1(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Text(
                                      l10n.tryAdjustingFilters,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else if (allStudents.isEmpty &&
                                studentProvider.students.isEmpty)
                              // No hay estudiantes en la escuela
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                    AppTheme.getLargePadding(screenSize)),
                                decoration: BoxDecoration(
                                  color: AppTheme.getCardColor(context),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getLargeRadius(screenSize)),
                                  border: Border.all(
                                      color: AppTheme.getBorderColor(context)),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.group_rounded,
                                      size: screenSize.height * 0.08,
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                    SizedBox(
                                        height: AppTheme.getMediumPadding(
                                            screenSize)),
                                    Text(
                                      'No hay estudiantes registrados',
                                      style: AppTheme.getSubtitle1(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Text(
                                      'Los estudiantes aparecerán aquí una vez que sean registrados',
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else
                              // Lista con resultados
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.getCardColor(context),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getLargeRadius(screenSize)),
                                  border: Border.all(
                                      color: AppTheme.getBorderColor(context)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header de lista
                                    Padding(
                                      padding: EdgeInsets.all(
                                          AppTheme.getMediumPadding(
                                              screenSize)),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.group_rounded,
                                            color: AppTheme.accentPurple,
                                            size: screenSize.height * 0.025,
                                          ),
                                          SizedBox(
                                              width: AppTheme.getSmallPadding(
                                                  screenSize)),
                                          Text(
                                            'Estudiantes Registrados',
                                            style: AppTheme.getSubtitle1(
                                                    screenSize)
                                                .copyWith(
                                              color:
                                                  AppTheme.getTextPrimaryColor(
                                                      context),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  AppTheme.getSmallPadding(
                                                      screenSize),
                                              vertical:
                                                  AppTheme.getSmallPadding(
                                                          screenSize) *
                                                      0.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentPurple
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppTheme.getSmallRadius(
                                                          screenSize)),
                                            ),
                                            child: Text(
                                              '${allStudents.length}',
                                              style: AppTheme.getCaption(
                                                      screenSize)
                                                  .copyWith(
                                                color: AppTheme.accentPurple,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Listado
                                    ListView.separated(
                                      padding: EdgeInsets.only(
                                        left: AppTheme.getMediumPadding(
                                            screenSize),
                                        right: AppTheme.getMediumPadding(
                                            screenSize),
                                        bottom: AppTheme.getMediumPadding(
                                            screenSize),
                                      ),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: allStudents.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                              height: AppTheme.getSmallPadding(
                                                  screenSize)),
                                      itemBuilder: (context, index) {
                                        final student = allStudents[index];
                                        return _buildStudentCard(
                                            context, student, screenSize, l10n);
                                      },
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
              ),
              const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    dynamic student,
    Size screenSize,
    AppLocalizations l10n,
  ) {
    // === ACTIVO correcto: vínculo + ventana de vigencia ===
    final now = DateTime.now();
    final start = student.fechaRegistroLlave ?? student.fechaRegistro;
    final end = student.fechaDesactivacionLlave;
    final dentroVentana =
        !now.isBefore(start) && (end == null || !now.isAfter(end));
    final consideredActive = (student.hasTutores && dentroVentana);

    final statusColor =
        consideredActive ? AppTheme.successColor : AppTheme.errorColor;
    final statusIcon =
        consideredActive ? Icons.verified_rounded : Icons.block_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openStudentProfile(student),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          // Más compacto: menos padding vertical
          padding: EdgeInsets.symmetric(
            vertical: AppTheme.getSmallPadding(screenSize) * 0.8,
            horizontal: AppTheme.getMediumPadding(screenSize),
          ),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Info (sin avatar, todo con elipsis)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.nombre,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.25),
                    Text(
                      '${student.nivelEducativo} - ${student.grupo}',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (student.matricula != null &&
                        student.matricula.isNotEmpty) ...[
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.2),
                      Text(
                        'Matrícula: ${student.matricula}',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: AppTheme.getSmallPadding(screenSize)),

              // Estado (chip con ícono) + chevron pequeño
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize) * 0.8,
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.4,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: statusColor.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: screenSize.height * 0.018,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          consideredActive ? l10n.active : l10n.inactive,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.022,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
