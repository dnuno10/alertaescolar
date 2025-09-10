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

  // Carga contactos del usuario autenticado
  Future<void> loadFamilyContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'No authenticated user found';
        return;
      }

      final data = await _supabase
          .from('contactos_familiares')
          .select('*')
          .eq('id_usuario', user.id)
          .order('fecha_registro', ascending: false);

      _familyContacts
        ..clear()
        ..addAll((data as List)
            .whereType<Map<String, dynamic>>()
            .map(_mapDatabaseToModel));
    } on PostgrestException catch (e) {
      // 42P01 = undefined_table
      if (e.code == '42P01' ||
          e.message.contains(
              'relation "public.contactos_familiares" does not exist')) {
        // Entorno recién provisionado: lista vacía sin error visible
        _familyContacts.clear();
      } else {
        _error = e.message;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading family contacts: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Inserta un contacto (con diálogo de carga)
  Future<ContactoFamiliar?> addFamilyContact(
    BuildContext context,
    String name,
    TipoParentesco relationship,
    String phone,
    String? email,
  ) async {
    final l10n = AppLocalizations.of(context);
    LoadingDialog.show(context, message: l10n.savingContact);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'No authenticated user found';
        return null;
      }

      final now = DateTime.now().toUtc();

      final payload = {
        'id_usuario': user.id,
        'nombre': name,
        'parentesco': relationship.name, // enum como texto
        'telefono': phone,
        'email': email,
        'fecha_registro': now.toIso8601String(),
      };

      final inserted = await _supabase
          .from('contactos_familiares')
          .insert(payload)
          .select()
          .single(); // ← un único registro

      final newContact =
          _mapDatabaseToModel(Map<String, dynamic>.from(inserted));
      _familyContacts.insert(0, newContact);
      return newContact;
    } on PostgrestException catch (e) {
      _error = e.message;
      debugPrint('Error adding family contact (pg): $_error');
      return null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding family contact: $_error');
      return null;
    } finally {
      if (context.mounted) LoadingDialog.hide(context);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Elimina contacto (con diálogo de carga)
  Future<bool> deleteFamilyContact(
      BuildContext context, String contactId) async {
    final l10n = AppLocalizations.of(context);
    LoadingDialog.show(context, message: l10n.deletingContact);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'No authenticated user found';
        return false;
      }

      await _supabase
          .from('contactos_familiares')
          .delete()
          .eq('id', contactId)
          .eq('id_usuario', user.id); // ← cinturón y tirantes

      _familyContacts.removeWhere((c) => c.id == contactId);
      return true;
    } on PostgrestException catch (e) {
      _error = e.message;
      debugPrint('Error deleting family contact (pg): $_error');
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting family contact: $_error');
      return false;
    } finally {
      if (context.mounted) LoadingDialog.hide(context);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualiza contacto (con diálogo de carga)
  Future<bool> updateFamilyContact(
      BuildContext context, ContactoFamiliar updatedContact) async {
    final l10n = AppLocalizations.of(context);
    LoadingDialog.show(context, message: l10n.updatingContact);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'No authenticated user found';
        return false;
      }

      final payload = {
        'nombre': updatedContact.nombre,
        'parentesco': updatedContact.parentesco.name,
        'telefono': updatedContact.telefono,
        'email': updatedContact.email,
      };

      final updated = await _supabase
          .from('contactos_familiares')
          .update(payload)
          .eq('id', updatedContact.id)
          .eq('id_usuario', user.id) // ← más seguro con RLS
          .select()
          .single(); // si RLS permite devolver el registro actualizado

      final fromDb = _mapDatabaseToModel(Map<String, dynamic>.from(updated));
      final idx = _familyContacts.indexWhere((c) => c.id == updatedContact.id);
      if (idx != -1) _familyContacts[idx] = fromDb;

      return true;
    } on PostgrestException catch (e) {
      _error = e.message;
      debugPrint('Error updating family contact (pg): $_error');
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating family contact: $_error');
      return false;
    } finally {
      if (context.mounted) LoadingDialog.hide(context);
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Helpers ----

  ContactoFamiliar _mapDatabaseToModel(Map<String, dynamic> data) {
    final fechaStr = data['fecha_registro']?.toString();
    final parsed = fechaStr != null ? DateTime.tryParse(fechaStr) : null;

    return ContactoFamiliar(
      id: (data['id'] ?? '').toString(),
      usuarioId: (data['id_usuario'] ?? '').toString(),
      nombre: (data['nombre'] ?? '').toString(),
      parentesco: _parseParentesco(data['parentesco']?.toString()),
      telefono: data['telefono']?.toString(), // ← respeta null
      email: data['email']?.toString(),
      fechaRegistro: parsed ?? DateTime.now().toUtc(),
    );
  }

  TipoParentesco _parseParentesco(String? v) {
    if (v == null) return TipoParentesco.otroFamiliar;
    try {
      return TipoParentesco.values.firstWhere(
        (e) => e.name == v,
        orElse: () => TipoParentesco.otroFamiliar,
      );
    } catch (_) {
      return TipoParentesco.otroFamiliar;
    }
  }

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
