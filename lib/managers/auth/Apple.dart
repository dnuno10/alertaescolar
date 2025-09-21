// ignore_for_file: file_names
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/auth/AdminSetup.dart';
import 'package:alertaescolar/managers/auth/auth_utils.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/models/models.dart';

class Apple {
  static final Apple _instance = Apple._Internal();
  // ignore: non_constant_identifier_names
  Apple._Internal();
  factory Apple() => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signInWithApple(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final available = !kIsWeb && await SignInWithApple.isAvailable();
    if (!available) {
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: l10n.appleNotAvailable,
          isError: true,
        );
      }
      return;
    }

    // ignore: use_build_context_synchronously
    LoadingDialog.show(context, message: l10n.signingInWithApple);

    try {
      final rawNonce = _supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Missing Apple ID token');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      if (response.session == null || response.user == null) {
        throw Exception('No Supabase session');
      }
      if (!context.mounted) return;

      //COMPARAR A PARTIR DE AQUÍ ---------

      final authUser = response.user!;
      final resolvedEmail =
          (authUser.email ?? credential.email ?? '').trim().toLowerCase();

      //1. Asegura/inserta fila mínima en 'usuarios'
      // En caso de que no exista en la tabla se inserta un registro del usuario en la tabla usuarios
      final usuario = await ensureUserRow(
        supabase: _supabase,
        authUser: authUser,
        defaultTipo: TipoUsuario.padre,
      );

      // 2) Elevar a admin si aplica (lista blanca)
      if (resolvedEmail.isNotEmpty) {
        final isAdmin = await AdminSetup.checkAndSetupAdmin(
          // ignore: use_build_context_synchronously
          context,
          resolvedEmail,
          authUser.id,
        );
        if (isAdmin) {
          // ignore: use_build_context_synchronously
          LoadingDialog.hide(context);
          CustomSnackBar.show(
            // ignore: use_build_context_synchronously
            context: context,
            message: l10n.loginSuccessful,
            isError: false,
          );
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
          return;
        }
      }

      // 3) Actualiza provider y navega
      // ignore: use_build_context_synchronously
      await Provider.of<UserProvider>(context, listen: false)
          .updateUser(usuario);

      final incomplete = usuario.nombre.isEmpty || usuario.apellido.isEmpty;

      //?!? - el admin llega hasta aquí? ya que no se ha redirigido antes?
      final nextRoute = incomplete
          ? AppRoutes.finishSettingUp
          : (usuario.tipo == TipoUsuario.administrador
              ? AppRoutes.adminDashboard
              : AppRoutes.home);

      // ignore: use_build_context_synchronously
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        // ignore: use_build_context_synchronously
        context: context,
        message: incomplete ? l10n.completeYourProfile : l10n.loginSuccessful,
        isError: false,
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed(nextRoute);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (context.mounted) {
        if (e.code == AuthorizationErrorCode.canceled) {
          CustomSnackBar.show(
            context: context,
            message: l10n.signInCanceled,
            isError: false,
          );
        } else {
          CustomSnackBar.show(
            context: context,
            message: l10n.appleSignInError,
            isError: true,
          );
        }
        LoadingDialog.hide(context);
      }
    } catch (e) {
      debugPrint('Apple Sign-In error: $e');
      if (context.mounted) {
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: l10n.appleSignInError,
          isError: true,
        );
      }
    }
  }
}
