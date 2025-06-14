import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../managers/user_provider.dart';
import '../models/models.dart';
import '../managers/auth/AdminSetup.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _initialRoute;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _supabase.auth.currentUser != null;
  String get initialRoute => _initialRoute ?? '/intro';

  /// Inicializa el servicio de autenticación
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Get the UserProvider instance
      final userProvider = Provider.of<UserProvider>(context, listen: false);

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
        try {
          // Buscar el usuario en la base de datos
          final userData = await _supabase
              .from('usuarios')
              .select('*')
              .eq('id', session!.user.id)
              .maybeSingle();

          if (userData != null) {
            // Usuario existe, cargar en el provider
            final usuario = Usuario.fromJson(userData);
            await userProvider.updateUser(usuario);

            // Determinar la ruta inicial según el tipo de usuario
            if (usuario.tipo == TipoUsuario.administrador) {
              _initialRoute = '/admin';
            } else {
              _initialRoute = '/';
            }
          } else {
            // Verificar si es un administrador en la lista de acceso
            if (context.mounted) {
              final isAdmin = await AdminSetup.checkAndSetupAdmin(
                  context, session.user.email ?? '', session.user.id);

              if (isAdmin) {
                _initialRoute = '/admin';
              } else {
                _initialRoute = '/finish_setting_up';
              }
            }
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
          _initialRoute = '/intro';
        }
      } else {
        _initialRoute = '/intro';
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando AuthService: $e');
      _initialRoute = '/intro';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Maneja el evento de inicio de sesión
  Future<void> _handleSignIn(BuildContext context, User user) async {
    try {
      // Check if provider is available
      if (!context.mounted) return;
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
        // Check if user is in admin list
        if (context.mounted) {
          final isAdmin = await AdminSetup.checkAndSetupAdmin(
              context, user.email ?? '', user.id);

          if (isAdmin) {
            return; // Admin setup handled the user creation
          }
        }

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
      if (!context.mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();
      _initialRoute = '/intro';
      notifyListeners();
    } catch (e) {
      debugPrint('Error manejando sign out: $e');
    }
  }

  /// Cierra la sesión del usuario
  Future<void> signOut(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();
      await _supabase.auth.signOut();
      _initialRoute = '/intro';
      notifyListeners();
    } catch (e) {
      debugPrint('Error cerrando sesión: $e');
      rethrow;
    }
  }

  /// Determina la ruta inicial basada en el estado de autenticación
  Future<String> getInitialRoute() async {
    if (!_isInitialized || _isLoading) {
      return '/intro';
    }

    if (isLoggedIn) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Verificar si el perfil está completo
        final userExist = await Supabase.instance.client
            .from('usuarios')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();

        if (userExist == null) {
          return '/finish_setting_up';
        } else if (userExist['nombre'] == null ||
            userExist['nombre'].toString().isEmpty ||
            userExist['apellido'] == null ||
            userExist['apellido'].toString().isEmpty) {
          return '/finish_setting_up';
        } else {
          // Check if user is admin
          final tipo = userExist['tipo']?.toString() ?? '';
          if (tipo == TipoUsuario.administrador.name) {
            return '/admin';
          }
          return '/';
        }
      }
    }

    return '/intro';
  }

  /// Navega a la ruta apropiada después de la autenticación
  Future<void> navigateAfterAuth(BuildContext context,
      {bool isNewUser = false}) async {
    if (!context.mounted) return;

    if (isNewUser) {
      Navigator.pushReplacementNamed(context, '/finish_setting_up');
    } else {
      final route = await getInitialRoute();
      Navigator.pushReplacementNamed(context, route);
    }
  }

  /// Check for existing session and auto-login
  Future<bool> checkAndAutoLogin() async {
    if (isLoggedIn) {
      final route = await getInitialRoute();
      _initialRoute = route;
      notifyListeners();
      return true;
    }
    return false;
  }
}
