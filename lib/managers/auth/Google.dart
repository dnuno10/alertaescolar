// ignore_for_file: file_names

import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/auth/AdminSetup.dart';
import 'package:alertaescolar/managers/auth/auth_utils.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Google {
  static final Google _instance = Google._Internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  // ignore: non_constant_identifier_names
  Google._Internal();
  factory Google() => _instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    const webClientId =
        '328996489325-1qblqo4s2h2s6bnmajf4ia331a49fssa.apps.googleusercontent.com';

    const iosClientId =
        '328996489325-4p4vhv5psrpnashnuokin3eboej6ulnq.apps.googleusercontent.com';

    final googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    LoadingDialog.show(context, message: l10n.signingInWithGoogle);

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (context.mounted) {
          LoadingDialog.hide(context);
          CustomSnackBar.show(
            context: context,
            message: l10n.signInCanceled,
            isError: false,
          );
        }
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null || idToken == null) {
        throw Exception('Missing Google tokens');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      if (response.session == null || response.user == null) {
        throw Exception('No Supabase session');
      }

      if (!context.mounted) return;

      final authUser = response.user!;
      final resolvedEmail = (authUser.email ?? '').trim().toLowerCase();

      // 1) Asegura/inserta fila mínima en 'usuarios'
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
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          return;
        }
      }

      // 3) Actualiza provider y navega según perfil
      // ignore: use_build_context_synchronously
      await Provider.of<UserProvider>(context, listen: false)
          .updateUser(usuario);

      final incomplete = usuario.nombre.isEmpty || usuario.apellido.isEmpty;
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
      Navigator.pushReplacementNamed(context, nextRoute);
    } catch (e, st) {
      debugPrint('Error en Google Sign In: $e\n$st');
      if (context.mounted) {
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: l10n.googleSignInError,
          isError: true,
        );
      }
    }
  }
}
