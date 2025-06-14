import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SendingMagicLink {
  final BuildContext context;
  final String email;

  SendingMagicLink({required this.context, required this.email});

  Future<void> sendMagicLink() async {
    final l10n = AppLocalizations.of(context);

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email.trim(),
      );

      CustomSnackBar.show(
        context: context,
        message: l10n.magicLinkSent ?? 'Magic link sent successfully',
        isError: false,
      );
      LoadingDialog.hide(context);

      Navigator.pushReplacementNamed(
        context,
        '/verify_magic_link',
        arguments: email,
      );
    } catch (error) {
      CustomSnackBar.show(
        context: context,
        message: l10n.loginErrorMessage,
        isError: true,
      );
      LoadingDialog.hide(context);
    }
  }

  Future<void> resendMagicLink() async {
    final l10n = AppLocalizations.of(context);

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email.trim(),
      );

      CustomSnackBar.show(
        context: context,
        message: l10n.magicLinkSent ?? 'Magic link sent successfully',
        isError: false,
      );
      LoadingDialog.hide(context);
    } catch (error) {
      CustomSnackBar.show(
        context: context,
        message: l10n.loginErrorMessage,
        isError: true,
      );
      LoadingDialog.hide(context);
    }
  }
}
