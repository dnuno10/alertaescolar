import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grupo.dart';
import '../components/loading_dialog.dart';

class GroupProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Grupo> _grupos = [];
  Grupo? _selectedGroup;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Grupo> get grupos => _grupos;
  Grupo? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper local para evitar dependencia a extensiones firstOrNull
  T? _firstOrNull<T>(Iterable<T> it) {
    final i = it.iterator;
    return i.moveNext() ? i.current : null;
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load all groups for a school (opcionalmente filtrado por nivel)
  Future<void> loadGroups({
    required String escuelaId,
    String? nivelEducativo,
    BuildContext? context,
  }) async {
    bool showDialogHere = false;
    try {
      _isLoading = true;
      _error = null;

      if (context != null && context.mounted) {
        if (!LoadingDialog.isVisible) {
          LoadingDialog.show(context, message: 'Cargando grupos...');
          showDialogHere = true;
        }
      }
      notifyListeners();

      // Primero filtros (PostgrestFilterBuilder)...
      var filterBuilder =
          _supabase.from('grupos').select().eq('id_escuela', escuelaId);

      if (nivelEducativo != null && nivelEducativo.isNotEmpty) {
        filterBuilder = filterBuilder.eq('nivel_educativo', nivelEducativo);
      }

      // ...al final los orders (TransformBuilder)
      final response =
          await filterBuilder.order('nivel_educativo').order('grupo');

      _grupos = (response as List).map((item) => Grupo.fromJson(item)).toList();

      _error = null;
      debugPrint('Loaded ${_grupos.length} groups from database');
    } catch (e) {
      _error = 'Error al cargar grupos: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted && showDialogHere) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Load a specific group by ID
  Future<Grupo?> loadGroupById({
    required String groupId,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando grupo...');
      }
      notifyListeners();

      final response =
          await _supabase.from('grupos').select().eq('id', groupId).single();

      final grupo = Grupo.fromJson(response);
      _selectedGroup = grupo;

      // Add to list if not already present
      final existingIndex = _grupos.indexWhere((g) => g.id == groupId);
      if (existingIndex == -1) {
        _grupos.add(grupo);
      } else {
        _grupos[existingIndex] = grupo;
      }

      _error = null;
      return grupo;
    } catch (e) {
      _error = 'Error al cargar grupo: $e';
      debugPrint(_error);
      return null;
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Create a new group
  Future<Grupo?> createGroup({
    required String escuelaId,
    required String grupo,
    required String nivelEducativo,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Creando grupo...');
      }
      notifyListeners();

      // Evita duplicados locales (rápido) — no bloquea validación en BD
      final existingGroup = _firstOrNull(_grupos.where((g) =>
          g.idEscuela == escuelaId &&
          g.grupo == grupo &&
          g.nivelEducativo == nivelEducativo));

      if (existingGroup != null) {
        throw Exception(
            'Ya existe un grupo con este nombre en este nivel educativo');
      }

      final response = await _supabase
          .from('grupos')
          .insert({
            'id_escuela': escuelaId,
            'grupo': grupo,
            'nivel_educativo': nivelEducativo,
          })
          .select()
          .single();

      final newGroup = Grupo.fromJson(response);
      _grupos.add(newGroup);

      // Sort groups after adding
      _sortGroups();

      _error = null;
      debugPrint('Created new group: ${newGroup.grupo}');
      return newGroup;
    } catch (e) {
      _error = 'Error al crear grupo: $e';
      debugPrint(_error);
      return null;
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Update an existing group
  Future<bool> updateGroup({
    required String groupId,
    String? grupo,
    String? nivelEducativo,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Actualizando grupo...');
      }
      notifyListeners();

      final updateData = <String, dynamic>{};
      if (grupo != null) updateData['grupo'] = grupo;
      if (nivelEducativo != null) {
        updateData['nivel_educativo'] = nivelEducativo;
      }

      if (updateData.isEmpty) {
        throw Exception('No hay cambios para actualizar');
      }

      await _supabase.from('grupos').update(updateData).eq('id', groupId);

      // Update local data
      final index = _grupos.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        final currentGroup = _grupos[index];
        _grupos[index] = currentGroup.copyWith(
          grupo: grupo,
          nivelEducativo: nivelEducativo,
        );

        // Update selected group if it's the one being updated
        if (_selectedGroup?.id == groupId) {
          _selectedGroup = _grupos[index];
        }

        // Sort groups after updating
        _sortGroups();
      }

      _error = null;
      debugPrint('Updated group: $groupId');
      return true;
    } catch (e) {
      _error = 'Error al actualizar grupo: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Delete a group
  Future<bool> deleteGroup({
    required String groupId,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Eliminando grupo...');
      }
      notifyListeners();

      await _supabase.from('grupos').delete().eq('id', groupId);

      // Remove from local data
      _grupos.removeWhere((g) => g.id == groupId);

      // Clear selected group if it was deleted
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = null;
      }

      _error = null;
      debugPrint('Deleted group: $groupId');
      return true;
    } catch (e) {
      _error = 'Error al eliminar grupo: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Get groups by educational level (nombre de nivel)
  List<Grupo> getGroupsByNivelEducativo(String nivelEducativo) {
    return _grupos
        .where((grupo) => grupo.nivelEducativo == nivelEducativo)
        .toList();
  }

  // Get groups by school
  List<Grupo> getGroupsBySchool(String escuelaId) {
    return _grupos.where((grupo) => grupo.idEscuela == escuelaId).toList();
  }

  // Get all unique educational levels
  List<String> getAvailableNivelesEducativos() {
    final niveles = _grupos
        .map((grupo) => grupo.nivelEducativo)
        .where((nivel) => nivel.isNotEmpty)
        .toSet()
        .toList();
    niveles.sort();
    return niveles;
  }

  // Get group names for a specific educational level
  List<String> getGroupNamesByNivel(String nivelEducativo) {
    return _grupos
        .where((grupo) => grupo.nivelEducativo == nivelEducativo)
        .map((grupo) => grupo.grupo)
        .toList();
  }

  // Set selected group
  void setSelectedGroup(Grupo? group) {
    _selectedGroup = group;
    notifyListeners();
  }

  // Clear groups list
  void clearGroups() {
    _grupos.clear();
    _selectedGroup = null;
    notifyListeners();
  }

  // Search groups
  List<Grupo> searchGroups(String query) {
    if (query.isEmpty) return _grupos;

    final searchQuery = query.toLowerCase();
    return _grupos.where((grupo) {
      return grupo.grupo.toLowerCase().contains(searchQuery) ||
          grupo.nivelEducativo.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Get group by name and educational level
  Grupo? getGroupByNameAndLevel(String grupoName, String nivelEducativo) {
    return _firstOrNull(_grupos.where((grupo) =>
        grupo.grupo == grupoName && grupo.nivelEducativo == nivelEducativo));
  }

  // Helper method to sort groups
  void _sortGroups() {
    _grupos.sort((a, b) {
      // First sort by educational level, then by group name
      final nivelComparison = a.nivelEducativo.compareTo(b.nivelEducativo);
      if (nivelComparison != 0) return nivelComparison;
      return a.grupo.compareTo(b.grupo);
    });
  }

  // Get statistics
  Map<String, int> getGroupStatistics() {
    final stats = <String, int>{};
    stats['total'] = _grupos.length;

    for (final grupo in _grupos) {
      final nivel = grupo.nivelEducativo;
      stats[nivel] = (stats[nivel] ?? 0) + 1;
    }

    return stats;
  }

  // Validate group data before operations
  bool validateGroupData({
    required String grupo,
    required String nivelEducativo,
    required String escuelaId,
  }) {
    if (grupo.isEmpty) {
      _error = 'El nombre del grupo no puede estar vacío';
      return false;
    }

    if (nivelEducativo.isEmpty) {
      _error = 'El nivel educativo no puede estar vacío';
      return false;
    }

    if (escuelaId.isEmpty) {
      _error = 'La escuela no puede estar vacía';
      return false;
    }

    // Check for valid group format (personalizable)
    final groupRegex = RegExp(r'^[0-9]{1,2}°?[A-Z]?$');
    if (!groupRegex.hasMatch(grupo)) {
      _error = 'El formato del grupo no es válido (ej: 1°A, 2B, 3°)';
      return false;
    }

    return true;
  }

  void clearAllData() {
    _grupos.clear();
    _selectedGroup = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
