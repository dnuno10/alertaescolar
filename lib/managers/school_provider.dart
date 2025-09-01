// lib/managers/school_provider.dart
import 'package:alertaescolar/main.dart'; // expone: final supabase = Supabase.instance.client;
import 'package:alertaescolar/models/escuela.dart';
import 'package:flutter/foundation.dart';

class SchoolProvider with ChangeNotifier {
  Escuela? _currentSchool;
  bool _isLoading = false;
  String? _error;

  // Guard para evitar cargas concurrentes del mismo recurso.
  bool _loadingSchool = false;

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
    notifyListeners();
  }

  /// Lectura directa sin tocar el estado interno (útil para utilidades/validaciones).
  Future<Escuela?> getSchoolById(String schoolId) async {
    try {
      final response =
          await supabase.from('escuelas').select().eq('id', schoolId).single();
      return Escuela.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('SchoolProvider.getSchoolById error: $e');
      }
      return null;
    }
  }

  /// Carga en memoria (y cachea). Si `forceRefresh=false` y ya es la misma escuela, reaprovecha.
  /// Evita llamadas simultáneas con un guard sencillo.
  Future<Escuela?> loadSchool(String schoolId,
      {bool forceRefresh = false}) async {
    if (_loadingSchool) {
      // Si ya hay una carga en curso, devolvemos lo último conocido.
      return _currentSchool;
    }

    if (!forceRefresh && _currentSchool?.id == schoolId) {
      return _currentSchool;
    }

    _loadingSchool = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await supabase.from('escuelas').select().eq('id', schoolId).single();

      _currentSchool = Escuela.fromJson(response);
      return _currentSchool;
    } catch (e) {
      _error = 'Error loading school: $e';
      if (kDebugMode) {
        print('SchoolProvider.loadSchool error: $e');
      }
      return null;
    } finally {
      _loadingSchool = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza en BD y sincroniza el cache local.
  Future<bool> updateSchool(Escuela updatedSchool) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await supabase
          .from('escuelas')
          .update(updatedSchool.toJson())
          .eq('id', updatedSchool.id);

      _currentSchool = updatedSchool;
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
