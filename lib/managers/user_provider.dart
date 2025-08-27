
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
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

// In the loadCurrentUser method:
  Future<void> loadCurrentUser(BuildContext context) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    bool dialogShown = false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Only show dialog if we're in an interactive context
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        LoadingDialog.show(context, message: l10n.loadingUserData);
        dialogShown = true;
      }

      // Check if there's an active user session
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No active user session found');
        _currentUser = null;
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
        // // Create basic user object from auth data
        // _currentUser = Usuario(
        //   id: user.id,
        //   nombre: user.userMetadata?['full_name']?.split(' ').first ?? '',
        //   apellido:
        //       user.userMetadata?['full_name']?.split(' ').skip(1).join(' ') ??
        //           '',
        //   email: user.email ?? '',
        //   fotoUrl: user.userMetadata?['avatar_url'],
        //   fechaRegistro: DateTime.now(),
        // );
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _error = e.toString();
    } finally {
      // Always hide the dialog if it was shown and context is still valid
      if (dialogShown && context.mounted) {
        try {
          LoadingDialog.hide(context);
        } catch (e) {
          debugPrint('Error hiding loading dialog: $e');
        }
      }

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

  // ...existing code...

  Future<void> updatePersonalInfo(
      String nombre, String apellido, BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    LoadingDialog.show(context, message: l10n.updatingPersonalInfo);

    if (_currentUser == null) {
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        context: context,
        message: 'No hay usuario activo',
        isError: true,
      );
      throw Exception('No hay usuario activo');
    }

    _error = null;
    notifyListeners();

    try {
      // Verificar si hay cambios
      if (_currentUser!.nombre == nombre &&
          _currentUser!.apellido == apellido) {
        debugPrint('No hay cambios en el nombre o apellido');
        CustomSnackBar.show(
          context: context,
          message: l10n.noChangesDetected,
        );
        return;
      }

      // Crear usuario actualizado
      final updatedUser = _currentUser!.copyWith(
        nombre: nombre,
        apellido: apellido,
      );

      // Actualizar en la base de datos
      await _supabase.from('usuarios').update({
        'nombre': nombre,
        'apellido': apellido,
      }).eq('id', _currentUser!.id);

      debugPrint(
          'Información personal actualizada en la base de datos: ${_currentUser!.id}');

      // Actualizar en memoria
      _currentUser = updatedUser;
      debugPrint(
          'Información personal actualizada en el provider: ${_currentUser!.id}');

      // Mostrar mensaje de éxito
      CustomSnackBar.show(
        context: context,
        message: l10n.personalInformationUpdatedSuccessfully,
      );
    } catch (e) {
      LoadingDialog.hide(context);

      debugPrint('Error actualizando información personal: $e');
      _error = e.toString();

      // Mostrar mensaje de error
      CustomSnackBar.show(
        context: context,
        message: '${l10n.errorUpdatingInformation}: $e',
        isError: true,
      );

      rethrow;
    } finally {
      LoadingDialog.hide(context);
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
