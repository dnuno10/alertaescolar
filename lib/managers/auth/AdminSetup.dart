// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSetup {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Verifica si el `email` está en `admin_access_list`. Si sí, crea/hidrata
  /// el usuario admin (persistiendo vía UserProvider) y navega al dashboard.
  /// Retorna `true` si se configuró como admin; `false` si no está autorizado
  /// o si ocurrió un error.
  static Future<bool> checkAndSetupAdmin(
    BuildContext context,
    String email,
    String userId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final emailNorm = email.trim().toLowerCase();

    try {
      final dynamic adminData = await _supabase
          .from('admin_access_list')
          .select()
          .eq('email', emailNorm)
          .maybeSingle();

      if (adminData == null) {
        // No autorizado como admin
        return false;
      }

      // Cast seguro
      final record = adminData as Map<String, dynamic>;

      // Parse de tipo de administrador con fallback
      TipoAdministrador tipoAdmin = TipoAdministrador.administrativo;
      final dynamic rawTipo = record['tipo_administrador'];
      if (rawTipo is String && rawTipo.isNotEmpty) {
        try {
          tipoAdmin = TipoAdministrador.values.firstWhere(
            (e) => e.name == rawTipo,
            orElse: () => TipoAdministrador.administrativo,
          );
        } catch (_) {
          tipoAdmin = TipoAdministrador.administrativo;
        }
      }

      final nowUtc = DateTime.now().toUtc();

      final escuelaId = record['id_escuela']?.toString();
      final adminUser = Usuario(
        id: userId,
        nombre: (record['nombre'] as String?) ?? '',
        apellido: (record['apellido'] as String?) ?? '',
        email: emailNorm,
        tipo: TipoUsuario.administrador,
        escuelaId: escuelaId,
        tipoAdministrador: tipoAdmin,
        fechaRegistro: nowUtc,
      );

      // Persistir + actualizar estado local desde el provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUser(adminUser, saveToDatabase: true);

      if (!context.mounted) return true;

      // Feedback + navegación segura al dashboard admin
      CustomSnackBar.show(
        context: context,
        message: l10n.accountSetupSuccessfully,
        isError: false,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      });

      return true;
    } on PostgrestException catch (e) {
      // Errores específicos de Postgrest
      debugPrint('PostgrestException in AdminSetup: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error checking admin access: $e');
      return false;
    }
  }
}
