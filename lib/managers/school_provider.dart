import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/models/escuela.dart';

class SchoolProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Escuela? _currentSchool;
  bool _isLoading = false;
  String? _error;

  bool _loadingSchool = false;

  // Caché simple por ID (objeto completo)
  final Map<String, Escuela> _cache = {};

  // Caché liviano para solo "nombre" (reduce roundtrips cuando solo queremos mostrarlo)
  final Map<String, String> _nameCache = {};

  Escuela? get currentSchool => _currentSchool;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAllData() {
    _currentSchool = null;
    _isLoading = false;
    _error = null;
    _loadingSchool = false;
    _cache.clear();
    _nameCache.clear();
    notifyListeners();
  }

  /// Devuelve la escuela por ID.
  /// - Si `useCache` es true y existe en caché, lo regresa sin consultar BD.
  Future<Escuela?> getSchoolById(String schoolId,
      {bool useCache = true}) async {
    try {
      if (useCache && _cache.containsKey(schoolId)) {
        return _cache[schoolId];
      }

      final response = await _supabase
          .from('escuelas')
          .select('*')
          .eq('id', schoolId)
          .maybeSingle();

      if (response == null) return null;

      final escuela = Escuela.fromJson(response);
      _cache[schoolId] = escuela;
      _nameCache[schoolId] = escuela.nombre; // mantener nombre sincronizado
      return escuela;
    } catch (e) {
      if (kDebugMode) {
        print('SchoolProvider.getSchoolById error: $e');
      }
      return null;
    }
  }

  /// Devuelve SOLO el nombre de la escuela por ID (consulta ligera).
  /// - Usa caché de nombres y permite `forceRefresh`.
  Future<String?> getSchoolNameById(String schoolId,
      {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _nameCache.containsKey(schoolId)) {
        return _nameCache[schoolId];
      }

      final response = await _supabase
          .from('escuelas')
          .select('id, nombre')
          .eq('id', schoolId)
          .maybeSingle();

      final nombre = response?['nombre']?.toString();
      if (nombre != null) {
        _nameCache[schoolId] = nombre;
        // si ya estaba en el cache completo, sincronizamos el nombre
        if (_cache.containsKey(schoolId)) {
          _cache[schoolId] = _cache[schoolId]!.copyWith(nombre: nombre);
        }
      }
      return nombre;
    } catch (e) {
      if (kDebugMode) {
        print('SchoolProvider.getSchoolNameById error: $e');
      }
      return null;
    }
  }

  /// Carga la escuela "actual" y la deja disponible en `currentSchool`.
  /// - Si `forceRefresh` es false y `_currentSchool` ya coincide, evita nueva consulta.
  Future<Escuela?> loadSchool(String schoolId,
      {bool forceRefresh = false}) async {
    if (_loadingSchool) return _currentSchool;

    if (!forceRefresh && _currentSchool?.id == schoolId) {
      // Ya cargada; no hacemos nada más
      return _currentSchool;
    }

    _loadingSchool = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Reusar getSchoolById con cache controlado
      final escuela = await getSchoolById(schoolId, useCache: !forceRefresh);
      _currentSchool = escuela;
      return _currentSchool;
    } catch (e) {
      _error = 'Error loading school: $e';
      if (kDebugMode) print('SchoolProvider.loadSchool error: $e');
      return null;
    } finally {
      _loadingSchool = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza en BD y sincroniza caches + estado.
  Future<bool> updateSchool(Escuela updatedSchool) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (updatedSchool.id.isEmpty) {
        _error = 'School id is empty';
        return false;
      }

      if (kDebugMode) {
        print('SchoolProvider: Actualizando escuela ${updatedSchool.id}');
        print('SchoolProvider: Datos a enviar: ${updatedSchool.toJson()}');
      }

      // Verificar primero que el registro existe y es visible
      final existingRecord = await _supabase
          .from('escuelas')
          .select('id, nombre')
          .eq('id', updatedSchool.id)
          .maybeSingle();

      if (existingRecord == null) {
        _error =
            'No se encontró la escuela con ID ${updatedSchool.id} o no tienes permisos para verla';
        if (kDebugMode) {
          print(
              'SchoolProvider: ERROR - Registro no encontrado o sin permisos');
        }
        return false;
      }

      final updateResult = await _supabase
          .from('escuelas')
          .update(updatedSchool.toJson())
          .eq('id', updatedSchool.id)
          .select()
          .maybeSingle();

      if (updateResult == null) {
        _error =
            'UPDATE no afectó ninguna fila - posible problema de permisos RLS';
        if (kDebugMode) {
          print('SchoolProvider: ERROR - UPDATE no afectó ninguna fila');
        }
        return false;
      }

      // Si llegamos aquí, el UPDATE fue exitoso
      final updated = Escuela.fromJson(updateResult);

      // Sincronizar estado y caches
      _currentSchool = updated;
      _cache[updated.id] = updated;
      _nameCache[updated.id] = updated.nombre;

      if (kDebugMode) {
        print('SchoolProvider: Datos actualizados confirmados desde BD');
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating school: $e';
      if (kDebugMode) {
        print('SchoolProvider.updateSchool error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
