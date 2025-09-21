// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/auth/SendingMagicLink.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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

  Future<void> checkAndRegister(String rawEmail) async {
    final l10n = AppLocalizations.of(context);
    final email = rawEmail.trim().toLowerCase();

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
}
