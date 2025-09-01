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
  Future<String?> _resolveEscuelaIdForUser({
    required String userId,
    required String emailNorm,
    required String tipoUsuario, // 'administrador' | 'padre' | etc
  }) async {
    // Si es admin: admin_access_list → id_escuela (por email)
    if (tipoUsuario.toLowerCase() == 'administrador' ||
        tipoUsuario.toLowerCase() == 'admin') {
      final adminRow = await _supabase
          .from('admin_access_list')
          .select('id_escuela')
          .eq('email', emailNorm)
          .eq('activo', true) // si tu esquema lo usa
          .order('created_at', ascending: false)
          .maybeSingle();

      final escuelaUuid = adminRow?['id_escuela']?.toString();
      if (escuelaUuid != null && escuelaUuid.isNotEmpty) {
        return escuelaUuid;
      }
    }

    // Si no es admin (o no hubo match): deducir por vínculo tutor→alumno
    try {
      final resp = await _supabase.from('alumno_tutores').select('''
        alumnos!inner(
          id_escuela
        )
      ''').eq('id_tutor', userId).limit(1);

      if (resp.isNotEmpty) {
        final alumno = resp[0]['alumnos'] as Map<String, dynamic>?;
        final escuelaUuid = alumno?['id_escuela']?.toString();
        if (escuelaUuid != null && escuelaUuid.isNotEmpty) {
          return escuelaUuid;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Carga el usuario actual desde Supabase.
  Future<void> loadCurrentUser(BuildContext context,
      {bool showDialog = true}) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    bool dialogShown = false;

    String? _nn(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (showDialog && (ModalRoute.of(context)?.isCurrent ?? false)) {
        LoadingDialog.show(context, message: l10n.loadingUserData);
        dialogShown = true;
      }

      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        debugPrint('No active user session found');
        _currentUser = null;
        return;
      }

      final row = await _supabase
          .from('usuarios')
          .select('*')
          .eq('id', authUser.id)
          .maybeSingle();

      if (row == null) {
        debugPrint('User authenticated but not in database: ${authUser.id}');
        _currentUser = null;
        return;
      }

      // 1) Usuario base
      var u = Usuario.fromJson(Map<String, dynamic>.from(row));

      // 2) Si es admin y no tiene escuelaId en memoria, resolverla por email en admin_access_list
      if (u.esAdministrador && (_nn(u.escuelaId) == null)) {
        final emailNorm = u.email.trim().toLowerCase();
        final adminRow = await _supabase
            .from('admin_access_list')
            .select('id_escuela, activo')
            .eq('email', emailNorm) // usa eq (email normalizado)
            .eq('activo', true) // opcional pero recomendable
            .maybeSingle();

        final escuelaUuid = _nn(adminRow?['id_escuela']?.toString());
        if (escuelaUuid != null) {
          u = u.copyWith(escuelaId: escuelaUuid);
        }
      }

      _currentUser = u;
      debugPrint('User loaded: ${u.id} (${u.email}) escuelaId=${u.escuelaId}');
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _error = e.toString();
    } finally {
      if (dialogShown && context.mounted) {
        try {
          LoadingDialog.hide(context);
        } catch (_) {}
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> ensureEscuelaIdLoaded() async {
    final u = _currentUser;
    if (u == null) return null;
    if (u.escuelaId != null && u.escuelaId!.isNotEmpty) return u.escuelaId;
    final escuelaId = await _resolveEscuelaIdForUser(
      userId: u.id,
      emailNorm: u.email.trim().toLowerCase(),
      tipoUsuario: u.tipo.name,
    );
    if (escuelaId != null && escuelaId.isNotEmpty) {
      _currentUser = u.copyWith(escuelaId: escuelaId);
      notifyListeners();
      return escuelaId;
    }
    return null;
  }

  /// Helper: devuelve el usuario actual o lanza si no existe.
  /// Útil para centralizar validación en los callers.
  Usuario requireCurrentUser() {
    final u = _currentUser;
    if (u == null) {
      throw StateError('No hay usuario activo');
    }
    return u;
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
            'tipo_administrador': user.tipoAdministrador?.name,
            'fecha_registro': fechaUtc.toIso8601String(),
          },
          onConflict: 'id',
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
      rethrow;
    } finally {
      if (setLoading) {
        _isLoading = false;
      }
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

      await _supabase.from('usuarios').update({
        'nombre': nombreTrim,
        'apellido': apellidoTrim,
      }).eq('id', _currentUser!.id);

      debugPrint(
          'Información personal actualizada en la base de datos: ${_currentUser!.id}');

      _currentUser = _currentUser!.copyWith(
        nombre: nombreTrim,
        apellido: apellidoTrim,
      );
      debugPrint(
          'Información personal actualizada en el provider: ${_currentUser!.id}');

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
