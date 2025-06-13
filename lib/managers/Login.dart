// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogIn {
  final BuildContext context;

  LogIn(this.context);

  Future<void> checkLoginStatus() async {
    try {
      debugPrint("🔍 Checking current session...");
      final session = Supabase.instance.client.auth.currentSession;

      if (session == null) {
        debugPrint("❌ No active session found. Returning to login.");
        Navigator.of(context).pop();
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Guardamos los datos localmente
      debugPrint("✅ Updating local user data...");

      debugPrint("🔍 Checking user existence in Supabase...");
      final userExist = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('email', session.user.email.toString())
          .maybeSingle();

      Navigator.of(context).pop();

      if (userExist == null) {
        _showSuccessAndNavigate(
          context,
          'Verificación exitosa',
          '/finish_setting_up',
        );
        Navigator.pushReplacementNamed(context, '/finish_setting_up');
      } else {
        // Create Usuario object from database data
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        _showSuccessAndNavigate(
          context,
          'Inicio de sesión exitoso',
          '/admin_dashboard',
        );
      }
    } on PostgrestException catch (error) {
      debugPrint("PostgrestException in checkLoginStatus: ${error.message}");
    } catch (error) {
      debugPrint("Unexpected error in checkLoginStatus: $error");
    }
  }

  void _showSuccessAndNavigate(
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
