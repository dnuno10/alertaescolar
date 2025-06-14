// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/managers/auth/MagicLink.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogIn {
  final BuildContext context;

  LogIn(this.context);

  Future<void> checkAndLogin(String email) async {
    final l10n = AppLocalizations.of(context);

    LoadingDialog.show(context, message: l10n.loggingIn);

    try {
      // Check if the email is registered
      final isRegistered = await Supabase.instance.client
          .rpc('is_email_registered', params: {'input_email': email});

      if (isRegistered == true) {
        // Email is already registered, send magic link
        SendingMagicLink(context: context, email: email).sendMagicLink();
      } else {
        // Email is not registered, show error message
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: l10n.pleaseCreateAccount,
          isError: true,
        );
      }
    } catch (e) {
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        context: context,
        message: l10n.loginErrorMessage,
        isError: true,
      );
    }
  }

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
        // Usuario no existe, redirigir a configuración
        _showSuccessAndNavigate(
          context,
          'Verificación exitosa',
          '/finish_setting_up',
        );
      } else {
        // Usuario existe, verificar si el perfil está completo
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        if (usuario.nombre.isEmpty || usuario.apellido.isEmpty) {
          // Perfil incompleto, redirigir a configuración
          _showSuccessAndNavigate(
            context,
            'Complete su perfil',
            '/finish_setting_up',
          );
        } else {
          // Perfil completo, redirigir al dashboard o home
          _showSuccessAndNavigate(
            context,
            'Inicio de sesión exitoso',
            usuario.esAdministrador ? '/admin_dashboard' : '/',
          );
        }
      }
    } on PostgrestException catch (error) {
      debugPrint("PostgrestException in checkLoginStatus: ${error.message}");
      Navigator.of(context).pop();

      CustomSnackBar.show(
        context: context,
        message: 'Database error: ${error.message}',
        isError: true,
      );
    } catch (error) {
      debugPrint("Unexpected error in checkLoginStatus: $error");
      Navigator.of(context).pop();

      CustomSnackBar.show(
        context: context,
        message: 'Unexpected error occurred. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> checkAndRegister(String email) async {
    final l10n = AppLocalizations.of(context);

    LoadingDialog.show(context, message: l10n.registering);
    try {
      // Check if the email is already registered
      final isRegistered = await Supabase.instance.client
          .rpc('is_email_registered', params: {'input_email': email});

      if (isRegistered == true) {
        // Email is already registered, show error message
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: l10n
              .emailAlreadyExists, // You'll need to add this to localizations
          isError: true,
        );
      } else {
        // Email is not registered, send magic link for registration
        SendingMagicLink(context: context, email: email).sendMagicLink();
      }
    } catch (e) {
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        context: context,
        message: l10n.signUpErrorMessage,
        isError: true,
      );
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
