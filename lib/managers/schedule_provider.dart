import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/loading_dialog.dart';
import '../models/models.dart';
import '../utils/time_format.dart';

class ScheduleProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Materia> _materias = [];
  List<Grupo> _grupos = [];
  List<Map<String, dynamic>> _nivelesEducativos = [];

  /// Key: idGrupo, Value: lista de clases del grupo
  final Map<String, List<ClaseHorario>> _horariosPorGrupoId = {};

  bool _isLoading = false;
  String? _error;

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

      final response = await _supabase
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

      final response = await _supabase
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
    String?
        nivelEducativoId, // si quieres filtrar por id de nivel (tabla niveles_educativos)
    String?
        nivelEducativoNombre, // o directo por nombre (lo que guarda grupos.nivel_educativo)
    bool loadAll = false,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando grupos...');
      }
      _safeNotifyListeners();

      var query = _supabase.from('grupos').select().eq('id_escuela', escuelaId);

      if (!loadAll) {
        if (nivelEducativoNombre != null && nivelEducativoNombre.isNotEmpty) {
          query = query.eq('nivel_educativo', nivelEducativoNombre);
        } else if (nivelEducativoId != null) {
          // traducir id -> nombre usando _nivelesEducativos ya cargados
          final nivel = _firstOrNull(_nivelesEducativos
              .where((n) => (n['id']?.toString() ?? '') == nivelEducativoId));
          final nombre = nivel?['nombre']?.toString();
          if (nombre != null && nombre.isNotEmpty) {
            query = query.eq('nivel_educativo', nombre);
          }
        }
      }

      final response = await query.order('grupo');
      _grupos =
          (response as List).map<Grupo>((row) => Grupo.fromJson(row)).toList();

      _error = null;

      debugPrint('Grupos cargados: ${_grupos.length}');
      for (final g in _grupos) {
        debugPrint('Grupo: ${g.grupo} | Nivel: ${g.nivelEducativo}');
      }
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
    String? grupoId, // opcional para filtrar por un grupo específico
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando horarios...');
      }
      _safeNotifyListeners();

      var query =
          _supabase.from('horarios').select().eq('id_escuela', escuelaId);

      if (grupoId != null && grupoId.isNotEmpty) {
        query = query.eq('id_grupo', grupoId);
      }

      final response = await query;
      final list =
          (response as List).map((r) => ClaseHorario.fromJson(r)).toList();

      _horariosPorGrupoId.clear();
      for (final ch in list) {
        _horariosPorGrupoId.putIfAbsent(ch.idGrupo, () => []).add(ch);
      }

      _error = null;
    } catch (e) {
      _error = 'Error al cargar horarios: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      _safeNotifyListeners();
    }
  }

  // ===== Helpers de consulta (por ID y por nombre para compatibilidad UI) =====

  Grupo? getGrupoById(String grupoId) {
    return _firstOrNull(_grupos.where((g) => g.id == grupoId));
  }

  Grupo? getGrupoByName(String nombreGrupo) {
    return _firstOrNull(_grupos
        .where((g) => g.grupo.toLowerCase() == nombreGrupo.toLowerCase()));
  }

  /// Devuelve horarios por **id de grupo** (recomendado)
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

  // ===== Listas de nombres para UI =====
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
    debugPrint('Grupos filtrados para nivel $nombre: ${res.length}');
    return res;
  }

  // Filtra grupos por **nombre** de nivel educativo (lo que guarda la tabla grupos)
  List<Grupo> getGruposByNivelEducativoName(String nivelNombre) {
    final res = _grupos.where((g) => g.nivelEducativo == nivelNombre).toList();
    debugPrint('Grupos filtrados para nivel $nivelNombre: ${res.length}');
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

  // ===== Debug =====
  void debugPrintAllData() {
    debugPrint('=== NIVELES EDUCATIVOS ===');
    for (var n in _nivelesEducativos) {
      debugPrint('ID: ${n['id']}, Nombre: ${n['nombre']}');
    }
    debugPrint('=== GRUPOS ===');
    for (var g in _grupos) {
      debugPrint('ID: ${g.id}, Grupo: ${g.grupo}, Nivel: ${g.nivelEducativo}');
    }
  }

  // ===== Inicialización =====
  Future<void> initialize(String escuelaId, {BuildContext? context}) async {
    await loadNivelesEducativos(escuelaId: escuelaId, context: context);
    await loadMaterias(escuelaId: escuelaId, context: context);
    await loadGrupos(
      escuelaId: escuelaId,
      loadAll: true,
      context: context,
    );
    await loadHorarios(escuelaId: escuelaId, context: context);
  }

  // ===== Limpieza =====
  void clearAllData() {
    _materias = [];
    _grupos = [];
    _nivelesEducativos = [];
    _horariosPorGrupoId.clear();
    _isLoading = false;
    _error = null;
    _safeNotifyListeners();
  }
}
