// lib/managers/auth/Logout.dart
// ignore_for_file: file_names

import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/provider_manager.dart';

class Logout {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    // Store the navigator before any operations that might affect context
    final navigator = Navigator.of(context);

    try {
      // First clean up the user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();
      ProviderManager.clearAllProvidersData();

      // Then sign out from Supabase
      await _supabaseClient.auth.signOut();

      // If context is still valid, show success message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: l10n.logoutSuccessful,
          isError: false,
        );
      }

      // Navigate using the previously stored navigator
      navigator.pushNamedAndRemoveUntil('/intro', (route) => false);
    } catch (error) {
      debugPrint("Error signing out: $error");

      // Only show error if context is still valid
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: l10n.logoutError,
          isError: true,
        );
      }
    }
  }
}
