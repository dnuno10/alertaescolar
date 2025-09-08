import 'package:alertaescolar/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/loading_dialog.dart';
import '../models/models.dart';

class ScheduleProvider with ChangeNotifier {
  List<Materia> _materias = [];
  List<Grupo> _grupos = [];
  List<Map<String, dynamic>> _nivelesEducativos = [];

  /// Key: idGrupo, Value: lista de clases del grupo
  final Map<String, List<ClaseHorario>> _horariosPorGrupoId = {};

  bool _isLoading = false;
  String? _error;

  RealtimeChannel? _chHorarios;
  RealtimeChannel? _chMaterias;
  RealtimeChannel? _chGrupos;
  RealtimeChannel? _chTurnos;

  String? _currentSchoolIdForRealtime;

  // Getters
  List<Materia> get materias => _materias;
  List<Grupo> get grupos => _grupos;
  List<Map<String, dynamic>> get nivelesEducativos => _nivelesEducativos;
  Map<String, List<ClaseHorario>> get horariosPorGrupoId => _horariosPorGrupoId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ===== Utilidades internas =====
  T? _firstOrNull<T>(Iterable<T> it) {
    final i = it.iterator;
    return i.moveNext() ? i.current : null;
  }

  void _safeNotifyListeners() {
    Future.microtask(() => notifyListeners());
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  void _disposeRealtime() {
    try {
      _chHorarios?.unsubscribe();
    } catch (_) {}
    try {
      _chMaterias?.unsubscribe();
    } catch (_) {}
    try {
      _chGrupos?.unsubscribe();
    } catch (_) {}
    try {
      _chTurnos?.unsubscribe();
    } catch (_) {}
    _chHorarios = _chMaterias = _chGrupos = _chTurnos = null;
  }

  /// Arranca realtime tomando la escuela del tutor (vía alumno_tutores)
  Future<void> startRealtimeForTutor(String userId) async {
    final schoolId = await _getUserSchoolId(userId);
    if (schoolId != null) {
      await startRealtimeForSchool(schoolId);
    } else {
      debugPrint('ScheduleProvider.startRealtimeForTutor: no se halló escuela');
    }
  }

  /// Arranca realtime para una escuela (filtra por id_escuela en tablas clave)
  Future<void> startRealtimeForSchool(String escuelaId) async {
    // Evita re-crear suscripciones iguales
    if (_currentSchoolIdForRealtime == escuelaId &&
        (_chHorarios != null ||
            _chMaterias != null ||
            _chGrupos != null ||
            _chTurnos != null)) {
      return;
    }

    _disposeRealtime();
    _currentSchoolIdForRealtime = escuelaId;

    // --- HORARIOS ---
    _chHorarios = supabase.channel('sch_horarios_$escuelaId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'horarios',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_escuela',
          value: escuelaId,
        ),
        callback: (payload) async {
          try {
            final newRec = payload.newRecord as Map<String, dynamic>?;
            final oldRec = payload.oldRecord as Map<String, dynamic>?;

            final affectedSchool =
                (newRec?['id_escuela'] ?? oldRec?['id_escuela'])?.toString();
            if (affectedSchool != escuelaId) return;

            final affectedGroupId =
                (newRec?['id_grupo'] ?? oldRec?['id_grupo'])?.toString();

            if (affectedGroupId != null && affectedGroupId.isNotEmpty) {
              await loadHorarios(
                escuelaId: escuelaId,
                grupoId: affectedGroupId,
                context: null, // evita superposición de diálogos
              );
            } else {
              await loadHorarios(escuelaId: escuelaId, context: null);
            }
          } catch (e) {
            debugPrint('Realtime horarios callback error: $e');
          }
        },
      )
      ..subscribe();

    // --- MATERIAS ---
    _chMaterias = supabase.channel('sch_materias_$escuelaId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'materias',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_escuela',
          value: escuelaId,
        ),
        callback: (payload) async {
          await loadMaterias(escuelaId: escuelaId, context: null);
        },
      )
      ..subscribe();

    // --- GRUPOS ---
    _chGrupos = supabase.channel('sch_grupos_$escuelaId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'grupos',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_escuela',
          value: escuelaId,
        ),
        callback: (payload) async {
          await loadGrupos(escuelaId: escuelaId, loadAll: true, context: null);
          await loadHorarios(escuelaId: escuelaId, context: null);
        },
      )
      ..subscribe();

    // --- TURNOS ---
    _chTurnos = supabase.channel('sch_turnos_$escuelaId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'turnos',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_escuela',
          value: escuelaId,
        ),
        callback: (payload) async {
          _safeNotifyListeners();
        },
      )
      ..subscribe();
  }

  /// Detiene todas las suscripciones
  Future<void> stopRealtime() async {
    _disposeRealtime();
    _currentSchoolIdForRealtime = null;
  }

  Future<String?> _getUserSchoolId(String userId) async {
    try {
      final resp = await supabase.from('alumno_tutores').select('''
        alumnos!inner(id_escuela)
      ''').eq('id_tutor', userId).limit(1);
      if (resp.isNotEmpty) {
        final alumno = (resp.first['alumnos'] as Map?) ?? {};
        final raw = (alumno['id_escuela'] ?? '').toString().trim();
        return raw.isEmpty ? null : raw;
      }
      return null;
    } catch (e) {
      debugPrint('_getUserSchoolId error: $e');
      return null;
    }
  }

  // ===== Niveles educativos =====
  Future<void> loadNivelesEducativos({
    required String escuelaId,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando niveles educativos...');
      }
      _safeNotifyListeners();

      final response = await supabase
          .from('niveles_educativos')
          .select()
          .eq('id_escuela', escuelaId)
          .order('nombre');

      _nivelesEducativos = (response as List).cast<Map<String, dynamic>>();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar niveles educativos: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      _safeNotifyListeners();
    }
  }

  // ===== Materias =====
  Future<void> loadMaterias({
    required String escuelaId,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando materias...');
      }
      _safeNotifyListeners();

      final response = await supabase
          .from('materias')
          .select()
          .eq('id_escuela', escuelaId)
          .order('nombre');

      _materias =
          (response as List).map((item) => Materia.fromJson(item)).toList();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar materias: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      _safeNotifyListeners();
    }
  }

  // ===== Grupos =====
  Future<void> loadGrupos({
    required String escuelaId,
    String? nivelEducativoId,
    String? nivelEducativoNombre,
    bool loadAll = false,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando grupos...');
      }
      _safeNotifyListeners();

      var filterBuilder =
          supabase.from('grupos').select().eq('id_escuela', escuelaId);

      if (!loadAll) {
        if (nivelEducativoNombre != null && nivelEducativoNombre.isNotEmpty) {
          filterBuilder =
              filterBuilder.eq('nivel_educativo', nivelEducativoNombre);
        } else if (nivelEducativoId != null) {
          final nivel = _firstOrNull(_nivelesEducativos
              .where((n) => (n['id']?.toString() ?? '') == nivelEducativoId));
          final nombre = nivel?['nombre']?.toString();
          if (nombre != null && nombre.isNotEmpty) {
            filterBuilder = filterBuilder.eq('nivel_educativo', nombre);
          }
        }
      }

      // Orden al final para mantener el tipo correcto
      final response = await filterBuilder.order('grupo');

      _grupos =
          (response as List).map<Grupo>((row) => Grupo.fromJson(row)).toList();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar grupos: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      _safeNotifyListeners();
    }
  }

  // ===== Horarios =====
  Future<void> loadHorarios({
    required String escuelaId,
    String? grupoId,
    BuildContext? context,
  }) async {
    bool showDialogHere = false;
    try {
      _isLoading = true;
      _error = null;

      if (context != null && context.mounted) {
        // evita abrir múltiples diálogos si ya hay uno activo
        if (!LoadingDialog.isVisible) {
          LoadingDialog.show(context, message: 'Cargando horarios...');
          showDialogHere = true;
        }
      }
      _safeNotifyListeners();

      // Filtros primero
      var filterBuilder =
          supabase.from('horarios').select().eq('id_escuela', escuelaId);

      if (grupoId != null && grupoId.isNotEmpty) {
        filterBuilder = filterBuilder.eq('id_grupo', grupoId);
      }

      // ❗ No existe 'dia_semana' en la tabla, solo booleans por día.
      // Ordenamos por hora de inicio únicamente.
      final response =
          await filterBuilder.order('hora_inicio', ascending: true);

      final list =
          (response as List).map((r) => ClaseHorario.fromJson(r)).toList();

      if (grupoId == null || grupoId.isEmpty) {
        _horariosPorGrupoId.clear();
        for (final ch in list) {
          _horariosPorGrupoId.putIfAbsent(ch.idGrupo, () => []).add(ch);
        }
      } else {
        _horariosPorGrupoId[grupoId] = list;
      }

      _error = null;
    } catch (e) {
      _error = 'Error al cargar horarios: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted && showDialogHere) {
        LoadingDialog.hide(context);
      }
      _safeNotifyListeners();
    }
  }

  // ===== Helpers =====

  Grupo? getGrupoById(String grupoId) {
    return _firstOrNull(_grupos.where((g) => g.id == grupoId));
  }

  Grupo? getGrupoByName(String nombreGrupo) {
    return _firstOrNull(_grupos
        .where((g) => g.grupo.toLowerCase() == nombreGrupo.toLowerCase()));
  }

  /// Devuelve horarios por **id de grupo**
  List<ClaseHorario> getHorariosForGroupId(String grupoId) {
    return _horariosPorGrupoId[grupoId] ?? const [];
  }

  /// Compatibilidad: permite pedir por **nombre** del grupo
  List<ClaseHorario> getHorariosForGroupName(String nombreGrupo) {
    final g = getGrupoByName(nombreGrupo);
    if (g == null) return const [];
    return getHorariosForGroupId(g.id);
  }

  Materia? getMateriaById(String materiaId) {
    return _firstOrNull(_materias.where((m) => m.id == materiaId));
  }

  // ===== Listas de nombres para UI (opcionales) =====
  List<String> getGruposNames() => _grupos.map((g) => g.grupo).toList();

  List<String> getNivelesEducativosNames() =>
      _nivelesEducativos.map((n) => n['nombre'].toString()).toList();

  Map<String, dynamic>? getNivelEducativoByName(String nombre) {
    return _firstOrNull(
        _nivelesEducativos.where((n) => (n['nombre'] ?? '') == nombre));
  }

  // Filtra grupos por **id** de nivel educativo (traduce a nombre internamente)
  List<Grupo> getGruposByNivelEducativo(String nivelEducativoId) {
    final nivel = _firstOrNull(_nivelesEducativos
        .where((n) => (n['id']?.toString() ?? '') == nivelEducativoId));
    if (nivel == null) {
      debugPrint('Nivel educativo no encontrado para ID: $nivelEducativoId');
      return const [];
    }
    final nombre = (nivel['nombre'] ?? '').toString();
    final res = _grupos.where((g) => g.nivelEducativo == nombre).toList();
    return res;
  }

  // Filtra grupos por **nombre** de nivel educativo
  List<Grupo> getGruposByNivelEducativoName(String nivelNombre) {
    final res = _grupos.where((g) => g.nivelEducativo == nivelNombre).toList();
    return res;
  }

  List<String> getGruposNamesByNivelEducativo(String nivelEducativoId) =>
      getGruposByNivelEducativo(nivelEducativoId).map((g) => g.grupo).toList();

  List<String> getGruposNamesByNivelEducativoName(String nivelNombre) =>
      getGruposByNivelEducativoName(nivelNombre).map((g) => g.grupo).toList();

  /// Regresa el **nombre del nivel** para un grupo dado por ID
  String? getNivelEducativoNameForGroup(String grupoId) {
    final g = getGrupoById(grupoId);
    return g?.nivelEducativo;
  }

  // ===== Inicialización de todo =====
  Future<void> initialize(String escuelaId, {BuildContext? context}) async {
    bool showDialogHere = false;
    try {
      _isLoading = true;
      _error = null;

      if (context != null && context.mounted) {
        if (!LoadingDialog.isVisible) {
          LoadingDialog.show(context, message: 'Inicializando horarios...');
          showDialogHere = true;
        }
      }
      _safeNotifyListeners();

      await loadNivelesEducativos(escuelaId: escuelaId);
      await loadMaterias(escuelaId: escuelaId);
      await loadGrupos(escuelaId: escuelaId, loadAll: true);
      await loadHorarios(escuelaId: escuelaId);

      _error = null;
    } catch (e) {
      _error = 'Error al inicializar: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted && showDialogHere) {
        LoadingDialog.hide(context);
      }
      _safeNotifyListeners();
    }
  }

  // ===== Limpieza =====
  void clearAllData() {
    _disposeRealtime();
    _materias = [];
    _grupos = [];
    _nivelesEducativos = [];
    _horariosPorGrupoId.clear();
    _isLoading = false;
    _error = null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposeRealtime();
    super.dispose();
  }
}
