import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../managers/group_provider.dart';
import '../../../managers/schedule_provider.dart';

import '../../../components/headers/nav_header.dart';
import '../../../components/loading_dialog.dart';
import '../../../components/admin/schedule/education_level_group_selector.dart';
import '../../../components/admin/schedule/day_filter.dart';
import '../../../components/admin/schedule/schedule_display.dart';
import '../../../components/admin/schedule/contact_info_card.dart';

/// ---- Clase auxiliar a nivel de archivo (NO anidada) ----
class _ParsedGroup {
  final int number;
  final String letter;
  const _ParsedGroup(this.number, this.letter);
}

class ScheduleManagementView extends StatefulWidget {
  const ScheduleManagementView({super.key});

  @override
  State<ScheduleManagementView> createState() => _ScheduleManagementViewState();
}

class _ScheduleManagementViewState extends State<ScheduleManagementView> {
  String? _selectedNivelEducativo;
  String? _selectedGrupo;
  String? _selectedDayKey; // "lunes" | "martes" | ... | null
  bool _isInitialized = false;

  UserProvider? _userProvider;
  VoidCallback? _userListener;

  @override
  void initState() {
    super.initState();
    _selectedDayKey = _getCurrentDayKey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Suscríbete a cambios de UserProvider una sola vez
    final up = Provider.of<UserProvider>(context);
    if (_userProvider != up) {
      _userProvider?.removeListener(_onUserChanged);
      _userProvider = up;
      _userListener = _onUserChanged;
      _userProvider!.addListener(_userListener!);

      // Intento de arranque inmediato si ya hay sesión
      _tryKickstart();
    }
  }

  @override
  void dispose() {
    // Limpia listener para evitar fugas
    _userProvider?.removeListener(_userListener ?? () {});
    super.dispose();
  }

  // ---------- Helpers de ordenamiento ----------

  _ParsedGroup? _tryParseGroup(String raw) {
    final s = raw.trim().toUpperCase();
    // Casos comunes: "1°A", "1A", "10 B", "2", "3°"
    final re = RegExp(r'^(\d+)\s*°?\s*([A-ZÁÉÍÓÚÑ]?)$');
    final m = re.firstMatch(s);
    if (m == null) return null;
    final numStr = m.group(1);
    final letter = (m.group(2) ?? '').trim();
    if (numStr == null) return null;
    final n = int.tryParse(numStr);
    if (n == null) return null;
    return _ParsedGroup(n, letter);
  }

  int _compareGroups(String a, String b) {
    final pa = _tryParseGroup(a);
    final pb = _tryParseGroup(b);
    if (pa != null && pb != null) {
      final c = pa.number.compareTo(pb.number);
      if (c != 0) return c;
      // Si ambos tienen letra, A-Z; si alguno no, el que no tiene va primero
      if (pa.letter.isEmpty && pb.letter.isNotEmpty) return -1;
      if (pb.letter.isEmpty && pa.letter.isNotEmpty) return 1;
      return pa.letter.compareTo(pb.letter);
    }
    // Fallback alfabético (case-insensitive)
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  List<String> _sortedGroupNames(Iterable<String> names) {
    final list = names.toList();
    list.sort(_compareGroups);
    return list;
  }

  // ---------- Otros helpers ----------

  String _getCurrentDayKey() {
    const keys = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo',
    ];
    final idx = DateTime.now().weekday - 1; // Mon=1..Sun=7
    return keys[idx.clamp(0, 6)];
  }

  // Evita depender de extensiones como .firstOrNull
  T? _firstOrNull<T>(Iterable<T> it) {
    final i = it.iterator;
    return i.moveNext() ? i.current : null;
  }

  // Reacciona a cambios del usuario:
  // - Si cierra sesión → limpia providers y UI.
  // - Si ahora sí hay escuelaId y no hemos iniciado → arranca.
  void _onUserChanged() {
    if (!mounted) return;
    final userProvider = _userProvider!;
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      // Logout: limpia estado de datos
      scheduleProvider.clearAllData();
      groupProvider.clearAllData();
      setState(() {
        _isInitialized = false;
        _selectedNivelEducativo = null;
        _selectedGrupo = null;
      });
      return;
    }

    // Si está logueado y aún no hemos iniciado, intenta arrancar
    _tryKickstart();
  }

  // Intenta arrancar una sola vez; resuelve escuelaId si hace falta.
  Future<void> _tryKickstart() async {
    if (!mounted || _isInitialized) return;

    final userProvider = _userProvider!;
    if (!userProvider.isLoggedIn) return;

    // Asegura escuelaId (admin por admin_access_list o tutor por alumno_tutores)
    String escuelaId;
    try {
      escuelaId = await userProvider.ensureEscuelaIdOrThrow();
    } catch (_) {
      // Si todavía no puede resolverse, no bloquees; reintentará en el próximo notifyListeners()
      return;
    }

    await _initializeScheduleData(escuelaId);
  }

  // Inicializa catálogos + grupos + horarios y arranca realtime para la escuela actual
  Future<void> _initializeScheduleData(String escuelaId) async {
    if (_isInitialized) return;
    if (!mounted) return;

    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    bool showHere = false;
    if (!LoadingDialog.isVisible) {
      LoadingDialog.show(context, message: 'Inicializando datos...');
      showHere = true;
    }

    try {
      await Future.wait([
        scheduleProvider.initialize(escuelaId,
            context: null), // evita diálogos encimados
        groupProvider.loadGroups(escuelaId: escuelaId, context: null),
      ]);

      // Arranca realtime (horarios/materias/grupos/turnos) para esta escuela
      await scheduleProvider.startRealtimeForSchool(escuelaId);

      final niveles = groupProvider.getAvailableNivelesEducativos();
      if (niveles.isNotEmpty && _selectedNivelEducativo == null) {
        setState(() {
          _selectedNivelEducativo = niveles.first;
          _isInitialized = true;
        });
        await _loadGruposForNivel(_selectedNivelEducativo!);
      } else {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing schedule data: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // evita bucles
        });
      }
    } finally {
      if (mounted && showHere) LoadingDialog.hide(context);
    }
  }

  Future<void> _loadGruposForNivel(String nivelEducativo) async {
    final userProvider = _userProvider!;
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Asegura escuelaId por si cambió o no estaba aún al entrar aquí
    final escuelaId = await userProvider.ensureEscuelaIdLoaded();
    if (escuelaId == null || escuelaId.isEmpty) return;

    try {
      final grupos = groupProvider.getGroupsByNivelEducativo(nivelEducativo);

      // ⚠️ Orden natural: numérico y luego alfabético
      final sortedGrupos = [...grupos]
        ..sort((a, b) => _compareGroups(a.grupo, b.grupo));

      debugPrint(
          'Grupos encontrados para $nivelEducativo: ${sortedGrupos.length}');

      if (sortedGrupos.isNotEmpty) {
        setState(() {
          _selectedGrupo = sortedGrupos.first.grupo;
        });

        await scheduleProvider.loadHorarios(
          escuelaId: escuelaId,
          grupoId: sortedGrupos.first.id,
          // ignore: use_build_context_synchronously
          context: context,
        );
      } else {
        setState(() {
          _selectedGrupo = null;
        });
        debugPrint('No se encontraron grupos para el nivel: $nivelEducativo');
      }
    } catch (e) {
      debugPrint('Error loading grupos: $e');
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer3<ThemeProvider, ScheduleProvider, GroupProvider>(
      builder:
          (context, themeProvider, scheduleProvider, groupProvider, child) {
        final error = scheduleProvider.error ?? groupProvider.error;
        final nivelesEducativos = groupProvider.getAvailableNivelesEducativos();

        // ⚠️ Orden natural aplicado a los nombres visibles en el selector
        final availableGrupos = _selectedNivelEducativo != null
            ? _sortedGroupNames(
                groupProvider
                    .getGroupsByNivelEducativo(_selectedNivelEducativo!)
                    .map((g) => g.grupo),
              )
            : <String>[];

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: l10n.scheduleManagement),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null)
                        _buildErrorState(error, screenSize)
                      else ...[
                        // Selector de nivel educativo y grupo
                        EducationLevelGroupSelector(
                          selectedNivelEducativo: _selectedNivelEducativo,
                          selectedGrupo: _selectedGrupo,
                          nivelesEducativos: nivelesEducativos,
                          grupos: availableGrupos,
                          onNivelEducativoChanged: (nivel) async {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _selectedNivelEducativo = nivel;
                              _selectedGrupo = null;
                            });
                            if (nivel != null) {
                              await _loadGruposForNivel(nivel);
                            }
                          },
                          onGrupoChanged: (grupo) async {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _selectedGrupo = grupo;
                            });
                            if (grupo != null &&
                                _selectedNivelEducativo != null) {
                              final grupos =
                                  groupProvider.getGroupsByNivelEducativo(
                                      _selectedNivelEducativo!);

                              // Evita depender de .firstOrNull
                              final selectedGrupoData = _firstOrNull(
                                grupos.where((g) => g.grupo == grupo),
                              );

                              if (selectedGrupoData != null) {
                                final escuelaId = await _userProvider!
                                    .ensureEscuelaIdLoaded();
                                if (escuelaId == null || escuelaId.isEmpty) {
                                  return;
                                }

                                // Primero intenta cache
                                final cached =
                                    scheduleProvider.getHorariosForGroupId(
                                        selectedGrupoData.id);

                                if (cached.isEmpty) {
                                  await scheduleProvider.loadHorarios(
                                    escuelaId: escuelaId,
                                    grupoId: selectedGrupoData.id,
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                  );
                                } else {
                                  // Cache listo → no recargamos
                                }
                              }
                            }
                          },
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                        // Filtro de día
                        DayFilter(
                          selectedDayKey: _selectedDayKey,
                          onDaySelected: (key) =>
                              setState(() => _selectedDayKey = key),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Vista de horario
                        if (_selectedGrupo != null)
                          ScheduleDisplay(
                            selectedGradeGroup: _selectedGrupo!,
                            selectedDayKey: _selectedDayKey,
                            schedules: scheduleProvider
                                .getHorariosForGroupName(_selectedGrupo!),
                            subjects: scheduleProvider.materias,
                            screenSize: screenSize,
                          )
                        else
                          _buildNoGroupSelectedState(screenSize),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Información de contacto
                        ContactInfoCard(screenSize: screenSize),
                      ],
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

  Widget _buildErrorState(String error, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: screenSize.width * 0.15,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            AppLocalizations.of(context).errorLoadingSchedule,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            error,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ElevatedButton.icon(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              LoadingDialog.show(context, message: 'Reintentando...');
              try {
                // Fuerza recarga de usuario y reintento de arranque
                await _userProvider?.reloadSilently(context);
                await _tryKickstart();
              } finally {
                if (mounted) LoadingDialog.hide(context);
              }
            },
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGroupSelectedState(Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppTheme.accentPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: screenSize.width * 0.12,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Selecciona un grupo',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Primero selecciona un nivel educativo y luego un grupo para ver los horarios',
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
