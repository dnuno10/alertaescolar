// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
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
    if (code.isEmpty || code.length != 6) {
      CustomSnackBar.show(
        context: context,
        message: 'Por favor ingrese un código válido',
        isError: true,
      );
      Navigator.pop(context);
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
        // Create new user
        final nuevoUsuario = Usuario(
          id: response.user!.id,
          nombre: '',
          apellido: '',
          email: email,
          fechaRegistro: DateTime.now(),
        );

        await userProvider.updateUser(nuevoUsuario);

        _showSuccessAndNavigate(
          context,
          'Verificación exitosa',
          '/finish_setting_up',
        );
      } else {
        final usuario = Usuario.fromJson(userExist);
        await userProvider.updateUser(usuario);

        _showSuccessAndNavigate(
          context,
          'Inicio de sesión exitoso',
          '/admin_dashboard',
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: 'Código inválido',
        isError: true,
      );
      Navigator.pop(context);
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
