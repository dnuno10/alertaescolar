// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';

class FinishSettingUp {
  final BuildContext context;
  final String idUser;
  final String email;
  final String nombre;
  final String apellido;
  final TipoUsuario tipo;

  FinishSettingUp({
    required this.context,
    required this.idUser,
    required this.email,
    required this.nombre,
    required this.apellido,
    this.tipo = TipoUsuario.padre,
  });

  Future<void> settingUpAccount() async {
    final supabase = Supabase.instance.client;
    final l10n = AppLocalizations.of(context);

    LoadingDialog.show(context, message: l10n.settingUpAccount);

    try {
      // Insertar usuario en la base de datos
      await supabase.from('usuarios').insert({
        'id': idUser,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'tipo': tipo.name,
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      // Crear usuario local
      final usuario = Usuario(
        id: idUser,
        nombre: nombre,
        apellido: apellido,
        email: email,
        tipo: tipo,
        fechaRegistro: DateTime.now(),
      );

      // Actualizar el provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUser(usuario);

      CustomSnackBar.show(
        context: context,
        message: l10n.accountSetupSuccessfully,
        isError: false,
      );

      // Navegar según el tipo de usuario
      Navigator.pushReplacementNamed(
          context, tipo == TipoUsuario.administrador ? '/admin' : '/');
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: l10n.errorSettingUpAccount,
        isError: true,
      );
      LoadingDialog.hide(context);
    }
  }
}
