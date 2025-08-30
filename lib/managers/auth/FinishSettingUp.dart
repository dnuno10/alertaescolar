// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/app/app_routes.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/models/usuario.dart';
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

    // Normalización
    final emailNorm = email.trim().toLowerCase();
    final nombreNorm = nombre.trim();
    final apellidoNorm = apellido.trim();
    final nowUtc = DateTime.now().toUtc();

    LoadingDialog.show(context, message: l10n.settingUpAccount);

    try {
      // 🔐 Guardia de sesión: el usuario solo puede actualizar su propia fila
      final currentId = supabase.auth.currentUser?.id;
      if (currentId == null || currentId != idUser) {
        throw AuthException('Session mismatch');
      }

      // Payload de actualización (no tocamos fecha_registro aquí)
      final Map<String, dynamic> payload = {
        // Si NO quieres permitir cambiar email aquí, comenta la línea de abajo:
        'email': emailNorm,
        'nombre': nombreNorm,
        'apellido': apellidoNorm,
        'tipo': tipo.name,
      };

      // Actualiza y devuelve la fila final
      final updated = await supabase
          .from('usuarios')
          .update(payload)
          .eq('id', idUser)
          .select()
          .maybeSingle();

      // Si por alguna razón la fila no existe (no debería pasar con ensureUserRow),
      // puedes hacer un fallback seguro (upsert). Lo dejamos por robustez:
      Map<String, dynamic> finalRow = updated ??
          await supabase
              .from('usuarios')
              .upsert({
                'id': idUser,
                'email': emailNorm,
                'nombre': nombreNorm,
                'apellido': apellidoNorm,
                'tipo': tipo.name,
                'fecha_registro': nowUtc.toIso8601String(),
              }, onConflict: 'id')
              .select()
              .single();

      if (!context.mounted) return;

      // Actualiza provider con lo que realmente quedó en BD
      final usuario = Usuario.fromJson(finalRow);
      await Provider.of<UserProvider>(context, listen: false)
          .updateUser(usuario);

      if (!context.mounted) return;

      // UI
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        context: context,
        message: l10n.accountSetupSuccessfully,
        isError: false,
      );

      // Navega según tipo de usuario
      final nextRoute = (usuario.tipo == TipoUsuario.administrador)
          ? AppRoutes.adminDashboard
          : AppRoutes.home;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, nextRoute);
        }
      });
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException settingUpAccount: ${e.message}');
      if (context.mounted) {
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: l10n.errorSettingUpAccount,
          isError: true,
        );
      }
    } on AuthException catch (e) {
      debugPrint('AuthException settingUpAccount: ${e.message}');
      if (context.mounted) {
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: l10n.errorSettingUpAccount,
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Unexpected error settingUpAccount: $e');
      if (context.mounted) {
        LoadingDialog.hide(context);
        CustomSnackBar.show(
          context: context,
          message: l10n.errorSettingUpAccount,
          isError: true,
        );
      }
    } finally {
      if (context.mounted) {
        LoadingDialog.hide(context);
      }
    }
  }
}
