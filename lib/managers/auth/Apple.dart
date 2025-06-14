// ignore_for_file: file_names
import 'dart:convert';
import 'dart:math';

import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';

class Apple {
  static final Apple _instance = Apple._Internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  Apple._Internal();

  factory Apple() => _instance;

  Future<void> signInWithApple(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    LoadingDialog.show(context, message: l10n.signingInWithApple);

    try {
      final rawNonce = _supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException(
          'Could not find ID Token from generated credential.',
        );
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.session == null) {
        throw Exception('No session returned from Supabase.');
      }

      // ignore: use_build_context_synchronously
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userExist = await _supabase
          .from('usuarios')
          .select('*')
          .eq('email', response.user!.email.toString())
          .maybeSingle();

      if (userExist == null) {
        // Usuario no existe, redirigir a configuración
        final nuevoUsuario = Usuario(
          id: response.user!.id,
          nombre: credential.givenName ?? '',
          apellido: credential.familyName ?? '',
          email: response.user!.email ?? '',
          fechaRegistro: DateTime.now(),
        );

        await userProvider.updateUser(nuevoUsuario);

        LoadingDialog.hide(context);

        _showSuccessAndNavigate(
          context,
          'Verificación exitosa',
          '/finish_setting_up',
        );
      } else {
        // Usuario existe, verificar si el perfil está completo
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        LoadingDialog.hide(context);

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
    } catch (e) {
      // ignore: use_build_context_synchronously
      LoadingDialog.hide(context); // ignore: avoid_print
      debugPrint('Error during Apple Sign-In: $e');
      // ignore: use_build_context_synchronously
      _showError(context, 'Error al iniciar sesión con Apple');
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

  void _showError(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomSnackBar.show(
        context: context,
        message: message,
        isError: true,
      );
    });
  }
}
