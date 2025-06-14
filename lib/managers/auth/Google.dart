// ignore_for_file: file_names
import 'dart:math';

import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Google {
  static final Google _instance = Google._Internal();

  // Cliente de Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // Constructor privado para Singleton
  Google._Internal();

  factory Google() => _instance;

  // Método principal para iniciar sesión
  Future<void> signInWithGoogle(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    const webClientId =
        '84476159662-prk0gfmqhd1j1dtechkas0s4gffm5iu6.apps.googleusercontent.com';
    const iosClientId =
        '84476159662-5srkbbd1l6aibi2ng9plj67ec6qhr8pf.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    LoadingDialog.show(context, message: l10n.signingInWithGoogle);

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Sign-in aborted by user.';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No access token found.';
      }
      if (idToken == null) {
        throw 'No ID token found.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session == null) {
        throw Exception('No session returned');
      }

      // Obtener el provider de usuario
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Verificar si el usuario existe en la base de datos
      final userExist = await _supabase
          .from('usuarios')
          .select('*')
          .eq('email', response.user!.email ?? '')
          .maybeSingle();

      if (userExist == null) {
        // Usuario no existe, redirigir a configuración
        _showSuccessAndNavigate(
          context,
          'Verificación exitosa',
          '/finish_setting_up',
        );
      } else {
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        if (usuario.nombre.isEmpty || usuario.apellido.isEmpty) {
          _showSuccessAndNavigate(
            context,
            'Complete su perfil',
            '/finish_setting_up',
          );
        } else {
          _showSuccessAndNavigate(
            context,
            'Inicio de sesión exitoso',
            usuario.esAdministrador ? '/admin_dashboard' : '/',
          );
        }
      }
    } catch (e) {
      // Cerrar pantalla de carga en caso de error
      LoadingDialog.hide(context);

      debugPrint('Error en Google Sign In: $e');

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Error al iniciar sesión con Google',
          isError: true,
        );
      }
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
