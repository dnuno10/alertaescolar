// ignore_for_file: file_names, use_build_context_synchronously

import 'package:alertaescolar/managers/auth/AdminSetup.dart';
import 'package:alertaescolar/managers/auth/auth_utils.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum VerifyNext { finishSetup, admin, home }

class VerifyResult {
  final String message;
  final VerifyNext next;
  const VerifyResult(this.message, this.next);
}

class VerifyMagicLink {
  final BuildContext context;
  final String email;
  final String code;

  VerifyMagicLink({
    required this.context,
    required this.email,
    required this.code,
  });

  Future<VerifyResult> verifyCode() async {
    final l10n = AppLocalizations.of(context);

    if (code.isEmpty || code.length != 6) {
      throw FormatException(l10n.enterCompleteCode);
    }

    final supabase = Supabase.instance.client;

    final response = await supabase.auth.verifyOTP(
      type: OtpType.email,
      token: code,
      email: email,
    );
    if (response.session == null || response.user == null) {
      throw Exception(l10n.invalidVerificationCode);
    }

    final authUser = response.user!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 1) Asegura/inserta fila mínima
    final usuario = await ensureUserRow(
      supabase: supabase,
      authUser: authUser,
      defaultTipo: TipoUsuario.padre,
    );

    // 2) Admin por lista blanca (por email verificado)
    final isAdmin = await AdminSetup.checkAndSetupAdmin(
      context,
      email.trim().toLowerCase(),
      authUser.id,
    );
    if (isAdmin) {
      return VerifyResult(l10n.loginSuccessful, VerifyNext.admin);
    }

    // 3) Hidrata provider y decide siguiente paso
    await userProvider.updateUser(usuario);

    if (usuario.nombre.isEmpty || usuario.apellido.isEmpty) {
      return VerifyResult(
          l10n.codeVerifiedSuccessfully, VerifyNext.finishSetup);
    }

    final next = usuario.tipo == TipoUsuario.administrador
        ? VerifyNext.admin
        : VerifyNext.home;
    return VerifyResult(l10n.loginSuccessful, next);
  }
}
