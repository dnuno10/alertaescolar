import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../components/loading_dialog.dart';

class ScheduleProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Materia> _materias = [];
  List<Map<String, dynamic>> _grupos = [];
  List<Map<String, dynamic>> _nivelesEducativos = [];
  Map<String, List<ClaseHorario>> _horarios = {};

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Materia> get materias => _materias;
  List<Map<String, dynamic>> get grupos => _grupos;
  List<Map<String, dynamic>> get nivelesEducativos => _nivelesEducativos;
  Map<String, List<ClaseHorario>> get horarios => _horarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error message
  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  // Load niveles educativos
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

  // Load materias (subjects)
  Future<void> loadMaterias({
    String? escuelaId,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando materias...');
      }
      // Safely notify listeners
      _safeNotifyListeners();

      final response = await _supabase
          .from('materias')
          .select()
          .eq('id_escuela', escuelaId!)
          .order('nombre');

      // Supabase Flutter SDK returns non-null response
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
      // Safely notify listeners
      _safeNotifyListeners();
    }
  }

  // Load groups
  Future<void> loadGrupos({
    String? escuelaId,
    String? nivelEducativoId,
    String? nivelEducativo, // Add this parameter for backward compatibility
    BuildContext? context,
    bool loadAll = false, // Add this parameter to load all groups
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando grupos...');
      }
      _safeNotifyListeners();

      var query =
          _supabase.from('grupos').select().eq('id_escuela', escuelaId!);

      // Only filter if we're not loading all groups and have a filter parameter
      if (!loadAll) {
        if (nivelEducativoId != null) {
          // Convert nivel educativo ID to name first since grupos table stores names
          final nivelEducativoData = _nivelesEducativos
              .where((nivel) => nivel['id'] == nivelEducativoId)
              .firstOrNull;
          if (nivelEducativoData != null) {
            query = query.eq('nivel_educativo', nivelEducativoData['nombre']);
          }
        } else if (nivelEducativo != null) {
          // Use the name directly since that's what's stored in the grupos table
          query = query.eq('nivel_educativo', nivelEducativo);
        }
      }

      final response = await query.order('grupo');

      // Supabase Flutter SDK returns non-null response
      _grupos = (response as List).cast<Map<String, dynamic>>();
      _error = null;

      debugPrint('Grupos cargados: ${_grupos.length}');
      for (var grupo in _grupos) {
        debugPrint(
            'Grupo: ${grupo['grupo']}, NivelEducativo: ${grupo['nivel_educativo']}');
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

  // Load schedules for a specific group or all groups
  Future<void> loadHorarios({
    String? escuelaId,
    String? grupoId,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando horarios...');
      }
      _safeNotifyListeners();

      var query =
          _supabase.from('horarios').select().eq('id_escuela', escuelaId!);

      if (grupoId != null) {
        query = query.eq('id_grupo', grupoId);
      }

      final response = await query;

      // Supabase Flutter SDK returns non-null response
      final horariosList = (response as List).cast<Map<String, dynamic>>();
      _horarios.clear();

      // Process the schedules and organize by group
      for (var horario in horariosList) {
        final claseHorario = _mapToClaseHorario(horario);
        final grupo = await _getGrupoById(horario['id_grupo']);
        final grupoKey = grupo?['grupo'] ?? 'sin_grupo';

        if (!_horarios.containsKey(grupoKey)) {
          _horarios[grupoKey] = [];
        }

        _horarios[grupoKey]?.add(claseHorario);
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

  // Get group by ID (improved helper method)
  Future<Map<String, dynamic>?> _getGrupoById(String grupoId) async {
    try {
      // First check in already loaded groups
      final cachedGrupo =
          _grupos.where((grupo) => grupo['id'] == grupoId).firstOrNull;

      if (cachedGrupo != null) return cachedGrupo;

      // If not found, fetch from database
      final response =
          await _supabase.from('grupos').select().eq('id', grupoId).single();

      return response;
    } catch (e) {
      debugPrint('Error fetching grupo: $e');
      return null;
    }
  }

  // Get grupo by name (new method)
  Map<String, dynamic>? getGrupoByName(String grupoName) {
    try {
      return _grupos.firstWhere((grupo) => grupo['grupo'] == grupoName);
    } catch (e) {
      debugPrint('Grupo no encontrado: $grupoName');
      return null;
    }
  }

  // Convert map from DB to ClaseHorario object
  ClaseHorario _mapToClaseHorario(Map<String, dynamic> data) {
    // Map the days of the week to DiaSemana enum
    DiaSemana? getDia() {
      if (data['lunes'] == true) return DiaSemana.lunes;
      if (data['martes'] == true) return DiaSemana.martes;
      if (data['miercoles'] == true) return DiaSemana.miercoles;
      if (data['jueves'] == true) return DiaSemana.jueves;
      if (data['viernes'] == true) return DiaSemana.viernes;
      if (data['sabado'] == true) return DiaSemana.sabado;
      if (data['domingo'] == true) return DiaSemana.domingo;
      return DiaSemana.lunes; // Default
    }

    // Format time from timestamp
    String formatTimeFromTimestamp(dynamic timestamp) {
      if (timestamp == null) return '';
      try {
        final DateTime dateTime = DateTime.parse(timestamp);
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return '';
      }
    }

    return ClaseHorario(
      id: data['id'] ?? '',
      materiaId: data['id_materia'] ?? '',
      escuelaId: data['id_escuela'] ?? '',
      grupo: data['id_grupo'] ?? '',
      dia: getDia()!,
      horaInicio: formatTimeFromTimestamp(data['hora_inicio']),
      horaFin: formatTimeFromTimestamp(data['hora_fin']),
      aula: data['aula'] ?? '',
    );
  }

  // Get schedules for a specific group
  List<ClaseHorario> getHorariosForGroup(String group) {
    return _horarios[group] ?? [];
  }

  // Get materia by ID
  Materia? getMateriaById(String materiaId) {
    try {
      return _materias.firstWhere((materia) => materia.id == materiaId);
    } catch (e) {
      return null;
    }
  }

  // Get all group names
  List<String> getGruposNames() {
    return _grupos
        .map((grupo) => grupo['grupo']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  // Get all educational level names
  List<String> getNivelesEducativosNames() {
    return _nivelesEducativos
        .map((nivel) => nivel['nombre'].toString())
        .toList();
  }

  // Get nivel educativo by name
  Map<String, dynamic>? getNivelEducativoByName(String nombre) {
    try {
      return _nivelesEducativos
          .firstWhere((nivel) => nivel['nombre'] == nombre);
    } catch (e) {
      return null;
    }
  }

  // Get groups by nivel educativo id (fixed to use name instead of ID)
  List<Map<String, dynamic>> getGruposByNivelEducativo(
      String nivelEducativoId) {
    // Convert ID to name first
    final nivelEducativoData = _nivelesEducativos
        .where((nivel) => nivel['id'] == nivelEducativoId)
        .firstOrNull;

    if (nivelEducativoData == null) {
      debugPrint('Nivel educativo no encontrado para ID: $nivelEducativoId');
      return [];
    }

    final nivelEducativoName = nivelEducativoData['nombre'];
    final filteredGroups = _grupos
        .where((grupo) => grupo['nivel_educativo'] == nivelEducativoName)
        .toList();

    debugPrint(
        'Grupos filtrados para nivel $nivelEducativoName (ID: $nivelEducativoId): ${filteredGroups.length}');
    return filteredGroups;
  }

  // Get groups by nivel educativo name (updated method)
  List<Map<String, dynamic>> getGruposByNivelEducativoName(String nivelNombre) {
    final filteredGroups = _grupos
        .where((grupo) => grupo['nivel_educativo'] == nivelNombre)
        .toList();

    debugPrint(
        'Grupos filtrados para nivel $nivelNombre: ${filteredGroups.length}');
    return filteredGroups;
  }

  // Get groups names by nivel educativo
  List<String> getGruposNamesByNivelEducativo(String nivelEducativoId) {
    return getGruposByNivelEducativo(nivelEducativoId)
        .map((grupo) => grupo['grupo']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  // Get groups names by nivel educativo name
  List<String> getGruposNamesByNivelEducativoName(String nivelNombre) {
    return getGruposByNivelEducativoName(nivelNombre)
        .map((grupo) => grupo['grupo']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  // Get nivel educativo name for a group
  String? getNivelEducativoNameForGroup(String grupoId) {
    final grupo = _grupos.where((g) => g['id'] == grupoId).firstOrNull;
    if (grupo == null) return null;

    // Since nivel_educativo in grupos table stores the name directly
    return grupo['nivel_educativo'];
  }

  // Debug method to print all data
  void debugPrintAllData() {
    debugPrint('=== NIVELES EDUCATIVOS ===');
    for (var nivel in _nivelesEducativos) {
      debugPrint('ID: ${nivel['id']}, Nombre: ${nivel['nombre']}');
    }

    debugPrint('=== GRUPOS ===');
    for (var grupo in _grupos) {
      debugPrint(
          'ID: ${grupo['id']}, Grupo: ${grupo['grupo']}, NivelEducativo: ${grupo['nivel_educativo']}');
    }
  }

  // Initialize - load all required data
  Future<void> initialize(String escuelaId, {BuildContext? context}) async {
    await loadNivelesEducativos(escuelaId: escuelaId, context: context);
    await loadMaterias(escuelaId: escuelaId, context: context);
    await loadGrupos(
        escuelaId: escuelaId,
        context: context,
        loadAll: true); // Load all groups
    await loadHorarios(escuelaId: escuelaId, context: context);
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    // Use microtask to ensure notifyListeners is not called during build
    Future.microtask(() {
      notifyListeners();
    });
  }
}
