// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/managers/auth/AdminSetup.dart';
import 'package:alertaescolar/managers/auth/auth_utils.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/managers/auth/SendingMagicLink.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogIn {
  final BuildContext context;
  LogIn(this.context);

  Future<void> checkAndLogin(String rawEmail) async {
    final l10n = AppLocalizations.of(context);
    final email = rawEmail.trim().toLowerCase();

    LoadingDialog.show(context, message: l10n.loggingIn);
    try {
      final result = await Supabase.instance.client
          .rpc('is_email_registered', params: {'input_email': email});
      final isRegistered = result == true;

      if (!context.mounted) return;

      // Cierra loader antes de cualquier UI
      LoadingDialog.hide(context);

      if (isRegistered) {
        final res = await SendingMagicLink(context: context, email: email)
            .sendMagicLink();

        // Muestra el mensaje proveniente del envío
        CustomSnackBar.show(
          context: context,
          message: res.message,
          isError: !res.success,
        );

        // Navega a verificación si se envió con éxito
        if (res.success) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.verifyMagicLink,
            arguments: email,
          );
        }
      } else {
        CustomSnackBar.show(
          context: context,
          message: l10n.pleaseCreateAccount,
          isError: true,
        );
      }
    } catch (_) {
      if (context.mounted) {
        LoadingDialog.hide(context); // redundante pero seguro
        CustomSnackBar.show(
          context: context,
          message: l10n.loginErrorMessage,
          isError: true,
        );
      }
    } finally {
      if (context.mounted) {
        LoadingDialog.hide(context); // red de seguridad
      }
    }
  }

  Future<void> checkLoginStatus() async {
    final l10n = AppLocalizations.of(context);
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) return;

      final authUser = session.user;
      final emailNorm = (authUser.email ?? '').trim().toLowerCase();

      // 1) Asegura/inserta fila mínima en 'usuarios'
      final usuario = await ensureUserRow(
        supabase: supabase,
        authUser: authUser,
        defaultTipo: TipoUsuario.padre,
      );

      // 2) Admin si aplica (lista blanca)
      if (emailNorm.isNotEmpty) {
        final isAdmin = await AdminSetup.checkAndSetupAdmin(
          context,
          emailNorm,
          authUser.id,
        );
        if (isAdmin) return; // AdminSetup ya pudo navegar/ajustar
      }

      // 3) Actualiza provider y decide ruta
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUser(usuario);

      if (usuario.nombre.isEmpty || usuario.apellido.isEmpty) {
        _showSuccessAndNavigate(
          context,
          l10n.completeYourProfile,
          AppRoutes.finishSettingUp,
        );
      } else {
        final route = usuario.tipo == TipoUsuario.administrador
            ? AppRoutes.adminDashboard
            : AppRoutes.home;
        _showSuccessAndNavigate(context, l10n.loginSuccessful, route);
      }
    } on PostgrestException catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: l10n.unexpectedError,
          isError: true,
        );
      }
      debugPrint("PostgrestException in checkLoginStatus: ${e.message}");
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: l10n.unexpectedError,
          isError: true,
        );
      }
      debugPrint("Unexpected error in checkLoginStatus: $e");
    }
  }

  Future<void> checkAndRegister(String rawEmail) async {
    final l10n = AppLocalizations.of(context);
    final email = rawEmail.trim().toLowerCase();

    // Guard simple por si viene vacío
    if (email.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: l10n.signUpErrorMessage,
        isError: true,
      );
      return;
    }

    LoadingDialog.show(context, message: l10n.registering);

    try {
      final result = await Supabase.instance.client
          .rpc('is_email_registered', params: {'input_email': email});
      final isRegistered = result == true;

      if (!context.mounted) return;

      // Cierra el loader ANTES de cualquier UI
      LoadingDialog.hide(context);

      if (isRegistered) {
        // Si ya existe, muestra error
        CustomSnackBar.show(
          context: context,
          message: l10n.emailAlreadyExists,
          isError: true,
        );
      } else {
        // Enviar magic link y usar su resultado
        final res = await SendingMagicLink(context: context, email: email)
            .sendMagicLink();

        CustomSnackBar.show(
          context: context,
          message: res.message,
          isError: !res.success,
        );

        if (res.success) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.verifyMagicLink,
            arguments: email,
          );
        }
      }
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException in checkAndRegister: ${e.message}');
      if (context.mounted) {
        LoadingDialog.hide(context); // redundante pero seguro
        CustomSnackBar.show(
          context: context,
          message: l10n.signUpErrorMessage,
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Unexpected error in checkAndRegister: $e');
      if (context.mounted) {
        LoadingDialog.hide(context); // redundante pero seguro
        CustomSnackBar.show(
          context: context,
          message: l10n.signUpErrorMessage,
          isError: true,
        );
      }
    } finally {
      // Red de seguridad: por si algún camino no cerró el diálogo
      if (context.mounted) {
        LoadingDialog.hide(context);
      }
    }
  }

  void _showSuccessAndNavigate(
      BuildContext context, String message, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      // Red de seguridad: si por alguna razón quedara abierto, ciérralo.
      LoadingDialog.hide(context);
      CustomSnackBar.show(context: context, message: message, isError: false);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, route);
      }
    });
  }
}
