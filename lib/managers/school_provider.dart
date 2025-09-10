import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/models/escuela.dart';

class SchoolProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Escuela? _currentSchool;
  bool _isLoading = false;
  String? _error;
  final Map<String, Future<Escuela?>> _inFlightLoads = {};

  final Map<String, Escuela> _cache = {};

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
    _cache.clear();
    _nameCache.clear();
    notifyListeners();
  }

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
      _nameCache[schoolId] = escuela.nombre;
      return escuela;
    } catch (e) {
      if (kDebugMode) {
        print('SchoolProvider.getSchoolById error: $e');
      }
      return null;
    }
  }

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

  Future<Escuela?> loadSchool(String schoolId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _currentSchool?.id == schoolId) {
      return _currentSchool;
    }

    final existingFuture = _inFlightLoads[schoolId];
    if (!forceRefresh && existingFuture != null) {
      return await existingFuture;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final future = () async {
      try {
        final escuela = await getSchoolById(schoolId, useCache: !forceRefresh);
        _currentSchool = escuela;

        if (escuela != null) {
          _cache[escuela.id] = escuela;
          _nameCache[escuela.id] = escuela.nombre;
        }

        return escuela;
      } catch (e) {
        _error = 'Error loading school: $e';
        return null;
      } finally {
        _isLoading = false;
        _inFlightLoads.remove(schoolId);
        notifyListeners();
      }
    }();

    _inFlightLoads[schoolId] = future;
    return await future;
  }

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

      final updated = Escuela.fromJson(updateResult);

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
