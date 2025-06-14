// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/managers/auth/AdminSetup.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyMagicLink {
  final BuildContext context;
  final String email;
  final String code;

  VerifyMagicLink(
      {required this.context, required this.email, required this.code});

  /// Verifica el código de autenticación en Supabase
  Future<void> verifyCode() async {
    final l10n = AppLocalizations.of(context);

    if (code.isEmpty || code.length != 6) {
      // Close loading dialog first
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        context: context,
        message: l10n.enterCompleteCode,
        isError: true,
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        token: code,
        email: email,
      );

      if (response.session == null) {
        throw Exception('No session returned');
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userExist = await Supabase.instance.client
          .from('usuarios')
          .select('*')
          .eq('email', email)
          .maybeSingle();

      if (userExist == null) {
        // Usuario no existe, verificar si es un administrador en la lista de acceso
        final isAdmin = await AdminSetup.checkAndSetupAdmin(
          context,
          email,
          response.user!.id,
        );

        if (isAdmin) {
          // Si ya se configuró como administrador, se ha manejado la navegación
          LoadingDialog.hide(context);
          return;
        }

        // Si no es admin, continuar con el flujo normal
        // Create new user
        final nuevoUsuario = Usuario(
          id: response.user!.id,
          nombre: '',
          apellido: '',
          email: email,
          fechaRegistro: DateTime.now(),
        );

        await userProvider.updateUser(nuevoUsuario);

        LoadingDialog.hide(context);
        _showSuccessAndNavigate(
          context,
          l10n.codeVerifiedSuccessfully,
          '/finish_setting_up',
        );
      } else {
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        LoadingDialog.hide(context);

        if (usuario.nombre.isEmpty || usuario.apellido.isEmpty) {
          // Perfil incompleto, redirigir a configuración
          _showSuccessAndNavigate(
            context,
            l10n.completeYourProfile,
            '/finish_setting_up',
          );
        } else {
          // Perfil completo, redirigir según el tipo de usuario
          _showSuccessAndNavigate(
            context,
            l10n.loginSuccessful,
            usuario.tipo == TipoUsuario.administrador ? '/admin' : '/',
          );
        }
      }
    } catch (e) {
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        context: context,
        message: l10n.invalidVerificationCode,
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
