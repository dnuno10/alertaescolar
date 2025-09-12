import 'dart:async';

import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/utils/modern_dropdown.dart';
import 'package:alertaescolar/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../students/student_profile_admin_view.dart';
import '../../../utils/time_format.dart';

class AttendanceCalendarView extends StatefulWidget {
  const AttendanceCalendarView({super.key});

  @override
  State<AttendanceCalendarView> createState() => _AttendanceCalendarViewState();
}

class _AttendanceCalendarViewState extends State<AttendanceCalendarView> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();

  // ==== Búsqueda + overlay de sugerencias (mismo patrón visual que Selectable/Directory) ====
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _searchFieldLink = LayerLink();
  final GlobalKey _searchFieldKey = GlobalKey();
  double _searchFieldWidth = 0;
  double _searchFieldHeight = 0;
  OverlayEntry? _suggestionsOverlay;
  Timer? _debounce;

  // Filtros (mismos nombres/semántica que en Selectable/StudentsDirectory)
  String _selectedNivelEducativo = 'all';
  String _selectedGrupoNombre = 'all';
  String _selectedTurnoNombre = 'all';
  String _selectedAccess = 'all'; // entrada | salida | retraso

  // Datos
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _filteredNotifications = [];
  String? _error;

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
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadInitialData();
  }

  // ========================= Carga de datos =========================
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    final escuelaId = userProvider.currentUser?.escuelaId;
    if (escuelaId == null) return;

    LoadingDialog.show(context, message: 'Cargando datos de asistencia...');

    setState(() => _error = null);

    try {
      // StudentProvider trae niveles/grupos/turnos (y su orden) igual que en las otras vistas
      await studentProvider.loadStudents(escuelaId: escuelaId);

      // Notificaciones de asistencia
      await _loadNotifications(escuelaId);

      // Filtros iniciales + overlay
      _filterNotifications();
      _updateSuggestionsOverlay();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      setState(() => _error = e.toString());
    } finally {
      if (mounted) LoadingDialog.hide(context);
    }
  }

  Future<void> _loadNotifications(String escuelaId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('notificaciones')
          .select(r'''
            id,
            id_alumno,
            id_admin,
            titulo,
            mensaje,
            estado,
            fecha_registro,
            tipo_notificacion,
            alumnos!inner(
              id,
              nombre,
              matricula,
              fecha_registro,
              id_grupo,
              id_turno,
              id_escuela,
              grupos!inner(
                grupo,
                nivel_educativo
              ),
              turnos!inner(
                turno
              )
            )
          ''')
          .eq('alumnos.id_escuela', escuelaId)
          .inFilter('tipo_notificacion', ['entrada', 'salida', 'retraso'])
          .order('fecha_registro', ascending: false);

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(response);
      });

      debugPrint(
          'Loaded ${_notifications.length} notifications for $escuelaId');
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      throw Exception('Error al cargar notificaciones: $e');
    }
  }

  // ========================= Sugerencias (mismo visual que Selectable/Directory) =========================
  void _onSearchTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      _filterNotifications();
      _updateSearchFieldSize();
      _updateSuggestionsOverlay();
    });
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

  List<StudentDetails> _buildNameSuggestions({
    required StudentProvider studentProvider,
    required String query,
    int limit = 8,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    // Base filtrada por selects actuales (igual que Selectable/Directory)
    final base = studentProvider.getFilteredBy(
      grupo: _selectedGrupoNombre,
      nivelEducativo: _selectedNivelEducativo,
      status: 'all', // en calendario no filtramos por estado
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
    final yOffset = (_searchFieldHeight > 0 ? _searchFieldHeight : 48) + 6;

    _suggestionsOverlay = OverlayEntry(
      builder: (context) {
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
                              // ignore: deprecated_member_use
                              AppTheme.getBorderColor(context).withOpacity(0.2),
                        ),
                        itemBuilder: (context, index) {
                          final s = suggestions[index];
                          final consideredActive =
                              (s.hasTutores && s.llaveActiva);

                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              // Igual que en Selectable: rellenamos el buscador y filtramos
                              _searchController.text = s.nombre;
                              _searchController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: s.nombre.length),
                              );
                              _filterNotifications();
                              _removeSuggestionsOverlay();
                              FocusScope.of(context).unfocus();
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
                                        const SizedBox(height: 2),
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
                                              // ignore: deprecated_member_use
                                              .withOpacity(0.12)
                                          : AppTheme.errorColor
                                              // ignore: deprecated_member_use
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

  // ========================= Filtrado de notificaciones =========================
  void _filterNotifications() {
    List<Map<String, dynamic>> filtered = List.from(_notifications);

    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((n) {
        final studentName =
            n['alumnos']?['nombre']?.toString().toLowerCase() ?? '';
        return studentName.contains(q);
      }).toList();
    }

    if (_selectedNivelEducativo != 'all') {
      filtered = filtered.where((n) {
        final nivel =
            n['alumnos']?['grupos']?['nivel_educativo']?.toString() ?? '';
        return nivel == _selectedNivelEducativo;
      }).toList();
    }

    if (_selectedGrupoNombre != 'all') {
      filtered = filtered.where((n) {
        final grupo = n['alumnos']?['grupos']?['grupo']?.toString() ?? '';
        return grupo == _selectedGrupoNombre;
      }).toList();
    }

    if (_selectedTurnoNombre != 'all') {
      filtered = filtered.where((n) {
        final turno = n['alumnos']?['turnos']?['turno']?.toString() ?? '';
        return turno == _selectedTurnoNombre;
      }).toList();
    }

    if (_selectedAccess != 'all') {
      filtered = filtered.where((n) {
        final tipo = (n['tipo_notificacion'] ?? '').toString();
        return tipo == _selectedAccess;
      }).toList();
    }

    // Día seleccionado
    filtered = filtered.where((n) {
      // 🔧 FIX: Usar TimeFormat.parseSupabaseDateTime para manejar timestamptz
      final fechaRegistro =
          TimeFormat.parseSupabaseDateTime(n['fecha_registro']);
      return fechaRegistro.year == selectedDate.year &&
          fechaRegistro.month == selectedDate.month &&
          fechaRegistro.day == selectedDate.day;
    }).toList();

    setState(() => _filteredNotifications = filtered);
  }

  List<Map<String, dynamic>> _getNotificationsForDate(DateTime date) {
    return _filteredNotifications.where((n) {
      // 🔧 FIX: Usar TimeFormat.parseSupabaseDateTime para manejar timestamptz
      final fechaRegistro =
          TimeFormat.parseSupabaseDateTime(n['fecha_registro']);
      return fechaRegistro.year == date.year &&
          fechaRegistro.month == date.month &&
          fechaRegistro.day == date.day;
    }).toList();
  }

  // ====== Listas desplegables: MISMO ORDEN/FUENTE que en Selectable/Directory ======
  List<String> _getAvailableGrupoNames(StudentProvider studentProvider) {
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

  // ========================= UI =========================
  Widget _buildFiltersSection(
    BuildContext context,
    Size screenSize,
    StudentProvider studentProvider,
  ) {
    final l10n = AppLocalizations.of(context);

    final availableNiveles = [
      'all',
      ...studentProvider.getAvailableNivelesEducativos(),
    ];
    final availableGroups = _getAvailableGrupoNames(studentProvider);
    final availableTurnos = [
      'all',
      ...studentProvider.getAvailableTurnoNames(),
    ];

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppTheme.getBorderColor(context).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Filtros de Asistencia',
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _selectedGrupoNombre = 'all';
                    _selectedNivelEducativo = 'all';
                    _selectedTurnoNombre = 'all';
                    _selectedAccess = 'all';
                    _searchController.clear();
                  });
                  _filterNotifications();
                  _removeSuggestionsOverlay();
                },
                child: Text(
                  l10n.clear,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Search (anclado y con overlay como en Selectable/Directory)
          CompositedTransformTarget(
            link: _searchFieldLink,
            child: Container(
              key: _searchFieldKey,
              child: CustomInputField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                label: 'Buscar por nombre del estudiante...',
                icon: Icons.search_rounded,
                screenSize: screenSize,
                keyboardType: TextInputType.text,
                onSubmitted: (_) => _removeSuggestionsOverlay(),
              ),
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Dropdowns ModernDropdown (misma fuente/orden) — gracias al micro-cambio, solo 1 se abre a la vez
          Row(
            children: [
              Expanded(
                child: ModernDropdown<String>(
                  label: 'Nivel Educativo',
                  value: _selectedNivelEducativo,
                  items: availableNiveles,
                  onChanged: (String? value) {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _selectedNivelEducativo = value ?? 'all';
                      _selectedGrupoNombre = 'all'; // reset grupo
                    });
                    _filterNotifications();
                    _updateSuggestionsOverlay();
                  },
                  getLabel: (String v) => v == 'all' ? l10n.all : v,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: ModernDropdown<String>(
                  label: l10n.group,
                  value: _selectedGrupoNombre,
                  items: availableGroups,
                  onChanged: (String? value) {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedGrupoNombre = value ?? 'all');
                    _filterNotifications();
                    _updateSuggestionsOverlay();
                  },
                  getLabel: (String v) => v == 'all' ? l10n.all : v,
                  screenSize: screenSize,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: ModernDropdown<String>(
                  label: 'Turno',
                  value: _selectedTurnoNombre,
                  items: availableTurnos,
                  onChanged: (String? value) {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedTurnoNombre = value ?? 'all');
                    _filterNotifications();
                    _updateSuggestionsOverlay();
                  },
                  getLabel: (String v) => v == 'all' ? l10n.all : v,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: ModernDropdown<String>(
                  label: l10n.access,
                  value: _selectedAccess,
                  items: const ['all', 'entrada', 'salida', 'retraso'],
                  onChanged: (String? value) {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedAccess = value ?? 'all');
                    _filterNotifications();
                  },
                  getLabel: (String v) {
                    switch (v) {
                      case 'all':
                        return l10n.all;
                      case 'entrada':
                        return l10n.entryRegistered;
                      case 'salida':
                        return l10n.exitRegistered;
                      case 'retraso':
                        return l10n.lateArrival;
                      default:
                        return v;
                    }
                  },
                  screenSize: screenSize,
                ),
              ),
            ],
          ),

          if (_notifications.isNotEmpty) ...[
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.height * 0.02,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      'Mostrando ${_filteredNotifications.length} de ${_notifications.length} registros',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
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
    );
  }

  Widget _buildDateSelector(BuildContext context, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Asistencia',
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppTheme.accentPurple,
                      onPrimary: Colors.white,
                      surface: AppTheme.getCardColor(context),
                      onSurface: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
                focusedDay = picked;
              });
              _filterNotifications();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.getSmallPadding(screenSize),
              horizontal: AppTheme.getMediumPadding(screenSize),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // ignore: deprecated_member_use
                  AppTheme.accentPurple.withOpacity(0.1),
                  // ignore: deprecated_member_use
                  AppTheme.accentBlue.withOpacity(0.05),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              // ignore: deprecated_member_use
              border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize) * 0.6),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppTheme.accentPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.accentPurple,
                          size: screenSize.height * 0.02,
                        ),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.8),
                      Flexible(
                        child: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateDetails(BuildContext context, Size screenSize) {
    final notificationsForDate = _getNotificationsForDate(selectedDate);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppTheme.getBorderColor(context).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Registros del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          if (notificationsForDate.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: screenSize.height * 0.05,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      'No hay registros para esta fecha',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...notificationsForDate.map((n) {
              return _buildNotificationCard(context, screenSize, n);
            }),
        ],
      ),
    );
  }

  final Map<String, String> _adminNameCache = {};

  Future<String> _getAdminFullName(String? adminId) async {
    final id = (adminId ?? '').trim();
    if (id.isEmpty) return '—';

    // cache
    final cached = _adminNameCache[id];
    if (cached != null) return cached;

    try {
      final row = await Supabase.instance.client
          .from('usuarios')
          .select('nombre, apellido')
          .eq('id', id)
          .maybeSingle();

      if (row != null) {
        final nombre = (row['nombre'] ?? '').toString().trim();
        final apellido = (row['apellido'] ?? '').toString().trim();
        final full = ('$nombre $apellido').trim();
        final result = full.isEmpty ? '—' : full;
        _adminNameCache[id] = result;
        return result;
      }
    } catch (_) {
      // Ignorar errores de red/RLS: devolvemos fallback y cacheamos para evitar retrys
    }

    _adminNameCache[id] = '—';
    return '—';
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Size screenSize,
    Map<String, dynamic> notification,
  ) {
    final student = notification['alumnos'] ?? const {};
    final tipoNotificacion =
        (notification['tipo_notificacion'] ?? '').toString();

    // 🔧 FIX: Usar TimeFormat.parseSupabaseDateTime para manejar timestamptz correctamente
    final fechaRegistro =
        TimeFormat.parseSupabaseDateTime(notification['fecha_registro']);
    final adminId = (notification['id_admin'] ?? '').toString();

    // 🔧 FIX: Usar TimeFormat.formatDateTimeToAmPm para formato correcto con timezone local
    final horaAmPm = TimeFormat.formatDateTimeToAmPm(fechaRegistro);

    Color typeColor;
    IconData typeIcon;
    String typeText;

    switch (tipoNotificacion) {
      case 'entrada':
        typeColor = AppTheme.successColor;
        typeIcon = Icons.login_rounded;
        typeText = 'Entrada';
        break;
      case 'salida':
        typeColor = AppTheme.errorColor;
        typeIcon = Icons.logout_rounded;
        typeText = 'Salida';
        break;
      case 'retraso':
        typeColor = AppTheme.warningColor;
        typeIcon = Icons.schedule_rounded;
        typeText = 'Retraso';
        break;
      default:
        typeColor = AppTheme.getTextSecondaryColor(context);
        typeIcon = Icons.notifications_rounded;
        typeText = tipoNotificacion.isEmpty ? 'Notificación' : tipoNotificacion;
    }

    final vPad = AppTheme.getSmallPadding(screenSize) * 0.7;
    final hPad = AppTheme.getMediumPadding(screenSize);

    // Traer nombre del admin (con caché) sin bloquear la UI
    return FutureBuilder<String>(
      future: _getAdminFullName(adminId),
      builder: (context, snapshot) {
        final adminName = snapshot.data ?? '—';

        final matricula = (student['matricula'] ?? '').toString().trim().isEmpty
            ? '—'
            : (student['matricula'] ?? '').toString();

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _navigateToStudentProfile(context, student);
          },
          child: Container(
            margin:
                EdgeInsets.only(bottom: AppTheme.getSmallPadding(screenSize)),
            padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              // ignore: deprecated_member_use
              border: Border.all(color: typeColor.withOpacity(0.25), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Info del alumno (compacta con elipsis)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre alumno
                      Text(
                        (student['nombre'] ?? 'N/A').toString(),
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.20),
                      // Nivel - Grupo
                      Text(
                        '${(student['grupos']?['nivel_educativo'] ?? '—').toString()} - ${(student['grupos']?['grupo'] ?? '—').toString()}',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.20),
                      // Matrícula
                      Text(
                        'Matrícula: $matricula',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppTheme.getSmallPadding(screenSize)),

                // Tipo + hora + admin (compacto). El ícono va dentro del chip del tipo.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tipo (chip)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.8,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.4,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize),
                        ),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: typeColor.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            typeIcon,
                            color: typeColor,
                            size: screenSize.height * 0.018,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            typeText,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.20),

                    // Hora
                    Text(
                      horaAmPm,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.20),

                    // Admin que escaneó
                    Text(
                      adminName == '—' ? '—' : 'Por $adminName',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),

                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.022,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========================= Navegación perfil =========================
  Future<StudentDetails> _convertToStudentDetailsWithKeys(
      Map<String, dynamic> studentData) async {
    try {
      final supabase = Supabase.instance.client;
      final keyResponse = await supabase
          .from('llaves')
          .select('*')
          .eq('id_alumno', studentData['id'])
          .maybeSingle();

      return StudentDetails(
        id: studentData['id'] ?? '',
        nombre: studentData['nombre'] ?? '',
        matricula: studentData['matricula'] ?? '',
        escuelaId: studentData['id_escuela'] ?? '',
        grupoId: studentData['id_grupo'] ?? '',
        grupo: studentData['grupos']?['grupo'] ?? '',
        nivelEducativo: studentData['grupos']?['nivel_educativo'] ?? '',
        turnoId: studentData['id_turno'],
        turno: studentData['turnos']?['turno'] ?? '',
        llaveId: keyResponse?['id'],
        llaveCodigo: keyResponse?['codigo'],
        llaveActiva: keyResponse?['activo'] ?? false,
        fechaRegistro: DateTime.parse(
            studentData['fecha_registro'] ?? DateTime.now().toIso8601String()),
        fechaRegistroLlave: keyResponse?['fecha_registro'] != null
            ? DateTime.parse(keyResponse!['fecha_registro'])
            : null,
        fechaDesactivacionLlave: keyResponse?['fecha_desactivacion'] != null
            ? DateTime.parse(keyResponse!['fecha_desactivacion'])
            : null,
        limiteVinculacion: keyResponse?['limite_vinculacion'],
        tutores: const [],
        familyContacts: const [],
      );
    } catch (e) {
      debugPrint('Error loading key data: $e');
      return StudentDetails(
        id: studentData['id'] ?? '',
        nombre: studentData['nombre'] ?? '',
        matricula: studentData['matricula'] ?? '',
        escuelaId: studentData['id_escuela'] ?? '',
        grupoId: studentData['id_grupo'] ?? '',
        grupo: studentData['grupos']?['grupo'] ?? '',
        nivelEducativo: studentData['grupos']?['nivel_educativo'] ?? '',
        turnoId: studentData['id_turno'],
        turno: studentData['turnos']?['turno'] ?? '',
        llaveActiva: false,
        fechaRegistro: DateTime.parse(
            studentData['fecha_registro'] ?? DateTime.now().toIso8601String()),
        tutores: const [],
        familyContacts: const [],
      );
    }
  }

  void _navigateToStudentProfile(
      BuildContext context, Map<String, dynamic> studentData) async {
    final studentDetails = await _convertToStudentDetailsWithKeys(studentData);
    if (!mounted) return;
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileAdminView(student: studentDetails),
      ),
    );
  }

  // ========================= Build =========================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, StudentProvider>(
      builder: (context, themeProvider, studentProvider, child) {
        if (_error != null && _notifications.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingDialog.hide(context);
          });

          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _error!,
                      style: AppTheme.getBodyMedium(screenSize),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            resizeToAvoidBottomInset: true,
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _removeSuggestionsOverlay(); // Oculta sugerencias si se toca afuera
                FocusScope.of(context).unfocus();
              },
              child: LiquidPullToRefresh(
                onRefresh: _onRefresh,
                color: AppTheme.accentPurple,
                backgroundColor: AppTheme.getBackgroundColor(context),
                height: 120,
                animSpeedFactor: 9.0,
                showChildOpacityTransition: false,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    NavHeader(title: l10n.attendanceCalendar),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFiltersSection(
                                context, screenSize, studentProvider),
                            SizedBox(
                                height: AppTheme.getLargePadding(screenSize)),
                            _buildDateSelector(context, screenSize),
                            SizedBox(
                                height: AppTheme.getLargePadding(screenSize)),
                            _buildDateDetails(context, screenSize),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
