// lib/managers/user_provider.dart
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
  // Alias para compatibilidad con vistas que esperan isLoadingUser
  bool get isLoadingUser => _isLoading;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Nuevo: verificación real de email vía Supabase Auth.
  bool get isEmailVerified =>
      _supabase.auth.currentUser?.emailConfirmedAt != null;

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

  // ► Helpers para mostrar datos en UI sin lógica repetida
  String get displayName {
    final u = _currentUser;
    if (u == null) return '';
    // nombreCompleto si tu modelo lo expone, sino "Nombre Apellido"
    final byModel = (u.nombreCompleto).trim();
    if (byModel.isNotEmpty) return byModel;
    final full = '${u.nombre} ${u.apellido}'.trim();
    if (full.isNotEmpty) return full;
    // fallback: parte local del email
    final email = (u.email).trim();
    return email.contains('@') ? email.split('@').first : email;
  }

  String get initials {
    final u = _currentUser;
    if (u == null) return '';
    final base = displayName.isNotEmpty ? displayName : (u.email);
    final parts = base.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final a = parts[0].isNotEmpty ? parts[0][0] : '';
      final b = parts[1].isNotEmpty ? parts[1][0] : '';
      return (a + b).toUpperCase();
    }
    return base.isNotEmpty ? base[0].toUpperCase() : '';
  }

  bool get hasUser => _currentUser != null;

  // ► Reload silencioso para pull-to-refresh / initState
  Future<void> reloadSilently(BuildContext context) =>
      loadCurrentUser(context, showDialog: false);

  /// Carga el usuario actual desde Supabase.
  Future<void> loadCurrentUser(BuildContext context,
      {bool showDialog = true}) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.maybeOf(context); // ← seguro
    bool dialogShown = false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Solo mostrar diálogo si ya hay Localizations en el árbol
      if (showDialog &&
          l10n != null &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
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
      if (u.esAdministrador &&
          (u.escuelaId == null || u.escuelaId!.isNotEmpty == false)) {
        final emailNorm = u.email.trim().toLowerCase();
        final adminRow = await _supabase
            .from('admin_access_list')
            .select('id_escuela, activo, created_at')
            .eq('email', emailNorm)
            .eq('activo', true)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        final escuelaUuid = (adminRow?['id_escuela']?.toString() ?? '').trim();
        if (escuelaUuid.isNotEmpty) {
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

  /// Devuelve escuelaId si está en memoria o intenta resolverlo; lanza si no puede.
// managers/user_provider.dart (dentro de la clase UserProvider)
  Future<String> ensureEscuelaIdOrThrow({bool forceRefresh = false}) async {
    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;

    if (authUser == null) {
      throw Exception('Sesión inválida. Inicia sesión de nuevo.');
    }

    // Si ya está en memoria y no forzamos, úsalo.
    if (!forceRefresh && (currentUser?.escuelaId?.isNotEmpty ?? false)) {
      return currentUser!.escuelaId!;
    }

    // 1) Camino admins: admin_access_list por email (primer login típico).
    final email = (authUser.email ?? '').trim().toLowerCase();
    if (email.isNotEmpty) {
      try {
        final adminRow = await supabase
            .from('admin_access_list')
            .select('id_escuela, activo')
            .eq('email', email)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        final idEscuela = adminRow?['id_escuela']?.toString();
        final activo = (adminRow?['activo'] as bool?) ?? true;

        if (idEscuela != null && idEscuela.isNotEmpty && activo) {
          if (_currentUser != null) {
            _currentUser = _currentUser!.copyWith(escuelaId: idEscuela);
            notifyListeners();
          }
          return idEscuela;
        }
      } catch (e) {
        debugPrint(
            'ensureEscuelaIdOrThrow: lookup admin_access_list falló: $e');
      }
    }

    // 2) Fallback: derivar escuela desde relaciones tutor/alumno (si aplica).
    try {
      final rel = await supabase
          .from('alumno_tutores')
          .select('alumnos ( id_escuela )')
          .eq('id_tutor', authUser.id)
          .limit(1)
          .maybeSingle();

      final idEscuela = rel?['alumnos']?['id_escuela']?.toString();
      if (idEscuela != null && idEscuela.isNotEmpty) {
        if (currentUser != null) {
          _currentUser = currentUser!.copyWith(escuelaId: idEscuela);
          notifyListeners();
        }
        return idEscuela;
      }
    } catch (e) {
      debugPrint('ensureEscuelaIdOrThrow: lookup alumno_tutores falló: $e');
    }

    throw Exception('No hay una escuela asociada a esta cuenta.');
  }

  /// Versión sincrónica que lanza si no hay escuela cargada.
  String requireEscuelaId() {
    final id = _currentUser?.escuelaId;
    if (id == null || id.isEmpty) {
      throw StateError('Escuela no definida en memoria.');
    }
    return id;
  }
}
