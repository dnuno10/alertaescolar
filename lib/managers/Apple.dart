// ignore_for_file: file_names
import 'dart:convert';

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
    _showLoadingDialog(context);

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

      // ignore: use_build_context_synchronously
      _closeLoadingDialog(context);

      if (userExist == null) {
        // Create new user with Apple data
        final nuevoUsuario = Usuario(
          id: response.user!.id,
          nombre: credential.givenName ?? '',
          apellido: credential.familyName ?? '',
          email: response.user!.email ?? '',
          fechaRegistro: DateTime.now(),
        );

        await userProvider.updateUser(nuevoUsuario);

        _showSuccessAndNavigate(
          // ignore: use_build_context_synchronously
          context,
          'Verificación exitosa',
          '/finish_setting_up',
        );
      } else {
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        _showSuccessAndNavigate(
          // ignore: use_build_context_synchronously
          context,
          'Inicio de sesión exitoso',
          '/admin_dashboard',
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _closeLoadingDialog(context);
      // ignore: avoid_print
      debugPrint('Error during Apple Sign-In: $e');
      // ignore: use_build_context_synchronously
      _showError(context, 'Error al iniciar sesión con Apple');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _closeLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
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
