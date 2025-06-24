import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contacto_familiar.dart';
import '../components/loading_dialog.dart';
import '../l10n/app_localizations.dart';

class FamilyProvider extends ChangeNotifier {
  final List<ContactoFamiliar> _familyContacts = [];
  bool _isLoading = false;
  String? _error;

  List<ContactoFamiliar> get contacts => List.unmodifiable(_familyContacts);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasContacts => _familyContacts.isNotEmpty;
  int get contactsCount => _familyContacts.length;

  final SupabaseClient _supabase = Supabase.instance.client;

  // Load family contacts for the current user
  Future<void> loadFamilyContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get the current authenticated user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'No authenticated user found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load contacts for the current user from Supabase
      try {
        final data = await _supabase
            .from('contactos_familiares')
            .select('*')
            .eq('id_usuario', user.id)
            .order('fecha_registro', ascending: false);

        _familyContacts.clear();
        for (final item in data) {
          _familyContacts.add(_mapDatabaseToModel(item));
        }
      } catch (e) {
        // Handle specific PostgreSQL error for table not existing
        if (e.toString().contains(
            'relation "public.contactos_familiares" does not exist')) {
          debugPrint(
              "Family contacts table doesn't exist yet. This is normal for new installations.");
          _familyContacts.clear();
        } else {
          rethrow;
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading family contacts: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new family contact with loading dialog
  Future<ContactoFamiliar?> addFamilyContact(BuildContext context, String name,
      TipoParentesco relationship, String phone, String? email) async {
    final l10n = AppLocalizations.of(context);

    // Show loading dialog
    LoadingDialog.show(
      context,
      message: l10n.savingContact,
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get the current authenticated user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'No authenticated user found';
        return null;
      }

      final now = DateTime.now();

      // Prepare data for insertion using the database column names
      final data = {
        'id_usuario': user.id,
        'nombre': name,
        'parentesco': relationship.name, // Store as string
        'telefono': phone,
        'email': email,
        'fecha_registro': now.toIso8601String()
      };

      // Insert into Supabase
      final response =
          await _supabase.from('contactos_familiares').insert(data).select();

      if (response.isNotEmpty) {
        // Create a new contact object and add to the list
        final newContact = _mapDatabaseToModel(response[0]);
        _familyContacts.insert(
            0, newContact); // Add to the beginning of the list
        return newContact;
      }

      return null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding family contact: $_error');
      return null;
    } finally {
      // Hide loading dialog
      if (context.mounted) {
        LoadingDialog.hide(context);
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a family contact with loading dialog
  Future<bool> deleteFamilyContact(
      BuildContext context, String contactId) async {
    final l10n = AppLocalizations.of(context);

    // Show loading dialog
    LoadingDialog.show(
      context,
      message: l10n.deletingContact,
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete from Supabase
      await _supabase.from('contactos_familiares').delete().eq('id', contactId);

      // Remove from local list
      _familyContacts.removeWhere((contact) => contact.id == contactId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting family contact: $_error');
      return false;
    } finally {
      // Hide loading dialog
      if (context.mounted) {
        LoadingDialog.hide(context);
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a family contact with loading dialog
  Future<bool> updateFamilyContact(
      BuildContext context, ContactoFamiliar updatedContact) async {
    final l10n = AppLocalizations.of(context);

    // Show loading dialog
    LoadingDialog.show(
      context,
      message: l10n.updatingContact,
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Prepare data for update
      final data = {
        'nombre': updatedContact.nombre,
        'parentesco': updatedContact.parentesco.name,
        'telefono': updatedContact.telefono,
        'email': updatedContact.email,
      };

      // Update in Supabase
      await _supabase
          .from('contactos_familiares')
          .update(data)
          .eq('id', updatedContact.id);

      // Update in local list
      final index =
          _familyContacts.indexWhere((c) => c.id == updatedContact.id);
      if (index != -1) {
        _familyContacts[index] = updatedContact;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating family contact: $_error');
      return false;
    } finally {
      // Hide loading dialog
      if (context.mounted) {
        LoadingDialog.hide(context);
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to convert database response to model
  ContactoFamiliar _mapDatabaseToModel(Map<String, dynamic> data) {
    return ContactoFamiliar(
      id: data['id'] ?? '',
      usuarioId: data['id_usuario'] ?? '',
      nombre: data['nombre'] ?? '',
      parentesco: _parseParentesco(data['parentesco']),
      telefono: data['telefono'] ?? '',
      email: data['email'],
      fechaRegistro: DateTime.parse(data['fecha_registro']),
    );
  }

  // Helper method to parse parentesco from string to enum
  TipoParentesco _parseParentesco(String? parentescoString) {
    if (parentescoString == null) return TipoParentesco.otroFamiliar;

    try {
      return TipoParentesco.values.firstWhere(
        (e) => e.name == parentescoString,
        orElse: () => TipoParentesco.otroFamiliar,
      );
    } catch (e) {
      return TipoParentesco.otroFamiliar;
    }
  }

  // Helper method to clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAllData() {
    _familyContacts.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
