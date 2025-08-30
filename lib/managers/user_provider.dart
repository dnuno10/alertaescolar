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

  /// Carga el usuario actual desde Supabase.
  /// `showDialog` permite evitar doble loader si el caller ya muestra uno.
  Future<void> loadCurrentUser(BuildContext context,
      {bool showDialog = true}) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    bool dialogShown = false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Muestra diálogo solo si estamos en una ruta interactiva y el caller lo permite
      if (showDialog && (ModalRoute.of(context)?.isCurrent ?? false)) {
        LoadingDialog.show(context, message: l10n.loadingUserData);
        dialogShown = true;
      }

      // Verifica sesión activa
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No active user session found');
        _currentUser = null;
        return;
      }

      // Obtén datos de la tabla usuarios
      final dynamic userData = await _supabase
          .from('usuarios')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (userData != null) {
        debugPrint('User found in database: ${user.id}');
        _currentUser = Usuario.fromJson(userData as Map<String, dynamic>);
      } else {
        debugPrint('User authenticated but not in database: ${user.id}');
        // Podrías construir un Usuario básico aquí si lo requieres
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _error = e.toString();
    } finally {
      // Cierra el diálogo si lo abrimos y el contexto sigue vivo
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

  /// Actualiza el usuario en memoria y opcionalmente en la base de datos.
  /// - `saveToDatabase`: hace upsert en Supabase (idempotente).
  /// - `setLoading`: si `true`, actualizará flags de loading para evitar flickers cuando no se desea.
  Future<void> updateUser(
    Usuario user, {
    bool saveToDatabase = false,
    bool setLoading = false,
  }) async {
    if (setLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final emailNorm = user.email.trim().toLowerCase();
      final fechaUtc = user.fechaRegistro.toUtc();

      if (saveToDatabase) {
        await _supabase.from('usuarios').upsert(
          {
            'id': user.id,
            'email': emailNorm,
            'nombre': user.nombre,
            'apellido': user.apellido,
            'tipo': user.tipo.name,
            'id_escuela': user.escuelaId,
            'tipo_administrador': user.tipoAdministrador?.name,
            'fecha_registro': fechaUtc.toIso8601String(),
          },
          onConflict:
              'id', // ajusta si tu índice único es distinto (ej. 'email' o 'id,email')
        );
        debugPrint('User data saved to database: ${user.id}');
      }

      _currentUser = user.copyWith(
        email: emailNorm,
        fechaRegistro: fechaUtc,
      );
      debugPrint('User updated in provider: ${user.id}');
    } catch (e) {
      debugPrint('Error updating user: $e');
      _error = e.toString();
      rethrow; // Permite que el llamador maneje el error si lo desea
    } finally {
      if (setLoading) {
        _isLoading = false;
      }
      // Notificamos siempre cambios de usuario o de estado
      notifyListeners();
    }
  }

  /// Actualiza información personal (nombre, apellido) y refleja en BD + estado.
  Future<void> updatePersonalInfo(
    String nombre,
    String apellido,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (!context.mounted) return;
    LoadingDialog.show(context, message: l10n.updatingPersonalInfo);

    if (_currentUser == null) {
      if (context.mounted) {
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: 'No hay usuario activo',
          isError: true,
        );
      }
      throw Exception('No hay usuario activo');
    }

    _error = null;
    notifyListeners();

    try {
      final nombreTrim = nombre.trim();
      final apellidoTrim = apellido.trim();

      // Verificar si hay cambios
      if (_currentUser!.nombre == nombreTrim &&
          _currentUser!.apellido == apellidoTrim) {
        debugPrint('No hay cambios en el nombre o apellido');
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            message: l10n.noChangesDetected,
          );
        }
        return;
      }

      // Actualizar en la base de datos
      await _supabase.from('usuarios').update({
        'nombre': nombreTrim,
        'apellido': apellidoTrim,
      }).eq('id', _currentUser!.id);

      debugPrint(
          'Información personal actualizada en la base de datos: ${_currentUser!.id}');

      // Actualizar en memoria
      _currentUser = _currentUser!.copyWith(
        nombre: nombreTrim,
        apellido: apellidoTrim,
      );
      debugPrint(
          'Información personal actualizada en el provider: ${_currentUser!.id}');

      // Mostrar mensaje de éxito
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: l10n.personalInformationUpdatedSuccessfully,
        );
      }
    } catch (e) {
      debugPrint('Error actualizando información personal: $e');
      _error = e.toString();

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: '${l10n.errorUpdatingInformation}: $e',
          isError: true,
        );
      }
      rethrow;
    } finally {
      if (context.mounted) {
        LoadingDialog.hide(context);
      }
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
