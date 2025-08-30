import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SendingResult {
  final bool success;
  final String message;
  const SendingResult({required this.success, required this.message});
}

class SendingMagicLink {
  final BuildContext context;
  final String email;

  SendingMagicLink({required this.context, required this.email});

  Future<SendingResult> requestMagicLink({bool isResend = false}) async {
    final l10n = AppLocalizations.of(context);
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      return SendingResult(
        success: false,
        message: l10n
            .loginErrorMessage, // o crea una key específica: l10n.enterValidEmail
      );
    }

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: normalizedEmail,
        // Configura según tu flujo:
        // emailRedirectTo: 'https://tuapp.com/auth/callback',
        shouldCreateUser: true,
      );

      // Mensaje único para enviar y reenviar; si quieres distinguir, usa isResend.
      final msg = l10n.magicLinkSent; // asumiendo no nulo
      return SendingResult(success: true, message: msg);
    } on AuthException catch (e) {
      // Errores propios de Supabase (rate limit, email inválido, etc.)
      return SendingResult(
        success: false,
        message: e.message.isNotEmpty ? e.message : l10n.loginErrorMessage,
      );
    } catch (_) {
      return SendingResult(
        success: false,
        message: l10n.loginErrorMessage,
      );
    }
  }

  // Helpers azucarados si quieres conservar nombres previos:
  Future<SendingResult> sendMagicLink() => requestMagicLink(isResend: false);
  Future<SendingResult> resendMagicLink() => requestMagicLink(isResend: true);
}
