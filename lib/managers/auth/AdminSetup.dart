// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSetup {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Checks if the email exists in the admin_access_list table and sets up the user
  /// Returns true if the user is an admin and was set up automatically
  static Future<bool> checkAndSetupAdmin(
      BuildContext context, String email, String userId) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Check if the email exists in the admin_access_list table
      final adminData = await _supabase
          .from('admin_access_list')
          .select()
          .eq('email', email)
          .maybeSingle();

      // If the email is not in the admin list or not active, return false to continue with normal flow
      if (adminData == null) {
        return false;
      }

      // If the email is in the admin list, set up the user with admin privileges
      final adminRecord = adminData;

      // Convert string to TipoAdministrador enum
      TipoAdministrador? tipoAdmin;
      if (adminRecord['tipo_administrador'] != null) {
        try {
          final tipoString = adminRecord['tipo_administrador'] as String;
          tipoAdmin = TipoAdministrador.values.firstWhere(
            (e) => e.name == tipoString,
            orElse: () => TipoAdministrador.administrativo,
          );
        } catch (e) {
          debugPrint('Error converting tipo_administrador: $e');
          tipoAdmin = TipoAdministrador.administrativo; // Default value
        }
      }

      // Create user object with admin data
      final adminUser = Usuario(
        id: userId,
        nombre: adminRecord['nombre'] ?? '',
        apellido: adminRecord['apellido'] ?? '',
        email: email,
        tipo: TipoUsuario.administrador,
        escuelaId: adminRecord['id_escuela'],
        tipoAdministrador: tipoAdmin,
        fechaRegistro: DateTime.now(),
      );

      // Insert user in the database
      await _supabase.from('usuarios').insert({
        'id': userId,
        'email': email,
        'nombre': adminUser.nombre,
        'apellido': adminUser.apellido,
        'tipo': TipoUsuario.administrador.name,
        'id_escuela': adminUser.escuelaId,
        'tipo_administrador': tipoAdmin?.name,
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      // Update the provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUser(adminUser);

      debugPrint(
          'Admin user setup complete: ${adminUser.email}, routing to /admin');

      // Show success message and navigate to admin page
      _showSuccessAndNavigate(
        context,
        l10n.accountSetupSuccessfully,
        '/admin',
      );

      return true;
    } catch (e) {
      debugPrint('Error checking admin access: $e');
      return false;
    }
  }

  static void _showSuccessAndNavigate(
      BuildContext context, String message, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomSnackBar.show(
        context: context,
        message: message,
        isError: false,
      );
      Navigator.pushReplacementNamed(context, route);
    });
  }
}
