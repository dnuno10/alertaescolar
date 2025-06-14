// ignore_for_file: file_names

import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';

class Logout {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Limpia los datos del usuario
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();

      await _supabaseClient.auth.signOut();
      // Navega a la pantalla de inicio de sesión después de cerrar sesión
      CustomSnackBar.show(
        context: context,
        message: l10n.logoutSuccessful,
        isError: false,
      );
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
    } catch (error) {
      debugPrint("Error signing out: $error");
      // Opcional: Muestra un mensaje de error
      CustomSnackBar.show(
        context: context,
        message: l10n.logoutError,
        isError: true,
      );
    }
  }
}
