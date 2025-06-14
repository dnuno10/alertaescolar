import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class UserProvider extends ChangeNotifier {
  Usuario? _currentUser;
  bool _isLoading = false;
  String? _error;

  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  final SupabaseClient _supabase = Supabase.instance.client;

  // Carga el usuario actual desde Supabase
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if there's an active user session
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No active user session found');
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get user data from supabase
      final userData = await _supabase
          .from('usuarios')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (userData != null) {
        debugPrint('User found in database: ${user.id}');
        _currentUser = Usuario.fromJson(userData);
      } else {
        debugPrint('User authenticated but not in database: ${user.id}');
        // If user is authenticated but not in database, initialize with basic data
        _currentUser = Usuario(
          id: user.id,
          nombre: user.userMetadata?['full_name']?.split(' ').first ?? '',
          apellido:
              user.userMetadata?['full_name']?.split(' ').skip(1).join(' ') ??
                  '',
          email: user.email ?? '',
          fotoUrl: user.userMetadata?['avatar_url'],
          fechaRegistro: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualiza el usuario en memoria y opcionalmente en la base de datos
  Future<void> updateUser(Usuario user, {bool saveToDatabase = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Si se solicita guardar en la base de datos
      if (saveToDatabase) {
        await _supabase.from('usuarios').upsert({
          'id': user.id,
          'email': user.email,
          'nombre': user.nombre,
          'apellido': user.apellido,
          'tipo': user.tipo.name,
          'foto_url': user.fotoUrl,
          'id_escuela': user.escuelaId,
          'tipo_administrador': user.tipoAdministrador?.name,
          'fecha_registro': user.fechaRegistro.toIso8601String(),
        });
        debugPrint('User data saved to database: ${user.id}');
      }

      // Actualizar el usuario en memoria
      _currentUser = user;
      debugPrint('User updated in provider: ${user.id}');
    } catch (e) {
      debugPrint('Error updating user: $e');
      _error = e.toString();
      rethrow; // Re-lanzar la excepción para que pueda ser manejada por el llamador
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cierra la sesión y limpia los datos del usuario
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
    debugPrint('User logged out from provider');
  }

  // Verifica si el usuario tiene datos completos
  bool hasCompleteProfile() {
    if (_currentUser == null) return false;
    return _currentUser!.nombre.isNotEmpty && _currentUser!.apellido.isNotEmpty;
  }

  // Verifica si el usuario es administrador
  bool isAdmin() {
    return _currentUser?.tipo == TipoUsuario.administrador;
  }
}
