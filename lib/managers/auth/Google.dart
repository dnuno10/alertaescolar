// ignore_for_file: file_names
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
    const webClientId =
        '84476159662-prk0gfmqhd1j1dtechkas0s4gffm5iu6.apps.googleusercontent.com';
    // const iosClientId =
    //     '733878207598-de09lsosiju0962cs78ausrto1hkg6bq.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      // clientId: iosClientId,
      serverClientId: webClientId,
    );

    // Mostrar pantalla de carga
    showDialog(
      context: context,
      barrierDismissible: false, // Impide que se cierre al tocar fuera
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(), // Indicador de carga
        );
      },
    );

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

      // Cerrar pantalla de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (userExist == null) {
        // Usuario no existe, crear nuevo usuario y redirigir a configuración
        final nuevoUsuario = Usuario(
          id: response.user!.id,
          nombre: googleUser.displayName?.split(' ').first ?? '',
          apellido: googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
          email: response.user!.email ?? '',
          fotoUrl: googleUser.photoUrl,
          fechaRegistro: DateTime.now(),
        );

        await userProvider.updateUser(nuevoUsuario);

        if (context.mounted) {
          _showSuccessAndNavigate(
            context,
            'Inicio de sesión exitoso',
            '/finish_setting_up',
          );
        }
      } else {
        // Usuario existe, actualizar datos locales
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        if (context.mounted) {
          _showSuccessAndNavigate(
            context,
            'Inicio de sesión exitoso',
            '/',
          );
        }
      }
    } catch (e) {
      // Cerrar pantalla de carga en caso de error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
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
