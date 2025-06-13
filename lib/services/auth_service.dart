import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../managers/user_provider.dart';
import '../models/models.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Inicializa el servicio de autenticación
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Escuchar cambios en el estado de autenticación
      _supabase.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final User? user = data.session?.user;

        if (event == AuthChangeEvent.signedIn && user != null) {
          await _handleSignIn(context, user);
        } else if (event == AuthChangeEvent.signedOut) {
          await _handleSignOut(context);
        }
      });

      // Verificar si hay una sesión activa
      final session = _supabase.auth.currentSession;
      if (session?.user != null) {
        await _handleSignIn(context, session!.user);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando AuthService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Maneja el evento de inicio de sesión
  Future<void> _handleSignIn(BuildContext context, User user) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Buscar usuario en la base de datos
      final userData = await _supabase
          .from('usuarios')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (userData != null) {
        // Usuario existe, cargar sus datos
        final usuario = Usuario.fromJson(userData);
        await userProvider.updateUser(usuario);
      } else {
        // Usuario no existe, necesita completar el setup
        final nuevoUsuario = Usuario(
          id: user.id,
          nombre: user.userMetadata?['full_name']?.split(' ').first ?? '',
          apellido:
              user.userMetadata?['full_name']?.split(' ').skip(1).join(' ') ??
                  '',
          email: user.email ?? '',
          fotoUrl: user.userMetadata?['avatar_url'],
          fechaRegistro: DateTime.now(),
        );

        await userProvider.updateUser(nuevoUsuario);
      }
    } catch (e) {
      debugPrint('Error manejando sign in: $e');
    }
  }

  /// Maneja el evento de cierre de sesión
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();
    } catch (e) {
      debugPrint('Error manejando sign out: $e');
    }
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error cerrando sesión: $e');
      rethrow;
    }
  }

  /// Determina la ruta inicial basada en el estado de autenticación
  String getInitialRoute() {
    if (!_isInitialized) {
      return '/intro';
    }

    if (_isLoading) {
      return '/intro';
    }

    if (isLoggedIn) {
      return '/';
    }

    return '/intro';
  }

  /// Navega a la ruta apropiada después de la autenticación
  void navigateAfterAuth(BuildContext context, {bool isNewUser = false}) {
    if (isNewUser) {
      Navigator.pushReplacementNamed(context, '/finish_setting_up');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}
