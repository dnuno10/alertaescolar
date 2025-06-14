// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinishSettingUp {
  final BuildContext context;
  final String idUser;
  final String email;
  final String nombre;
  final String apellido;

  FinishSettingUp({
    required this.context,
    required this.idUser,
    required this.email,
    required this.nombre,
    required this.apellido,
  });

  Future<void> settingUpAccount() async {
    final supabase = Supabase.instance.client;

    try {
      // Insertar usuario en la base de datos
      await supabase.from('usuarios').insert({
        'id': idUser,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'tipo': 'padre',
        'activo': true,
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      // Crear usuario local
      final usuario = Usuario(
        id: idUser,
        nombre: nombre,
        apellido: apellido,
        email: email,
        fechaRegistro: DateTime.now(),
      );

      // Actualizar el provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUser(usuario);

      CustomSnackBar.show(
        context: context,
        message: 'Cuenta configurada exitosamente',
        isError: false,
      );
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: 'Error al configurar la cuenta',
        isError: true,
      );
      Navigator.pop(context);
    }
  }
}
